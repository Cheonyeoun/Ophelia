# Ophelia — system architecture

A production-grade Flutter music player. This document is the single source of truth for how Ophelia is engineered: layers, data flow, storage, playback, resilience, testing, and the reasoning behind each choice. UI/UX design comes after this is settled.

---

## 1. Design goals (what "production-grade" means here)

| Goal | What it actually requires |
|---|---|
| Replaceable parts | Hexagonal architecture — domain never imports a package directly |
| Works with a broken/changed API | Every external dependency sits behind an interface (port) |
| Works offline | Local DB is the source of truth for everything except raw audio bytes |
| Portable user data | Full export/import of the local DB as a single file |
| Doesn't crash under real conditions | Explicit error types, retries, circuit breakers, graceful degradation |
| Maintainable at scale | Feature-first folders, one direction of dependency, enforced by lint rules |
| Provably correct | Domain and use cases are unit-testable with zero Flutter/network/DB involved |

---

## 2. The architecture: hexagonal (ports & adapters)

**The rule that makes everything else work:** dependencies point *inward*. The domain knows nothing about Flutter, SQL, HTTP, or `just_audio`. Everything external is plugged in from the outside through an interface the domain defines.

```
                         ┌─────────────────────────────┐
                         │        Presentation          │
                         │  (Flutter widgets, Riverpod)  │
                         └───────────────┬───────────────┘
                                         │ calls
                         ┌───────────────▼───────────────┐
                         │      Application (use cases)   │
                         │  PlayTrack, SearchCatalog, ...  │
                         └───────────────┬───────────────┘
                                         │ depends on (interfaces only)
                         ┌───────────────▼───────────────┐
                         │            Domain              │
                         │  Track, Playlist, PlaybackState │
                         │  Ports: MediaSourcePort, etc.   │
                         └───────────────┬───────────────┘
                                         │ implemented by
              ┌──────────────┬──────────┼──────────┬──────────────┐
              ▼              ▼          ▼          ▼              ▼
        MediaSource DB   LocalLibrary  Download  Playback     ExportImport
        adapter          adapter       adapter   adapter      adapter
        (API client)     (Drift)       (dio +    (just_audio  (file writer)
                                        disk)     + audio_service)
```

**Learning note — why this beats a "normal" layered app:** in a typical Flutter app, a widget calls a repository that calls `http` or `sqflite` directly. That's fine for a small app, but it means every external change (API v2, switching databases) ripples through your UI code. Here, a change to the API only touches one adapter file. Your domain and your screens never notice.

---

## 3. Layer-by-layer breakdown

### 3.1 Domain layer (pure Dart, no Flutter import allowed)

**Entities** — plain immutable classes, no framework code:
- `Track` (id, title, artist, album, durationMs, coverArtUrl/path, sourceType: streamed | local | downloaded)
- `Album`, `Artist`
- `Playlist` (id, name, ordered track ids)
- `UserProfile` (displayName, backgroundImage, profileImage)
- `ListeningEvent` (trackId, playedAt, msPlayed) — raw data behind "top 5 this week"
- `PlaybackState` (currentTrack, position, queue, isImmersive, repeatMode, shuffle)
- `DownloadRecord` (trackId, localPath, sizeBytes, downloadedAt)
- `Settings` (streamingQuality, gaplessPlayback, downloadQuality, wifiOnlyDownloads, connectedServer)

**Ports** (abstract interfaces, defined here, implemented in infrastructure):
- `MediaSourcePort`: `search(query)`, `getTracksByArtist(artistName)`, `getStreamUrl(trackId)`, `getTrackMetadata(trackId)`, `getCoverArt(trackId)`
- `LocalLibraryPort`: CRUD for playlists, profile, listening events
- `DownloadPort`: `download(track)`, `deleteDownload(trackId)`, `isDownloaded(trackId)`
- `PlaybackEnginePort`: `play(track, sourcePath, {queueIndex})`, `resume()`, `pause()`, `seek(duration)`, `skipNext()`, `skipPrevious()`, `setQueue(tracks)`, `setShuffle(enabled)`, `setRepeatMode(mode)`, `captureNavigationState()`, `restoreNavigationState(snapshot)`
- `ExportImportPort`: `exportBundle() -> File`, `importBundle(File)`
- `SettingsPort`: `getSettings()`, `saveSettings(settings)`

**Why ports live in the domain, not infrastructure:** the domain decides what it needs. Infrastructure adapts to the domain's contract — never the other way around. This is the "dependency inversion" in SOLID, made concrete.

