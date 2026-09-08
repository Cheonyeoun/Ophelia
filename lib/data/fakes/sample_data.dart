import '../../core/domain/download_record.dart';
import '../../core/domain/listening_event.dart';
import '../../core/domain/playlist.dart';
import '../../core/domain/track.dart';
import '../../core/domain/user_profile.dart';

/// Sample data shared by every fake in lib/data/fakes/, matching the
/// visual mockups under docs/design/ so the app has believable content to
/// run against during UI development.
///
/// **Temporary, UI-development-only data — not production content.**

const sampleTracks = <Track>[
  Track(
    id: 't1',
    title: 'Marble & Ash',
    artist: 'Wren Callahan',
    album: 'Salt Air',
    durationMs: 214000,
    coverArtPath: '/covers/salt_air.jpg',
    sourceType: TrackSourceType.downloaded,
  ),
  Track(
    id: 't2',
    title: 'Salt Air',
    artist: 'Wren Callahan',
    album: 'Salt Air',
    durationMs: 198000,
    coverArtPath: '/covers/salt_air.jpg',
    sourceType: TrackSourceType.downloaded,
  ),
  Track(
    id: 't3',
    title: 'Low Tide',
    artist: 'Ossian Vale',
    album: 'Amber Light',
    durationMs: 231000,
    coverArtPath: '/covers/amber_light.jpg',
    sourceType: TrackSourceType.downloaded,
  ),
  Track(
    id: 't4',
    title: 'Amber Light',
    artist: 'Ossian Vale',
    album: 'Amber Light',
    durationMs: 245000,
    coverArtPath: '/covers/amber_light.jpg',
    sourceType: TrackSourceType.streamed,
  ),
  Track(
    id: 't5',
    title: 'Quiet Rooms',
    artist: 'Marta Solis',
    album: 'Quiet Rooms',
    durationMs: 207000,
    coverArtPath: '/covers/quiet_rooms.jpg',
    sourceType: TrackSourceType.downloaded,
  ),
];

final samplePlaylists = <Playlist>[
  Playlist(id: 'p1', name: 'Night drift', trackIds: ['t3', 't1', 't5']),
  Playlist(id: 'p2', name: 'Slow burn', trackIds: ['t2', 't4']),
];

const sampleUserProfile = UserProfile(
  displayName: 'Maren Iyer',
  backgroundImagePath: '/images/profile_bg.jpg',
  profileImagePath: '/images/maren_iyer.jpg',
);

final sampleDownloadRecords = <DownloadRecord>[
  DownloadRecord(
    trackId: 't1',
    localPath: '/downloads/t1.mp3',
    sizeBytes: 8400000,
    downloadedAt: DateTime(2026, 8, 20),
  ),
  DownloadRecord(
    trackId: 't2',
    localPath: '/downloads/t2.mp3',
    sizeBytes: 9200000,
    downloadedAt: DateTime(2026, 8, 21),
  ),
  DownloadRecord(
    trackId: 't3',
    localPath: '/downloads/t3.mp3',
    sizeBytes: 7100000,
    downloadedAt: DateTime(2026, 8, 22),
  ),
  DownloadRecord(
    trackId: 't5',
    localPath: '/downloads/t5.mp3',
    sizeBytes: 6900000,
    downloadedAt: DateTime(2026, 8, 23),
  ),
];

/// Listening history over the past week, roughly matching the profile
/// mockup's "Marble & Ash · 14 plays" most-heard highlight and its "Top 5
/// songs" ordering — plus one deliberately stale event (>7 days old) so
/// window filtering has something to exclude.
List<ListeningEvent> buildSampleListeningEvents() {
  final reference = DateTime.now();
  DateTime daysAgo(int days) => reference.subtract(Duration(days: days));

  final events = <ListeningEvent>[];
  void addPlays(String trackId, int count) {
    for (var i = 0; i < count; i++) {
      events.add(
        ListeningEvent(
          trackId: trackId,
          playedAt: daysAgo(i % 7),
          msPlayed: sampleTracks
              .firstWhere((track) => track.id == trackId)
              .durationMs,
        ),
      );
    }
  }

  addPlays('t1', 14); // Marble & Ash — most heard this week
  addPlays('t5', 9); // Quiet Rooms
  addPlays('t2', 6); // Salt Air
  addPlays('t4', 3); // Amber Light
  addPlays('t3', 1); // Low Tide

  // Stale event outside the usual 7-day window.
  events.add(
    ListeningEvent(trackId: 't3', playedAt: daysAgo(10), msPlayed: 231000),
  );

  return events;
}
