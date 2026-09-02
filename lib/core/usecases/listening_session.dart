import '../domain/listening_event.dart';

/// Tracks when the currently-playing track started, so `PlayTrack`,
/// `PauseTrack`, `SkipNext`, and `SkipPrevious` can record its actual
/// elapsed listening time instead of a placeholder. One instance is
/// shared between those use cases (constructor injection) for the life
/// of a playback session.
class ListeningSession {
  final DateTime Function() now;
  String? _trackId;
  DateTime? _startedAt;

  ListeningSession({this.now = DateTime.now});

  /// Begins tracking [trackId] as the track now playing.
  void start(String trackId) {
    _trackId = trackId;
    _startedAt = now();
  }

  /// Stops tracking and returns a [ListeningEvent] with the actual
  /// elapsed time for the track that was playing — or `null` if nothing
  /// was being tracked (e.g. before the first track of a session, or
  /// after a previous call to [finish]).
  ListeningEvent? finish() {
    final trackId = _trackId;
    final startedAt = _startedAt;
    if (trackId == null || startedAt == null) return null;
    _trackId = null;
    _startedAt = null;
    return ListeningEvent(
      trackId: trackId,
      playedAt: startedAt,
      msPlayed: now().difference(startedAt).inMilliseconds,
    );
  }
}
