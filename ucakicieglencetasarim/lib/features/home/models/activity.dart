import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final double progress;
  final IconData icon;
  final Color color;
  final String category;
  final DateTime lastUpdated;
  final bool isCompleted;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.icon,
    required this.color,
    required this.category,
    required this.lastUpdated,
    this.isCompleted = false,
  });

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    double? progress,
    IconData? icon,
    Color? color,
    String? category,
    DateTime? lastUpdated,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
} 