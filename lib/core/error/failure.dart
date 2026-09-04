/// Base type for domain-level failures returned by ports and use cases
/// instead of exceptions crossing layers (see docs/architecture.md §8).
/// Pure Dart — no Flutter, no package imports.
sealed class Failure {
  final String message;

  const Failure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// A network call failed (timeout, no connection, non-2xx response, ...).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

/// The requested resource does not exist.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// Reading from or writing to local storage failed.
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error']);
}

/// Data could not be decoded/parsed into a domain type.
class DecodeFailure extends Failure {
  const DecodeFailure([super.message = 'Decode error']);
}

/// An operation failed, and an attempt to roll the system back to its
/// prior state *because* of that failure also failed — so beyond the
/// original problem, whatever was being rolled back (e.g.
/// `PlaybackEnginePort`'s navigation state — see
/// `core/usecases/play_track.dart`) may no longer match what it was
/// before the attempt. Distinct from a plain failure so a caller can tell
/// "the operation didn't happen" apart from "the operation didn't happen
/// AND the attempted cleanup didn't either."
class EngineInconsistentFailure extends Failure {
  final Failure cause;
  final Failure rollbackFailure;

  EngineInconsistentFailure(this.cause, this.rollbackFailure)
      : super(
          '${cause.message}; additionally, rolling back failed: '
          '${rollbackFailure.message}',
        );
}