### 3.2 Application layer (use cases)

One class per user-meaningful action. Each use case depends only on ports (interfaces), injected via constructor.

```dart
class PlayTrack {
  final PlaybackEnginePort playback;
  final MediaSourcePort mediaSource;
  final DownloadPort downloads;
  final LocalLibraryPort library;

  PlayTrack(this.playback, this.mediaSource, this.downloads, this.library);

  Future<void> call(Track track) async {
    final source = await downloads.isDownloaded(track.id)
        ? await downloads.localPathFor(track.id)
        : await mediaSource.getStreamUrl(track.id);
    await playback.play(track, source);
    await library.recordListeningEvent(track.id);
  }
}
```

**Learning note:** this is where "download-first, stream-fallback" logic lives — once, in one place — instead of scattered across UI code. Every screen that plays a track calls this same use case and gets the same guarantees.

Key use cases: `PlayTrack`, `PauseTrack`, `ResumeTrack`, `SeekBy`, `SkipNext/Previous`, `SearchCatalog`, `GetArtistTracks`, `GetPlaylistTracks`, `BuildQueue`, `ToggleImmersive`, `ToggleShuffle`, `ToggleRepeatMode`, `DownloadTrack`, `RemoveDownload`, `ComputeTopSongs(window: 7d)`, `ExportLibrary`, `ImportLibrary`, `SavePlaylist`, `UpdateProfile`, `SetStreamingQuality`, `ToggleGaplessPlayback`, `SetDownloadQuality`, `ToggleWifiOnlyDownloads`, `SetConnectedServer`.

### 3.3 Infrastructure layer (adapters — the only place packages are imported)

| Port | Adapter | Package(s) |
|---|---|---|
| `MediaSourcePort` | `ApiMediaSourceAdapter` | `dio`, `retrofit` or hand-rolled client |
| `LocalLibraryPort` | `DriftLibraryAdapter` | `drift` (SQLite) |
| `DownloadPort` | `DiskDownloadAdapter` | `dio`, `path_provider` |
| `PlaybackEnginePort` | `JustAudioPlaybackAdapter` | `just_audio`, `audio_service` |
| `ExportImportPort` | `FileExportAdapter` | `path_provider`, `share_plus` |
| `SettingsPort` | TBD — likely the same Drift DB as `LocalLibraryPort`, or `shared_preferences` | `drift` or `shared_preferences` |

Each adapter is the *only* place that knows about its underlying package. If `just_audio` is ever abandoned, you write `NewEnginePlaybackAdapter` implementing the same `PlaybackEnginePort` — nothing else in the app changes.

### 3.4 Presentation layer (Flutter + Riverpod)

Screens never call adapters. They call use cases through providers.

```dart
final playTrackProvider = Provider((ref) => PlayTrack(
  ref.read(playbackEngineProvider),
  ref.read(mediaSourceProvider),
  ref.read(downloadPortProvider),
  ref.read(localLibraryProvider),
));
```

**Why Riverpod specifically:** it gives you compile-time-safe dependency injection (swap real adapters for fakes in tests by overriding one provider), it doesn't need `BuildContext` to read state, and it scales cleanly as feature count grows — all useful properties for a "not-MVP" app.

---

## 4. Feature-first folder structure

```
lib/
  core/
    domain/          # entities + ports (no Flutter imports)
    usecases/        # application layer
    error/           # Failure types, Result<T> wrapper
  data/
    media_source/    # ApiMediaSourceAdapter + DTOs + mappers
    local_db/         # Drift schema, DAOs, DriftLibraryAdapter
    downloads/        # DiskDownloadAdapter
    export_import/    # FileExportAdapter, bundle format
  playback/
    engine/           # JustAudioPlaybackAdapter, audio_service handler
  features/
    home/
    library/
    artist/           # artist detail screen
    playlist/         # playlist detail screen
    profile/
    playback_ui/      # immersive + everyday play screens, the queue screen
    settings/
    search/
  app/
    router.dart
    theme.dart
    providers.dart     # top-level provider wiring / composition root
```

**Rule enforced by lint (`import_lint` or a custom `analysis_options.yaml` rule):** files under `core/domain` and `core/usecases` cannot import anything from `data/`, `playback/`, or `features/`. This is what actually *forces* the architecture to hold as the codebase grows — without it, "hexagonal" degrades into a diagram nobody follows by month three.

---

## 5. Data architecture

### 5.1 What's local vs. remote

