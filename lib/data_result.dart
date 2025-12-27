/// A lightweight, type-safe result type for Dart that elegantly handles
/// success and failure states without exceptions.
///
/// This library provides the [DataResult] class, which represents operations
/// that can either succeed with data or fail with an error. It's inspired by
/// Result/Either types from functional programming languages and provides a
/// clean alternative to exception-based error handling.
///
/// ## Features
///
/// - Type-safe success and failure handling
/// - Pattern matching with `when` and `whenOrNull` methods
/// - Zero dependencies
/// - Lightweight implementation
/// - Sealed class for exhaustive pattern matching
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:data_result/data_result.dart';
///
/// // Define your custom result type
/// class MyResult<T> extends DataResult<T, String> {
///   MyResult.success(super.data) : super.success();
///   MyResult.failure(super.failure) : super.failure();
/// }
///
/// // Use your result type
/// final success = MyResult.success('Data loaded');
/// final failure = MyResult.failure('Something went wrong');
///
/// // Handle results
/// success.when(
///   success: (data) => print('Success: $data'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```
///
/// ## Advanced Usage
///
/// ```dart
/// // Define a specialized result type for API calls
/// class ApiResult<T> extends DataResult<T, ApiError> {
///   ApiResult.success(super.data) : super.success();
///   ApiResult.failure(super.failure) : super.failure();
/// }
///
/// Future<ApiResult<User>> fetchUser(int id) async {
///   try {
///     final response = await api.getUser(id);
///     return ApiResult.success(response);
///   } catch (e) {
///     return ApiResult.failure(ApiError('Failed to fetch user: $e'));
///   }
/// }
///
/// void loadUser() async {
///   final result = await fetchUser(123);
///
///   result.when(
///     success: (user) => displayUser(user),
///     failure: (error) => showError(error.message),
///   );
/// }
/// ```
library;

export 'src/data_result_base.dart';
