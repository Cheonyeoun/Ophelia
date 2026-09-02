import 'package:test/test.dart';
import 'package:ophelia/core/error/failure.dart';

void main() {
  test('each failure type constructs with a default message', () {
    expect(const NetworkFailure().message, 'Network error');
    expect(const NotFoundFailure().message, 'Not found');
    expect(const StorageFailure().message, 'Storage error');
    expect(const DecodeFailure().message, 'Decode error');
  });

  test('each failure type accepts a custom message', () {
    expect(const NetworkFailure('timed out').message, 'timed out');
    expect(const NotFoundFailure('no such track').message, 'no such track');
    expect(const StorageFailure('disk full').message, 'disk full');
    expect(const DecodeFailure('bad json').message, 'bad json');
  });

  test('two instances of the same failure type with the same message are '
      'equal', () {
    expect(const NetworkFailure('x'), equals(const NetworkFailure('x')));
    expect(
      const NetworkFailure('x').hashCode,
      equals(const NetworkFailure('x').hashCode),
    );
  });

  test('different failure types with the same message are not equal', () {
    expect(
      const NetworkFailure('x'),
      isNot(equals(const StorageFailure('x'))),
    );
  });

  test('pattern matching distinguishes each failure case', () {
    String describe(Failure failure) => switch (failure) {
          NetworkFailure() => 'network',
          NotFoundFailure() => 'not_found',
          StorageFailure() => 'storage',
          DecodeFailure() => 'decode',
        };

    expect(describe(const NetworkFailure()), 'network');
    expect(describe(const NotFoundFailure()), 'not_found');
    expect(describe(const StorageFailure()), 'storage');
    expect(describe(const DecodeFailure()), 'decode');
  });
}