| Data | Lives where | Why |
|---|---|---|
| Playlists, profile, listening history, settings | Local DB (Drift/SQLite) — source of truth | Yours; must be portable and offline |
| Song metadata, cover art, stream URLs | Fetched from media API, cached locally | Catalog too large to own |
| Downloaded audio files | Local disk, indexed in `DownloadRecord` table | User explicitly opted in |
| "Top 5 / most heard this week" | Computed from local `ListeningEvent` table | Pure local aggregation, no network needed |

### 5.2 Local schema (Drift, simplified)

- `playlists(id, name, created_at)`
- `playlist_tracks(playlist_id, track_id, position)`
- `cached_tracks(id, title, artist, album, duration_ms, cover_art_path, is_downloaded)`
- `listening_events(id, track_id, played_at, ms_played)`
- `profile(id, display_name, background_path, profile_image_path)`
- `downloads(track_id, local_path, size_bytes, downloaded_at)`

### 5.3 Local DB performance (Drift/SQLite optimization)

A local database being "just SQLite" doesn't mean it's fast by default — these are the concrete practices that keep it production-grade as the library grows:

- **Off the UI thread:** run Drift via a background isolate (`DriftIsolate`/`NativeDatabase.createInBackground`) so no query ever blocks the main thread or causes frame drops during scroll.
- **Deliberate indexing:** index all foreign keys (`playlist_tracks.track_id`, `listening_events.track_id`) and hot filter/sort columns (`listening_events.played_at`). Avoid over-indexing write-heavy tables.
- **FTS5 for search:** index title/artist/album in an SQLite FTS5 virtual table instead of `LIKE '%query%'` — the difference between instant search and stutter at scale.
- **Materialized aggregates:** maintain a small `weekly_stats` table updated incrementally, rather than a live `GROUP BY` over all of `listening_events` every time the profile screen opens.
- **WAL mode:** `PRAGMA journal_mode=WAL` so background writes (listening events) don't block foreground reads (library browsing).
- **Batched writes:** buffer and batch-write listening events (e.g. on track completion) in a single transaction, not per playback tick.
- **No blobs in the DB:** cover art and audio files live on disk; only paths are stored in SQLite. Keeps the DB small, fast to `VACUUM`, and fast to export.
- **Pagination everywhere:** library/queue views use `LIMIT`/keyset pagination, never load the full track table into memory.
- **Periodic maintenance:** `VACUUM`/`ANALYZE` on app idle or via a "optimize library" settings action.

### 5.4 Export/import format

A `.ophelia` bundle = a zip containing:
- `library.sqlite` (a snapshot copy of the Drift DB)
- `manifest.json` (schema version, export timestamp, app version — critical for handling future migrations gracefully)
- optionally, downloaded audio files (toggle: "include downloads" vs "metadata only," since audio files can be large)

Import validates `manifest.json`'s schema version first and runs migrations if the importing device is on a newer schema — never blindly overwrites.

---

## 6. Navigation shell

The bottom nav bar and the mini-player are two separate, independently-scoped pieces of persistent UI — both live in the root scaffold that wraps the tab navigator, not in individual screens. This is what keeps the rule below trivial to honor as new screens get added later, instead of something that has to be remembered per screen.

| Screen | Bottom nav bar | Mini-player |
|---|---|---|
| Home (root tab) | Yes | Yes, if a track is loaded |
| Library (root tab) | Yes | Yes |
| Settings (root tab) | Yes | Yes |
| Search (pushed from Home) | No — full screen, back arrow | Yes |
| Downloads (pushed from Library/Settings) | No — full screen, back arrow | Yes |
| Artist detail (pushed from an artist anywhere) | No — full screen, back arrow | Yes |
| Playlist detail (pushed from Library/Home) | No — full screen, back arrow | Yes |
| Queue (pushed from Everyday Play) | No — full screen, back arrow | No (see below) |
| Everyday play | No | — (this screen is the player) |
| Immersive play | No | — (this screen is the player) |

Rules:
- **Nav bar scope:** only the three root tabs (Home, Library, Settings) show the bottom nav bar. Any screen reached by pushing (Search, Downloads, playlist/artist detail, etc.) is a full-screen push with a back arrow — standard mobile pattern, and it keeps the tab bar meaningfully tied to top-level destinations only.
- **Mini-player scope:** shown on every screen except the two screens that are themselves the player (Everyday Play, Immersive Play) — and Queue, which is nested alongside them as a route outside the outer shell rather than inside it, since it's only ever reached by pushing from Everyday Play (itself already outside that shell); crossing from a route outside the shell into one nested inside it trips a Navigator duplicate-page-key assertion. The mini-player hides entirely when nothing is loaded, rather than rendering an empty/disabled bar.
- **Persistence:** the mini-player is one persistent widget instance across navigation — it must not remount or flicker when moving between Home → Library → a pushed detail screen.
- **Entry point:** tapping the mini-player navigates to Everyday Play (slide up from bottom) — the only interaction that transitions into the two player-only screens from elsewhere in the app.

