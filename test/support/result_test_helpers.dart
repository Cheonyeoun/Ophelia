import 'package:test/test.dart';
import 'package:ophelia/core/error/result.dart';

/// Unwraps a [Result], failing the test with a clear message if [result]
/// is actually a [ResultFailure]. Shared by the use case tests so each
/// doesn't repeat the same switch pattern.
T unwrapValue<T, F>(Result<T, F> result) => switch (result) {
      Success(value: final v) => v,
      ResultFailure() => fail('expected a Success case, got a failure'),
    };

/// Unwraps a [Result]'s failure, failing the test with a clear message if
/// [result] is actually a [Success].
F unwrapFailure<T, F>(Result<T, F> result) => switch (result) {
      Success() => fail('expected a ResultFailure case, got a success'),
      ResultFailure(failure: final f) => f,
    };
