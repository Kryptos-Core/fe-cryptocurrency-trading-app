import 'package:dartz/dartz.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/datasources/notification_remote_datasource.dart';
import 'package:crypto_trading_app/domain/entities/notification_entity.dart';
import 'package:crypto_trading_app/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getNotifications(page: page, limit: limit);
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String notificationId) async {
    try {
      await remoteDataSource.markRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAllRead() async {
    try {
      await remoteDataSource.markAllRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      return const Left(NetworkFailure());
    }
  }
}