## 7. Playback engine architecture

Background playback (notification controls, lock screen, headphone buttons) is a genuinely hard problem in Flutter if done from scratch — this is one place to lean on a mature package rather than reinvent it.

- `audio_service` runs the actual playback in a background isolate/service so music keeps playing when the app is backgrounded or the screen locks.
- `just_audio` handles the decode/stream/gapless-playback layer underneath it, and supports both network streams and local file paths transparently — which is exactly what `PlaybackEnginePort` needs to abstract over "streamed" vs. "downloaded" without the use case caring.
- The **Immersive** and **Everyday** play screens both subscribe to the *same* playback state stream from the adapter; they differ only in which controls they render. This directly reflects your wireframe: two views, one state source.

---

## 8. Resilience & error handling (what makes it "production," not "demo")

- **Result type instead of exceptions crossing layers:** use cases return `Result<T, Failure>` (a sealed class: `NetworkFailure`, `NotFoundFailure`, `StorageFailure`, `DecodeFailure`). UI pattern-matches on this to show the right state — never a raw try/catch scattered in widgets.
- **Retry with backoff** on `MediaSourceAdapter` network calls (e.g. via `dio`'s interceptors) — transient failures shouldn't surface as errors to the user.
- **Circuit breaker** around the media API: if it's down, stop hammering it, surface "catalog unavailable, playing downloaded tracks" and keep local playback fully functional.
- **Offline-first reads:** Home/Library screens always render from the local cache immediately, then silently refresh from the API — never a blank loading screen if cached data exists.
- **Graceful audio failure:** if a stream URL 404s mid-playback, auto-skip to next queued track with a toast, not a crash.

---

## 9. Testing strategy

| Layer | Test type | What it proves |
|---|---|---|
| Domain + use cases | Pure unit tests, no mocks needed beyond fake ports | Business logic is correct in isolation |
| Adapters | Unit tests with mocked package internals (e.g. mock `dio`) | Adapter correctly implements its port contract |
| Providers/state | Riverpod `ProviderContainer` tests | Wiring is correct |
| Widgets | `flutter_test` widget tests | Screens render correctly given a state |
| End-to-end | `integration_test` on a couple of critical flows (play a song, export/import) | The whole stack actually works together |

**Learning note:** because use cases only depend on interfaces, testing `PlayTrack` means injecting a `FakeMediaSourcePort` and a `FakePlaybackEnginePort` — no real network, no real audio engine, tests run in milliseconds. This is the single biggest practical payoff of the whole architecture.

---

## 10. Security & privacy

- No API keys or secrets committed to the repo — use `--dart-define` at build time or a gitignored config, and never log them.
- Exported bundles contain personal listening data — treat as sensitive; the export flow should warn the user before sharing it, since sharing means someone else can see their listening history.
- If the media API needs auth tokens, store them via `flutter_secure_storage` (Keychain/Keystore), never plain SharedPreferences.
- Validate all data coming back from the media API before it touches the domain (a corrupt/malicious API response should fail at the adapter boundary, not propagate).

---

## 11. Build & release readiness

- **CI:** run `flutter analyze` (with the custom import-direction lint from §4), `flutter test`, and build on every PR.
- **Code generation:** Drift and Riverpod both use `build_runner` — wire this into CI so generated code is never stale in a merged PR.
- **Crash/error reporting:** something like Sentry or Firebase Crashlytics, configured to scrub personal data before sending (consistent with the offline/privacy stance).
- **Versioned schema migrations:** every Drift schema change ships a migration step — untested migrations are the most common cause of "production" apps corrupting real users' data on update.

---

## 12. Open decisions before we start building

1. **Which media API** for the catalog — this determines the exact `MediaSourcePort` method signatures (does it return direct stream URLs, or require a signed-request flow?).
2. **Drift vs. Isar** for the local DB — recommendation is Drift, given relational data (playlists ↔ tracks) and the need for reliable export/import as portable SQLite files.
3. **How "download for offline" limits work** — storage cap? user-configurable?

Once these are settled, next step is UI/UX design applied on top of this architecture — translating your wireframes into a proper design system (typography, spacing, motion, the glassmorphic profile treatment) before any widget code is written.
