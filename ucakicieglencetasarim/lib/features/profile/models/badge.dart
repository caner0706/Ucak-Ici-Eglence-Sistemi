import 'package:flutter/material.dart';

class UserBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime earnedAt;

  UserBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.earnedAt,
  });
} 