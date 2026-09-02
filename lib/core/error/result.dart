/// Either a successful [T] value or an [F] failure — returned by port and
/// use case methods instead of throwing exceptions across layers (see
/// docs/architecture.md §8). Pure Dart — no Flutter, no package imports.
///
/// Match on the concrete case with a switch pattern:
/// ```dart
/// switch (result) {
///   case Success(value: final v): ...
///   case ResultFailure(failure: final f): ...
/// }
/// ```
sealed class Result<T, F> {
  const Result();

  const factory Result.success(T value) = Success<T, F>;

  const factory Result.failure(F failure) = ResultFailure<T, F>;
}

class Success<T, F> extends Result<T, F> {
  final T value;

  const Success(this.value);
}

class ResultFailure<T, F> extends Result<T, F> {
  final F failure;

  const ResultFailure(this.failure);
}
