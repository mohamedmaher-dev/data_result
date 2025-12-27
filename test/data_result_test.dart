import 'package:data_result/data_result.dart';
import 'package:test/test.dart';

// Define custom result types for testing
class TestResult<T> extends DataResult<T, String> {
  TestResult.success(super.data) : super.success();
  TestResult.failure(super.error) : super.failure();
}

class ApiResult<T> extends DataResult<T, String> {
  ApiResult.success(super.data) : super.success();
  ApiResult.failure(super.error) : super.failure();
}

class ValidationResult<T> extends DataResult<T, List<String>> {
  ValidationResult.success(super.data) : super.success();
  ValidationResult.failure(super.errors) : super.failure();
}

class DbResult<T> extends DataResult<T, DatabaseError> {
  DbResult.success(super.data) : super.success();
  DbResult.failure(super.error) : super.failure();
}

void main() {
  group('DataResult', () {
    group('Success', () {
      test('creates a successful result with data', () {
        final result = TestResult<String>.success('test data');

        expect(result.data, equals('test data'));
        expect(result.failure, isNull);
        expect(result.isSuccess, isTrue);
      });

      test('creates a successful result with null data', () {
        final result = TestResult<String?>.success(null);

        expect(result.data, isNull);
        expect(result.failure, isNull);
        expect(result.isSuccess, isTrue);
      });

      test('creates a successful result with different types', () {
        final intResult = TestResult<int>.success(42);
        expect(intResult.data, equals(42));
        expect(intResult.isSuccess, isTrue);

        final listResult = TestResult<List<int>>.success([1, 2, 3]);
        expect(listResult.data, equals([1, 2, 3]));
        expect(listResult.isSuccess, isTrue);

        final mapResult = TestResult<Map<String, int>>.success({'key': 100});
        expect(mapResult.data, equals({'key': 100}));
        expect(mapResult.isSuccess, isTrue);
      });
    });

    group('Failure', () {
      test('creates a failed result with failure data', () {
        final result = TestResult<String>.failure('test error');

        expect(result.data, isNull);
        expect(result.failure, equals('test error'));
        expect(result.isSuccess, isFalse);
      });

      test('creates a failed result with string error', () {
        final result = TestResult<int>.failure('error message');

        expect(result.data, isNull);
        expect(result.failure, equals('error message'));
        expect(result.isSuccess, isFalse);
      });

      test('creates a failed result with custom error type', () {
        final error = DatabaseError('test error');
        final result = DbResult<String>.failure(error);

        expect(result.data, isNull);
        expect(result.failure, equals(error));
        expect(result.isSuccess, isFalse);
      });
    });

    group('isSuccess', () {
      test('returns true for successful result', () {
        final result = TestResult<String>.success('data');
        expect(result.isSuccess, isTrue);
      });

      test('returns false for failed result', () {
        final result = TestResult<String>.failure('error');
        expect(result.isSuccess, isFalse);
      });
    });

    group('when', () {
      test('calls success callback for successful result', () {
        final result = TestResult<String>.success('test data');
        String? capturedData;
        String? capturedError;

        result.when(
          success: (final data) => capturedData = data,
          failure: (final error) => capturedError = error,
        );

        expect(capturedData, equals('test data'));
        expect(capturedError, isNull);
      });

      test('calls failure callback for failed result', () {
        final result = TestResult<String>.failure('test error');
        String? capturedData;
        String? capturedError;

        result.when(
          success: (final data) => capturedData = data,
          failure: (final error) => capturedError = error,
        );

        expect(capturedData, isNull);
        expect(capturedError, equals('test error'));
      });

      test('executes side effects in callbacks', () {
        final result = TestResult<int>.success(42);
        var sideEffectValue = 0;

        result.when(
          success: (final data) => sideEffectValue = data * 2,
          failure: (final error) => sideEffectValue = -1,
        );

        expect(sideEffectValue, equals(84));
      });

      test('handles complex types in callbacks', () {
        final result = TestResult<List<int>>.success([1, 2, 3]);
        List<int>? capturedList;

        result.when(
          success: (final data) => capturedList = data,
          failure: (final error) => {},
        );

        expect(capturedList, equals([1, 2, 3]));
      });
    });

    group('whenOrNull', () {
      test(
        'calls only success callback when provided for successful result',
        () {
          final result = TestResult<String>.success('test data');
          String? capturedData;
          String? capturedError;

          result.whenOrNull(success: (final data) => capturedData = data);

          expect(capturedData, equals('test data'));
          expect(capturedError, isNull);
        },
      );

      test('calls only failure callback when provided for failed result', () {
        final result = TestResult<String>.failure('test error');
        String? capturedData;
        String? capturedError;

        result.whenOrNull(failure: (final error) => capturedError = error);

        expect(capturedData, isNull);
        expect(capturedError, equals('test error'));
      });

      test('does not call failure callback for successful result', () {
        final result = TestResult<String>.success('test data');
        var failureCallbackCalled = false;

        result.whenOrNull(
          failure: (final error) => failureCallbackCalled = true,
        );

        expect(failureCallbackCalled, isFalse);
      });

      test('does not call success callback for failed result', () {
        final result = TestResult<String>.failure('error');
        var successCallbackCalled = false;

        result.whenOrNull(
          success: (final data) => successCallbackCalled = true,
        );

        expect(successCallbackCalled, isFalse);
      });

      test('handles both callbacks being null', () {
        final result = TestResult<String>.success('test data');

        // Should not throw
        expect(() => result.whenOrNull(), returnsNormally);
      });

      test('calls both callbacks when both provided for successful result', () {
        final result = TestResult<String>.success('test data');
        String? capturedData;
        String? capturedError;

        result.whenOrNull(
          success: (final data) => capturedData = data,
          failure: (final error) => capturedError = error,
        );

        expect(capturedData, equals('test data'));
        expect(capturedError, isNull);
      });

      test('calls both callbacks when both provided for failed result', () {
        final result = TestResult<String>.failure('test error');
        String? capturedData;
        String? capturedError;

        result.whenOrNull(
          success: (final data) => capturedData = data,
          failure: (final error) => capturedError = error,
        );

        expect(capturedData, isNull);
        expect(capturedError, equals('test error'));
      });
    });

    group('Real-world scenarios', () {
      test('handles API response simulation', () {
        final successResponse = simulateApiCall(shouldFail: false);
        final failureResponse = simulateApiCall(shouldFail: true);

        User? user;
        String? error;

        successResponse.when(
          success: (final u) => user = u,
          failure: (final e) => error = e,
        );

        expect(user, isNotNull);
        expect(user!.name, equals('John Doe'));
        expect(error, isNull);

        user = null;
        error = null;

        failureResponse.when(
          success: (final u) => user = u,
          failure: (final e) => error = e,
        );

        expect(user, isNull);
        expect(error, equals('Network error'));
      });

      test('handles form validation', () {
        final validEmail = validateEmail('user@example.com');
        final invalidEmail = validateEmail('invalid');

        validEmail.when(
          success: (final email) => expect(email, equals('user@example.com')),
          failure: (final errors) => fail('Should not have errors'),
        );

        invalidEmail.when(
          success: (final email) => fail('Should not be valid'),
          failure: (final errors) => expect(errors, isNotEmpty),
        );
      });

      test('handles database operations', () {
        final saveResult = saveToDatabaseSimulation(123);
        final loadResult = loadFromDatabaseSimulation(999);

        saveResult.when(
          success: (final id) => expect(id, equals(123)),
          failure: (final error) => fail('Save should succeed'),
        );

        loadResult.when(
          success: (final data) => fail('Load should fail'),
          failure: (final error) =>
              expect(error.message, contains('not found')),
        );
      });
    });

    group('Type safety', () {
      test('maintains type safety with different generic types', () {
        final TestResult<int> intResult = TestResult.success(42);
        final TestResult<String> stringResult = TestResult.failure('404');
        final TestResult<List<int>> complexResult = TestResult.success([1, 2]);

        expect(intResult.data, isA<int>());
        expect(stringResult.failure, isA<String>());
        expect(complexResult.data, isA<List<int>>());
      });

      test('custom result types maintain type safety', () {
        final apiResult = ApiResult<String>.success('data');
        final validationResult = ValidationResult<String>.failure([
          'error1',
          'error2',
        ]);
        final dbResult = DbResult<int>.success(42);

        expect(apiResult.data, isA<String>());
        expect(validationResult.failure, isA<List<String>>());
        expect(dbResult.data, isA<int>());
      });
    });
  });
}

// Helper classes and functions for tests

class User {
  final String name;
  final String email;

  User(this.name, this.email);
}

ApiResult<User> simulateApiCall({required final bool shouldFail}) {
  if (shouldFail) {
    return ApiResult.failure('Network error');
  }
  return ApiResult.success(User('John Doe', 'john@example.com'));
}

ValidationResult<String> validateEmail(final String email) {
  final errors = <String>[];

  if (!email.contains('@')) errors.add('Missing @');
  if (!email.contains('.')) errors.add('Missing domain');

  return errors.isEmpty
      ? ValidationResult.success(email)
      : ValidationResult.failure(errors);
}

class DatabaseError {
  final String message;
  DatabaseError(this.message);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is DatabaseError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

DbResult<int> saveToDatabaseSimulation(final int id) => DbResult.success(id);

DbResult<Map<String, dynamic>> loadFromDatabaseSimulation(final int id) {
  if (id == 999) {
    return DbResult.failure(DatabaseError('Record not found'));
  }
  return DbResult.success({'id': id});
}
