import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Following Interface Segregation Principle (ISP)
/// Each use case has a single responsibility and clear contract
abstract class UseCase<Type, Params> {
  /// Execute the use case
  /// Returns Either<Failure, Type> for functional error handling
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters use case
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
