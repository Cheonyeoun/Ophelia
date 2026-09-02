import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';
import 'package:ophelia/core/error/result.dart';

void main() {
  test('Result.success constructs a Success wrapping the value', () {
    const result = Result<int, Failure>.success(42);

    expect(result, isA<Success<int, Failure>>());
  });

  test('Result.failure constructs a ResultFailure wrapping the failure', () {
    const result = Result<int, Failure>.failure(NotFoundFailure());

    expect(result, isA<ResultFailure<int, Failure>>());
  });

  test('pattern matching extracts the value from a success case', () {
    const result = Result<int, Failure>.success(42);

    final matched = switch (result) {
      Success(value: final v) => v,
      ResultFailure() => fail('expected a Success case'),
    };

    expect(matched, 42);
  });

  test('pattern matching extracts the failure from a failure case', () {
    const result = Result<int, Failure>.failure(NotFoundFailure('missing'));

    final matched = switch (result) {
      Success() => fail('expected a ResultFailure case'),
      ResultFailure(failure: final f) => f,
    };

    expect(matched, isA<NotFoundFailure>());
    expect(matched.message, 'missing');
  });
}
