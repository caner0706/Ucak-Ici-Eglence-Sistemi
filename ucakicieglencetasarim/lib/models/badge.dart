import 'package:flutter/material.dart';

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
  });

  AchievementBadge copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    bool? isUnlocked,
  }) {
    return AchievementBadge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
} 