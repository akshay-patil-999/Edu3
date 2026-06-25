import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Initialize SharedPreferences (lazy loading)
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('StorageService initialized');
    }
  }

  /// Ensure initialization before use
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  List<String> getCompletedTasks() {
    return _prefs?.getStringList(AppConstants.completedTasksKey) ?? [];
  }

  Future<void> markTaskComplete(String taskId) async {
    await _ensureInitialized();
    final completedTasks = getCompletedTasks();
    if (!completedTasks.contains(taskId)) {
      completedTasks.add(taskId);
      await _prefs?.setStringList(AppConstants.completedTasksKey, completedTasks);
    }
  }

  Future<void> markTaskIncomplete(String taskId) async {
    await _ensureInitialized();
    final completedTasks = getCompletedTasks();
    completedTasks.remove(taskId);
    await _prefs?.setStringList(AppConstants.completedTasksKey, completedTasks);
  }

  bool isTaskCompleted(String taskId) {
    return getCompletedTasks().contains(taskId);
  }

  Future<void> clearCompletedTasks() async {
    await _ensureInitialized();
    await _prefs?.remove(AppConstants.completedTasksKey);
  }
}
