import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return _parseAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<UserModel> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return _parseAuthResponse(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> logout() => _apiClient.clearToken();

  Future<bool> hasToken() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _apiClient.clearToken();
        return null;
      }
      throw _apiClient.handleError(e);
    }
  }

  Future<UserModel> _parseAuthResponse(Map<String, dynamic> data) async {
    final token = data['access_token'] as String;
    await _apiClient.saveToken(token);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
