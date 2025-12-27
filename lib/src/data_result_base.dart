/// An abstract class representing the result of an operation that can either
/// succeed with data of type [S] or fail with an error of type [F].
///
/// This class provides a type-safe way to handle success and failure cases
/// without using exceptions, following functional programming patterns like
/// Result/Either types from other languages.
///
/// Users should extend this class to create their own result types:
///
/// ## Usage
///
/// ```dart
/// // Define your custom result type by extending DataResult
/// class ApiResult<T> extends DataResult<T, String> {
///   ApiResult.success(super.data) : super.success();
///   ApiResult.failure(super.failure) : super.failure();
/// }
///
/// // Use your custom result type
/// ApiResult<User> fetchUser() {
///   try {
///     final user = api.getUser();
///     return ApiResult.success(user);
///   } catch (e) {
///     return ApiResult.failure('Failed to fetch user: $e');
///   }
/// }
///
/// // Handle the result
/// final result = fetchUser();
/// result.when(
///   success: (user) => print('User: ${user.name}'),
///   failure: (error) => print('Error: $error'),
/// );
/// ```
///
/// ## Type Parameters
///
/// * [S] - The type of data contained in a successful result
/// * [F] - The type of failure/error information in a failed result
abstract class DataResult<S, F> {
  /// The success data if this result is successful, null otherwise.
  ///
  /// Use [isSuccess] to check if this value is available before accessing it,
  /// or use the [when] or [whenOrNull] methods for safe access.
  final S? data;

  /// The failure data if this result is failed, null otherwise.
  ///
  /// Use [isSuccess] to check if this is a failure case before accessing it,
  /// or use the [when] or [whenOrNull] methods for safe access.
  final F? failure;

  /// Creates a successful result containing the given [data].
  ///
  /// Example:
  /// ```dart
  /// final result = DataResult<int, String>.success(42);
  /// print(result.isSuccess); // true
  /// print(result.data); // 42
  /// ```
  const DataResult.success(this.data) : failure = null;

  /// Creates a failed result containing the given [failure].
  ///
  /// Example:
  /// ```dart
  /// final result = DataResult<int, String>.failure('Something went wrong');
  /// print(result.isSuccess); // false
  /// print(result.failure); // 'Something went wrong'
  /// ```
  const DataResult.failure(this.failure) : data = null;

  /// Returns `true` if this result represents a successful operation.
  ///
  /// When `true`, the [data] property contains the success value.
  /// When `false`, the [failure] property contains the error information.
  ///
  /// Example:
  /// ```dart
  /// final result = DataResult<String, Exception>.success('Hello');
  /// if (result.isSuccess) {
  ///   print('Data: ${result.data}');
  /// } else {
  ///   print('Error: ${result.failure}');
  /// }
  /// ```
  bool get isSuccess => failure == null;

  /// Executes one of the provided callbacks based on whether this result
  /// is successful or failed.
  ///
  /// This method requires handling both success and failure cases, ensuring
  /// that all possible outcomes are properly handled.
  ///
  /// * [success] - Called with the success data if this is a successful result
  /// * [failure] - Called with the failure data if this is a failed result
  ///
  /// Example:
  /// ```dart
  /// final result = fetchUserData();
  ///
  /// result.when(
  ///   success: (user) {
  ///     print('User: ${user.name}');
  ///     updateUI(user);
  ///   },
  ///   error: (error) {
  ///     print('Failed: $error');
  ///     showErrorDialog(error);
  ///   },
  /// );
  /// ```
  void when({
    required final void Function(S data) success,
    required final void Function(F failure) failure,
  }) => isSuccess ? success(data as S) : failure(failure as F);

  /// Optionally executes callbacks based on whether this result is successful
  /// or failed.
  ///
  /// Unlike [when], this method allows you to handle only the cases you're
  /// interested in. If a callback is not provided, it simply won't be called.
  ///
  /// This is useful when you only need to handle one case, such as only
  /// showing errors or only processing successful results.
  ///
  /// * [success] - Optional callback called with the success data
  /// * [failure] - Optional callback called with the failure data
  ///
  /// Example:
  /// ```dart
  /// final result = loadConfiguration();
  ///
  /// // Only handle success case
  /// result.whenOrNull(
  ///   success: (config) {
  ///     applyConfiguration(config);
  ///   },
  /// );
  ///
  /// // Only handle failure case
  /// result.whenOrNull(
  ///   failure: (error) {
  ///     logError(error);
  ///   },
  /// );
  /// ```
  void whenOrNull({
    final void Function(S data)? success,
    final void Function(F failure)? failure,
  }) => isSuccess ? success?.call(data as S) : failure?.call(failure as F);
}
