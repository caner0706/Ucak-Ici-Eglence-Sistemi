import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final List<Activity> _activities = [];

  List<Activity> getActivities() {
    // Aktiviteleri son güncelleme tarihine göre sırala
    _activities.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return _activities;
  }

  void updateActivityProgress(String id, double progress) {
    final index = _activities.indexWhere((activity) => activity.id == id);
    if (index != -1) {
      final activity = _activities[index];
      _activities[index] = activity.copyWith(
        progress: progress,
        lastUpdated: DateTime.now(),
        isCompleted: progress >= 1.0,
      );
    }
  }

  void addActivity(Activity activity) {
    // Eğer aynı ID'ye sahip aktivite varsa güncelle
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
    } else {
      _activities.add(activity);
    }
  }

  void removeActivity(String id) {
    _activities.removeWhere((activity) => activity.id == id);
  }

  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Activity> getActivitiesByCategory(String category) {
    return _activities.where((activity) => activity.category == category).toList();
  }

  List<Activity> getInProgressActivities() {
    return _activities.where((activity) => activity.progress > 0 && activity.progress < 1.0).toList();
  }

  List<Activity> getCompletedActivities() {
    return _activities.where((activity) => activity.isCompleted).toList();
  }
} 