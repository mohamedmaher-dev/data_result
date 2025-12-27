# Data Result

A lightweight, type-safe alternative to Either/Result types for Dart and Flutter.

[![pub package](https://img.shields.io/pub/v/data_result.svg)](https://pub.dev/packages/data_result)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Installation

```yaml
dependencies:
  data_result: ^1.0.0
```

## Quick Start

Create your result type by extending `DataResult`:

```dart
import 'package:data_result/data_result.dart';

class ApiResult<T> extends DataResult<T, String> {
  ApiResult.success(super.data) : super.success();
  ApiResult.failure(super.error) : super.failure();
}
```

Use it in your functions:

```dart
Future<ApiResult<User>> fetchUser(int id) async {
  try {
    final response = await http.get(Uri.parse('api.example.com/users/$id'));
    if (response.statusCode == 200) {
      return ApiResult.success(User.fromJson(response.body));
    }
    return ApiResult.failure('HTTP ${response.statusCode}');
  } catch (e) {
    return ApiResult.failure('Network error: $e');
  }
}
```

Handle the result:

```dart
final result = await fetchUser(123);

result.when(
  success: (user) => print('User: $user'),
  error: (error) => print('Error: $error'),
);
```

## API

**Create Results:**

- `YourResult.success(data)` - Success result
- `YourResult.failure(error)` - Failure result

**Check Status:**

- `result.isSuccess` - Check if successful
- `result.data` - Get success data (or null)
- `result.failure` - Get failure data (or null)

**Handle Results:**

- `result.when(success: ..., error: ...)` - Handle both cases
- `result.whenOrNull(success: ..., failure: ...)` - Handle one case

## Examples

**Validation:**

```dart
class ValidationResult<T> extends DataResult<T, List<String>> {
  ValidationResult.success(super.data) : super.success();
  ValidationResult.failure(super.errors) : super.failure();
}

ValidationResult<String> validateEmail(String email) {
  final errors = <String>[];
  if (email.isEmpty) errors.add('Email required');
  if (!email.contains('@')) errors.add('Invalid email');

  return errors.isEmpty
    ? ValidationResult.success(email)
    : ValidationResult.failure(errors);
}
```

**Database:**

```dart
class DbResult<T> extends DataResult<T, String> {
  DbResult.success(super.data) : super.success();
  DbResult.failure(super.error) : super.failure();
}

DbResult<User> saveUser(User user) {
  try {
    database.insert(user);
    return DbResult.success(user);
  } catch (e) {
    return DbResult.failure('Save failed: $e');
  }
}
```

## Comparison with Either Packages

Packages like [dart_either](https://pub.dev/packages/dart_either), [dartz](https://pub.dev/packages/dartz), and [fpdart](https://pub.dev/packages/fpdart) are powerful functional programming libraries with advanced features. **data_result** takes a different approach focused on simplicity and clarity.

### When to Choose data_result

**data_result** is perfect when you want:

- Clear, self-documenting code with `success`/`failure` naming
- Minimal learning curve for your team
- Zero dependencies
- Simple error handling without FP complexity

```dart
// Clear naming - no memorization needed
class ApiResult<T> extends DataResult<T, String> {
  ApiResult.success(super.data) : super.success();
  ApiResult.failure(super.error) : super.failure();
}

ApiResult<User> result = ApiResult.success(user);
result.when(
  success: (user) => handleSuccess(user),  // Instantly clear
  error: (error) => handleError(error),
);
```

### When to Choose Either Packages

**Either packages** are great when you need:

- Advanced functional programming patterns (monad comprehensions, traverse, etc.)
- Rich API with 50+ methods for complex transformations
- Integration with FP ecosystems
- Team familiar with FP concepts like `Left`/`Right`

```dart
// Functional programming approach
Either<String, User> result = Either.right(user);
result.fold(
  ifLeft: (error) => handleError(error),
  ifRight: (user) => handleSuccess(user),
);
```

### Key Differences

| Feature          | dart_either/dartz/fpdart          | data_result             |
| ---------------- | --------------------------------- | ----------------------- |
| **Philosophy**   | Functional programming            | Pragmatic simplicity    |
| **Naming**       | `Left`/`Right`                    | `success`/`failure`     |
| **API**          | Comprehensive (50+ methods)       | Minimal (3 methods)     |
| **Dependencies** | Has dependencies                  | Zero dependencies       |
| **Use Case**     | Complex FP workflows              | Simple error handling   |
| **Best For**     | FP enthusiasts, advanced patterns | Everyone, readable code |

### The Bottom Line

Both approaches are valid:

- Choose **Either packages** if you're doing functional programming and need advanced features
- Choose **data_result** if you want clear, simple error handling that any developer can understand

**data_result** exists because not every project needs the complexity of full Either monads. Sometimes you just want clean, readable error handling.

## License

MIT License - see [LICENSE](LICENSE) file.
