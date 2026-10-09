/// Minimal, dependency free `Result` used across the whole code base.
///
/// Clean Architecture forbids the domain layer from leaking exceptions to the
/// presentation layer, so every repository method returns a [Result] that is
/// either a [Success] holding the value or a [ResultFailure] wrapping a
/// `Failure` object carrying a user friendly message.
///
/// The type is intentionally tiny: [map], [flatMap], [fold] and
/// [valueOrNull] are the only combinators the use cases and cubits need.
library;

/// Sealed result type: `Result<T>` is either [Success] or [ResultFailure].
sealed class Result<T> {
  const Result();

  /// Transforms a successful value, leaving a failure untouched.
  Result<R> map<R>(R Function(T value) transform) {
    final Result<T> self = this;
    if (self is Success<T>) {
      return Success<R>(transform(self.value));
    }
    return ResultFailure<R>(self.failureOrNull!);
  }

  /// Chains another asynchronous [Result] producing operation.
  Future<Result<R>> flatMap<R>(Future<Result<R>> Function(T value) transform) {
    final Result<T> self = this;
    if (self is Success<T>) {
      return transform(self.value);
    }
    return Future<Result<R>>.value(ResultFailure<R>(self.failureOrNull!));
  }

  /// Folds the result into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object failure) onFailure,
  }) {
    final Result<T> self = this;
    if (self is Success<T>) {
      return onSuccess(self.value);
    }
    return onFailure(self.failureOrNull!);
  }

  /// The wrapped value, or `null` when this result is a failure.
  T? get valueOrNull {
    final Result<T> self = this;
    return self is Success<T> ? self.value : null;
  }

  /// The wrapped failure, or `null` when this result is a success.
  Object? get failureOrNull {
    final Result<T> self = this;
    return self is ResultFailure<T> ? self.failure : null;
  }

  /// `true` when this result holds a value.
  bool get isSuccess => this is Success<T>;
}

/// Successful branch of [Result].
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Success<T> && value == other.value;

  @override
  int get hashCode => Object.hash(Success, value);

  @override
  String toString() => 'Success($value)';
}

/// Failing branch of [Result].
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  /// Usually one of the `Failure` subclasses from `core/errors/failures.dart`.
  final Object failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> && failure == other.failure;

  @override
  int get hashCode => Object.hash(ResultFailure, failure);

  @override
  String toString() => 'ResultFailure($failure)';
}
