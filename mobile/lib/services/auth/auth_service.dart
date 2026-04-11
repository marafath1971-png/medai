import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user.dart';
import '../api/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await _saveTokens(data);
        _currentUser = User.fromJson(data['data']['user']);
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Registration failed',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('LOGIN: Calling ${ApiConstants.baseUrl}${ApiConstants.login}');
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      print('LOGIN Response: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await _saveTokens(data);
        _currentUser = User.fromJson(data['data']['user']);
        return {'success': true, 'message': 'Login successful'};
      }
      return {'success': false, 'message': data['message'] ?? 'Login failed'};
    } on DioException catch (e) {
      print('LOGIN Error Type: ${e.type}');
      print('LOGIN Error Message: ${e.message}');
      print('LOGIN Error Response: ${e.response?.data}');

      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Cannot connect to server. Make sure backend is running.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password';
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'Email already registered';
      } else {
        errorMessage = e.message ?? 'Login failed';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('LOGIN Unexpected Error: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginGoogle,
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await _saveTokens(data);
        _currentUser = User.fromJson(data['data']['user']);
        return {'success': true, 'message': 'Google login successful'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Google login failed',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> loginWithApple(String idToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.loginApple,
        data: {'idToken': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        await _saveTokens(data);
        _currentUser = User.fromJson(data['data']['user']);
        return {'success': true, 'message': 'Apple login successful'};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Apple login failed',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );

      final data = response.data as Map<String, dynamic>;
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Password reset email sent',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      final data = response.data as Map<String, dynamic>;
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Password reset successful',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyEmail,
        data: {'token': token},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _currentUser = _currentUser?.copyWith(emailVerified: true);
      }
      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Email verified',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> enable2FA() async {
    try {
      final response = await _apiClient.post(ApiConstants.enable2fa);

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final secret = data['data']['secret'] as String;
        final qrCodeUrl = data['data']['qrCodeUrl'] as String;
        return {'success': true, 'secret': secret, 'qrCodeUrl': qrCodeUrl};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to enable 2FA',
      };
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> verify2FA(String code) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.verify2fa,
        data: {'code': code},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _currentUser = _currentUser?.copyWith(twoFactorEnabled: true);
      }
      return {'success': data['success'] == true, 'message': data['message']};
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<Map<String, dynamic>> disable2FA(String code) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.disable2fa,
        data: {'code': code},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _currentUser = _currentUser?.copyWith(twoFactorEnabled: false);
      }
      return {'success': data['success'] == true, 'message': data['message']};
    } on DioException catch (e) {
      final error = ApiException.fromDioError(e);
      return {'success': false, 'message': error.message};
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      if (kDebugMode) print('Logout API error: $e');
    }
    await _clearTokens();
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    if (accessToken == null) return null;

    _apiClient.setTokens(accessToken: accessToken);

    try {
      final response = await _apiClient.get(ApiConstants.me);
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        _currentUser = User.fromJson(data['data']);
        return _currentUser;
      }
    } catch (e) {
      await _clearTokens();
    }
    return null;
  }

  Future<bool> tryAutoLogin() async {
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);

    if (accessToken == null || refreshToken == null) return false;

    _apiClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);

    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['data']?['accessToken'] as String?;
    final refreshToken = data['data']?['refreshToken'] as String?;

    if (accessToken != null) {
      await _storage.write(
        key: AppConstants.accessTokenKey,
        value: accessToken,
      );
    }
    if (refreshToken != null) {
      await _storage.write(
        key: AppConstants.refreshTokenKey,
        value: refreshToken,
      );
    }

    _apiClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    _apiClient.clearTokens();
  }
}
