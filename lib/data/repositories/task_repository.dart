import 'package:dio/dio.dart';

import '../models/task_model.dart';
import '../services/api_client.dart';

class TaskRepository {
  TaskRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TaskModel>> getTasks({String? search, String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        '/tasks',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final list = response.data as List<dynamic>;
      return list.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<TaskModel> getTask(int id) async {
    try {
      final response = await _apiClient.dio.get('/tasks/$id');
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _apiClient.dio.post('/tasks', data: task.toJson());
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<TaskModel> updateTask(int id, TaskModel task) async {
    try {
      final response = await _apiClient.dio.put('/tasks/$id', data: task.toJson());
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _apiClient.dio.delete('/tasks/$id');
    } on DioException catch (e) {
      throw _apiClient.handleError(e);
    }
  }
}
