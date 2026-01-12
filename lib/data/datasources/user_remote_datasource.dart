import 'package:dio/dio.dart';
import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/data/models/user_model.dart';

/// User Remote Datasource
/// Handles user management API calls
abstract class UserRemoteDataSource {
  /// Get all users with pagination
  Future<PaginatedUsersResponse> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    required String token,
  });

  /// Get user by ID
  Future<UserModel> getUserById(String userId, String token);

  /// Get current user (users/me)
  Future<UserModel> getMe(String token);

  /// Update current user
  Future<UserModel> updateMe({
    required String token,
    String? firstName,
    String? lastName,
    String? email,
  });

  /// Update user by ID (Admin only)
  Future<UserModel> updateUser({
    required String userId,
    required String token,
    String? firstName,
    String? lastName,
    String? email,
    bool? isActive,
  });

  /// Delete user by ID (Admin only)
  Future<void> deleteUser(String userId, String token);

  /// Get user statistics
  Future<UserStatistics> getStatistics(String token);
}

/// Paginated users response
class PaginatedUsersResponse {
  final List<UserModel> items;
  final PaginationMeta meta;

  const PaginatedUsersResponse({
    required this.items,
    required this.meta,
  });

  factory PaginatedUsersResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedUsersResponse(
      items: (json['items'] as List)
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

/// User statistics
class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int newUsersThisMonth;
  final int newUsersToday;

  const UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.newUsersThisMonth,
    required this.newUsersToday,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['totalUsers'] as int,
      activeUsers: json['activeUsers'] as int,
      inactiveUsers: json['inactiveUsers'] as int,
      newUsersThisMonth: json['newUsersThisMonth'] as int,
      newUsersToday: json['newUsersToday'] as int,
    );
  }
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedUsersResponse> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? isActive,
    required String token,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      final response = await dio.get(
        ApiConstants.users,
        queryParameters: queryParams,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaginatedUsersResponse.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get users',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to get users';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getUserById(String userId, String token) async {
    try {
      final response = await dio.get(
        '${ApiConstants.users}/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to get user';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        } else if (statusCode == 404) {
          throw NotFoundException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getMe(String token) async {
    try {
      final response = await dio.get(
        ApiConstants.usersMe,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to get user';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateMe({
    required String token,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (email != null) data['email'] = email;

      final response = await dio.patch(
        ApiConstants.usersMe,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(responseData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to update user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to update user';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        } else if (statusCode == 400) {
          throw ValidationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateUser({
    required String userId,
    required String token,
    String? firstName,
    String? lastName,
    String? email,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (email != null) data['email'] = email;
      if (isActive != null) data['isActive'] = isActive;

      final response = await dio.patch(
        '${ApiConstants.users}/$userId',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(responseData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to update user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to update user';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        } else if (statusCode == 404) {
          throw NotFoundException(message: message);
        } else if (statusCode == 400) {
          throw ValidationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteUser(String userId, String token) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.users}/$userId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return;
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to delete user',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to delete user';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        } else if (statusCode == 404) {
          throw NotFoundException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserStatistics> getStatistics(String token) async {
    try {
      final response = await dio.get(
        ApiConstants.usersStatistics,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserStatistics.fromJson(data);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Failed to get statistics',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data['message'] ?? 'Failed to get statistics';

        if (statusCode == 401) {
          throw AuthenticationException(message: message);
        }
        
        throw ServerException(message: message);
      }
      
      throw NetworkException(
        message: 'Network error. Please check your connection.',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
