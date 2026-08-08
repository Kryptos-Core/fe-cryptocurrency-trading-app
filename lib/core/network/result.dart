/// Result<T> — sealed Success/Failure instead of throwing.
///
/// Repositories return `Result<T>`; UI layer pattern-matches on success/failure.
/// This enforces explicit error handling at every layer without try/catch spam.
library;

import 'package:equatable/equatable.dart';

import '../error/app_error.dart';

sealed class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Returns the value or throws an [AppError] (use only when failure is impossible).
  T unwrap() {
    final self = this;
    if (self is Success<T>) return self.value;
    if (self is Failure<T>) throw self.error;
    throw StateError('Unreachable');
  }

  /// Returns the value or null on failure.
  T? get valueOrNull {
    final self = this;
    return self is Success<T> ? self.value : null;
  }

  /// Returns the error or null on success.
  AppError? get errorOrNull {
    final self = this;
    return self is Failure<T> ? self.error : null;
  }

  /// Fold over the result.
  R fold<R>({required R Function(T value) onSuccess, required R Function(AppError error) onFailure}) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.value);
    if (self is Failure<T>) return onFailure(self.error);
    throw StateError('Unreachable');
  }

  /// Map success value to a new type.
  Result<R> map<R>(R Function(T value) transform) {
    final self = this;
    if (self is Success<T>) return Success<R>(transform(self.value));
    if (self is Failure<T>) return Failure<R>(self.error);
    throw StateError('Unreachable');
  }

  @override
  List<Object?> get props => [];
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  List<Object?> get props => [value];
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  List<Object?> get props => [error];
}
