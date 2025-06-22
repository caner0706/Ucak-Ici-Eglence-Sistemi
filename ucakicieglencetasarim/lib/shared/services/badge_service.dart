import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/badge.dart';

class BadgeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final List<AchievementBadge> _badges = [
    AchievementBadge(
      id: 'aviation_intro',
      title: 'Havacılık Adayı',
      description: 'Havacılığın temellerini öğrendin',
      icon: Icons.flight_takeoff,
      color: Colors.blue,
    ),
    AchievementBadge(
      id: 'air_flow',
      title: 'Hava Uzmanı',
      description: 'Hava akımlarını keşfettin',
      icon: Icons.air,
      color: Colors.lightBlue,
    ),
    AchievementBadge(
      id: 'airplane_parts',
      title: 'Mekanik Uzmanı',
      description: 'Uçak parçalarını tanıdın',
      icon: Icons.engineering,
      color: Colors.orange,
    ),
    AchievementBadge(
      id: 'first_flight',
      title: 'İlk Uçuş',
      description: 'Hezarfen\'in ilk uçuşunu öğrendin',
      icon: Icons.history_edu,
      color: Colors.purple,
    ),
    AchievementBadge(
      id: 'safety_rules',
      title: 'Güvenlik Uzmanı',
      description: 'Güvenlik kurallarını öğrendin',
      icon: Icons.security,
      color: Colors.green,
    ),
    AchievementBadge(
      id: 'meteorology',
      title: 'Meteoroloji Uzmanı',
      description: 'Hava durumunu öğrendin',
      icon: Icons.cloud,
      color: Colors.cyan,
    ),
    AchievementBadge(
      id: 'navigation',
      title: 'Navigasyon Uzmanı',
      description: 'Yön bulma becerilerini geliştirdin',
      icon: Icons.explore,
      color: Colors.indigo,
    ),
    AchievementBadge(
      id: 'communication',
      title: 'İletişim Uzmanı',
      description: 'Havacılık iletişimini öğrendin',
      icon: Icons.radio,
      color: Colors.teal,
    ),
    AchievementBadge(
      id: 'flight_planning',
      title: 'Planlama Uzmanı',
      description: 'Uçuş planlamasını öğrendin',
      icon: Icons.flight,
      color: Colors.deepPurple,
    ),
    AchievementBadge(
      id: 'emergency',
      title: 'Acil Durum Uzmanı',
      description: 'Acil durum prosedürlerini öğrendin',
      icon: Icons.warning,
      color: Colors.red,
    ),
    AchievementBadge(
      id: 'aerodynamics_lab',
      title: 'Aerodinamik Uzmanı',
      description: 'Hava akışı ve kaldırma kuvveti deneylerini tamamladın',
      icon: Icons.science,
      color: Colors.blue,
    ),
    AchievementBadge(
      id: 'engine_lab',
      title: 'Motor Uzmanı',
      description: 'Jet motorları ve pervanelerin çalışma prensiplerini öğrendin',
      icon: Icons.precision_manufacturing,
      color: Colors.orange,
    ),
    AchievementBadge(
      id: 'material_lab',
      title: 'Malzeme Uzmanı',
      description: 'Uçak malzemelerinin dayanıklılık testlerini tamamladın',
      icon: Icons.architecture,
      color: Colors.green,
    ),
    AchievementBadge(
      id: 'electronics_lab',
      title: 'Elektronik Uzmanı',
      description: 'Uçak elektronik sistemlerinin testlerini tamamladın',
      icon: Icons.electric_bolt,
      color: Colors.purple,
    ),
    AchievementBadge(
      id: 'fuel_lab',
      title: 'Yakıt Uzmanı',
      description: 'Uçak yakıtlarının özelliklerini ve testlerini öğrendin',
      icon: Icons.local_gas_station,
      color: Colors.red,
    ),
    AchievementBadge(
      id: 'climate_lab',
      title: 'İklim Test Uzmanı',
      description: 'Aşırı hava koşullarında uçak testlerini tamamladın',
      icon: Icons.thermostat,
      color: Colors.cyan,
    ),
    AchievementBadge(
      id: 'sound_lab',
      title: 'Ses Test Uzmanı',
      description: 'Uçak gürültü seviyesi ve ses yalıtımı testlerini tamamladın',
      icon: Icons.volume_up,
      color: Colors.teal,
    ),
    AchievementBadge(
      id: 'structure_lab',
      title: 'Yapı Test Uzmanı',
      description: 'Uçak yapısal bütünlük testlerini tamamladın',
      icon: Icons.construction,
      color: Colors.indigo,
    ),
    AchievementBadge(
      id: 'simulation_lab',
      title: 'Simülasyon Uzmanı',
      description: 'Uçuş simülasyonları ve testlerini tamamladın',
      icon: Icons.sim_card,
      color: Colors.deepPurple,
    ),
    AchievementBadge(
      id: 'final_project',
      title: 'Laboratuvar Ustası',
      description: 'Tüm laboratuvar deneyimlerini başarıyla tamamladın',
      icon: Icons.emoji_events,
      color: Colors.amber,
    ),
  ];

  static List<AchievementBadge> getBadges() {
    return _badges;
  }

  static AchievementBadge? getBadgeById(String id) {
    try {
      return _badges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<void> unlockBadge(String id) async {
    final badge = getBadgeById(id);
    if (badge == null) return;

    // Yerel rozet durumunu güncelle
    final index = _badges.indexWhere((b) => b.id == id);
    if (index != -1) {
      _badges[index] = _badges[index].copyWith(isUnlocked: true);
    }
  }

  static bool isBadgeUnlocked(String id) {
    final badge = getBadgeById(id);
    return badge?.isUnlocked ?? false;
  }

  static List<AchievementBadge> getUserBadges() {
    return _badges.where((badge) => badge.isUnlocked).toList();
  }
} 