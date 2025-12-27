// ignore_for_file: avoid_print

import 'package:data_result/data_result.dart';

/// Main entry point demonstrating various uses of DataResult.
void main() {
  print('=== Data Result Examples ===\n');

  // Basic Examples
  basicSuccessFailureExample();
  print('\n---\n');

  // Pattern Matching Examples
  whenExample();
  print('\n---\n');

  whenOrNullExample();
  print('\n---\n');

  // Real-World Examples
  apiCallExample();
  print('\n---\n');

  validationExample();
  print('\n---\n');

  databaseOperationExample();
  print('\n---\n');

  fileOperationExample();
}

// Define custom result types for different domains

/// A result type for API operations
class ApiResult<T> extends DataResult<T, String> {
  ApiResult.success(super.data) : super.success();
  ApiResult.failure(super.error) : super.failure();
}

/// A result type for validation operations
class ValidationResult<T> extends DataResult<T, List<String>> {
  ValidationResult.success(super.data) : super.success();
  ValidationResult.failure(super.errors) : super.failure();
}

/// A result type for database operations
class DbResult<T> extends DataResult<T, DatabaseError> {
  DbResult.success(super.data) : super.success();
  DbResult.failure(super.error) : super.failure();
}

/// A result type for file operations
class FileResult<T> extends DataResult<T, FileError> {
  FileResult.success(super.data) : super.success();
  FileResult.failure(super.error) : super.failure();
}

/// Demonstrates basic success and failure result creation.
void basicSuccessFailureExample() {
  print('1. Basic Success/Failure Example:');

  // Create a successful result
  final successResult = ApiResult<String>.success(
    'Operation completed successfully!',
  );

  // Create a failed result
  final failureResult = ApiResult<String>.failure('Something went wrong');

  // Check status
  print('Success result is successful: ${successResult.isSuccess}');
  print('Success result data: ${successResult.data}');

  print('Failure result is successful: ${failureResult.isSuccess}');
  print('Failure result error: ${failureResult.failure}');
}

/// Demonstrates the when method for pattern matching.
void whenExample() {
  print('2. Pattern Matching with when():');

  final results = [
    ApiResult<int>.success(42),
    ApiResult<int>.failure('Network error'),
  ];

  for (var result in results) {
    result.when(
      success: (final value) => print('  ✓ Success! Value: $value'),
      failure: (final error) => print('  ✗ Error! Message: $error'),
    );
  }
}

/// Demonstrates the whenOrNull method for optional pattern matching.
void whenOrNullExample() {
  print('3. Optional Pattern Matching with whenOrNull():');

  final result = ApiResult<String>.success('Hello, World!');

  // Only handle success
  print('  Handling only success:');
  result.whenOrNull(success: (final data) => print('    Got data: $data'));

  // Only handle failure (won't print anything)
  print('  Handling only failure (no output expected):');
  result.whenOrNull(failure: (final error) => print('    Got error: $error'));
}

/// Simulates an API call and demonstrates handling the result.
void apiCallExample() {
  print('4. API Call Example:');

  // Simulate successful API call
  final successfulCall = simulateApiCall(shouldFail: false);
  successfulCall.when(
    success: (final user) =>
        print('  User fetched: ${user.name} (${user.email})'),
    failure: (final error) => print('  API Error: $error'),
  );

  // Simulate failed API call
  final failedCall = simulateApiCall(shouldFail: true);
  failedCall.when(
    success: (final user) => print('  User fetched: ${user.name}'),
    failure: (final error) => print('  API Error: $error'),
  );
}

/// Demonstrates form validation with DataResult.
void validationExample() {
  print('5. Form Validation Example:');

  // Valid input
  final validResult = validateEmail('user@example.com');
  validResult.when(
    success: (final email) => print('  ✓ Valid email: $email'),
    failure: (final errors) =>
        print('  ✗ Validation errors: ${errors.join(", ")}'),
  );

  // Invalid input
  final invalidResult = validateEmail('invalid-email');
  invalidResult.when(
    success: (final email) => print('  ✓ Valid email: $email'),
    failure: (final errors) =>
        print('  ✗ Validation errors: ${errors.join(", ")}'),
  );

  // Empty input
  final emptyResult = validateEmail('');
  emptyResult.when(
    success: (final email) => print('  ✓ Valid email: $email'),
    failure: (final errors) =>
        print('  ✗ Validation errors: ${errors.join(", ")}'),
  );
}

/// Demonstrates database operation result handling.
void databaseOperationExample() {
  print('6. Database Operation Example:');

  final saveResult = simulateDatabaseSave(
    userId: 123,
    data: {'name': 'John Doe'},
  );
  saveResult.when(
    success: (final id) => print('  ✓ Record saved with ID: $id'),
    failure: (final error) => print('  ✗ Database error: ${error.message}'),
  );

  final loadResult = simulateDatabaseLoad(userId: 999);
  loadResult.when(
    success: (final data) => print('  ✓ Data loaded: $data'),
    failure: (final error) => print('  ✗ Database error: ${error.message}'),
  );
}

/// Demonstrates file operation result handling.
void fileOperationExample() {
  print('7. File Operation Example:');

  final readResult = simulateFileRead('config.json');
  readResult.whenOrNull(
    success: (final content) => print('  ✓ File content: $content'),
    failure: (final error) => print('  ✗ File error: ${error.name}'),
  );

  final missingFileResult = simulateFileRead('missing.txt');
  missingFileResult.whenOrNull(
    success: (final content) => print('  ✓ File content: $content'),
    failure: (final error) => print('  ✗ File error: ${error.name}'),
  );
}

// ============================================================================
// Helper Classes and Simulation Functions
// ============================================================================

/// Sample User class for API examples.
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

/// Simulates an API call that can succeed or fail.
ApiResult<User> simulateApiCall({required final bool shouldFail}) {
  if (shouldFail) {
    return ApiResult.failure('Network timeout: Unable to reach server');
  }
  return ApiResult.success(
    User(id: 1, name: 'John Doe', email: 'john@example.com'),
  );
}

/// Validates an email address.
ValidationResult<String> validateEmail(final String email) {
  final errors = <String>[];

  if (email.isEmpty) {
    errors.add('Email is required');
  } else if (!email.contains('@')) {
    errors.add('Email must contain @');
  } else if (!email.contains('.')) {
    errors.add('Email must contain a domain');
  }

  if (errors.isEmpty) {
    return ValidationResult.success(email);
  } else {
    return ValidationResult.failure(errors);
  }
}

/// Database error class for examples.
class DatabaseError {
  final String message;
  final int code;

  DatabaseError(this.message, this.code);
}

/// Simulates saving data to a database.
DbResult<int> simulateDatabaseSave({
  required final int userId,
  required final Map<String, dynamic> data,
})
// Simulate successful save
=> DbResult.success(userId);

/// Simulates loading data from a database.
DbResult<Map<String, dynamic>> simulateDatabaseLoad({
  required final int userId,
}) {
  // Simulate record not found
  if (userId == 999) {
    return DbResult.failure(DatabaseError('Record not found', 404));
  }
  return DbResult.success({'id': userId, 'name': 'John Doe'});
}

/// File error enum for examples.
enum FileError { notFound, permissionDenied, readError }

/// Simulates reading a file.
FileResult<String> simulateFileRead(final String path) {
  if (path == 'missing.txt') {
    return FileResult.failure(FileError.notFound);
  }
  return FileResult.success('{"setting": "value"}');
}
