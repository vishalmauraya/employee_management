import 'package:flutter/foundation.dart';

import '../../core/utils/api_exception.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._taskRepository);

  final TaskRepository _taskRepository;

  List<TaskModel> tasks = [];
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String? statusFilter;

  Future<void> loadTasks({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      tasks = await _taskRepository.getTasks(
        search: searchQuery.isEmpty ? null : searchQuery,
        status: statusFilter,
      );
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'Failed to load tasks';
    }

    isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    loadTasks();
  }

  void setStatusFilter(String? status) {
    statusFilter = status;
    loadTasks();
  }

  Future<TaskModel?> getTask(int id) async {
    try {
      return await _taskRepository.getTask(id);
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> saveTask(TaskModel task, {int? taskId}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (taskId == null) {
        await _taskRepository.createTask(task);
      } else {
        await _taskRepository.updateTask(taskId, task);
      }
      await loadTasks(showLoading: false);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await _taskRepository.deleteTask(id);
      await loadTasks(showLoading: false);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    tasks = [];
    searchQuery = '';
    statusFilter = null;
    errorMessage = null;
    notifyListeners();
  }
}
