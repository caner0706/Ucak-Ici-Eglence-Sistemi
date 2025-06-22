import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/badge.dart';

class BadgeService {
  static const String _badgesKey = 'user_badges';
  List<UserBadge> _badges = [];
  late SharedPreferences _prefs;

  // Singleton pattern
  static final BadgeService _instance = BadgeService._internal();
  factory BadgeService() => _instance;
  BadgeService._internal();

  // SharedPreferences'ı başlat
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadBadges();
  }

  // Rozetleri yükle
  void _loadBadges() {
    final badgesJson = _prefs.getStringList(_badgesKey) ?? [];
    _badges = badgesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return UserBadge(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
        color: Color(map['color']),
        earnedAt: DateTime.parse(map['earnedAt']),
      );
    }).toList();
  }

  // Rozetleri kaydet
  Future<void> _saveBadges() async {
    final badgesJson = _badges.map((badge) {
      return jsonEncode({
        'id': badge.id,
        'title': badge.title,
        'description': badge.description,
        'icon': badge.icon.codePoint,
        'color': badge.color.value,
        'earnedAt': badge.earnedAt.toIso8601String(),
      });
    }).toList();
    await _prefs.setStringList(_badgesKey, badgesJson);
  }

  // Rozet ekle
  Future<void> addBadge(UserBadge badge) async {
    if (!hasBadge(badge.id)) {
      _badges.add(badge);
      await _saveBadges();
    }
  }

  // Tüm rozetleri getir
  List<UserBadge> getBadges() {
    return _badges;
  }

  // Belirli bir rozeti getir
  UserBadge? getBadge(String id) {
    try {
      return _badges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  // Rozet var mı kontrol et
  bool hasBadge(String id) {
    return _badges.any((badge) => badge.id == id);
  }
} 