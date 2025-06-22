import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/badge_service.dart';
import '../../../../shared/widgets/badge_dialog.dart';
import 'origami_airplane_screen.dart';
import '3d_model_screen.dart';
import 'wing_design_screen.dart';
import 'wind_tunnel_screen.dart';
import 'motor_integration_screen.dart';
import 'cockpit_design_screen.dart';
import 'material_selection_screen.dart';
import 'flight_simulation_screen.dart';

class DesignWorkshopScreen extends StatefulWidget {
  const DesignWorkshopScreen({super.key});

  @override
  State<DesignWorkshopScreen> createState() => _DesignWorkshopScreenState();
}

class _DesignWorkshopScreenState extends State<DesignWorkshopScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, bool> _completedTasks = {
    'Origami Uçak': false,
    '3D Uçak Modeli': false,
    'Kanat Tasarımı': false,
    'Rüzgar Tüneli Testi': false,
    'Motor Entegrasyonu': false,
    'Kokpit Tasarımı': false,
    'Malzeme Seçimi': false,
    'Uçuş Simülasyonu': false,
  };

  // Görev sıralaması
  final List<String> _taskOrder = [
    'Origami Uçak',
    '3D Uçak Modeli',
    'Kanat Tasarımı',
    'Rüzgar Tüneli Testi',
    'Motor Entegrasyonu',
    'Kokpit Tasarımı',
    'Malzeme Seçimi',
    'Uçuş Simülasyonu',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _loadCompletedTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCompletedTasks() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('completed_tasks')
        .where('userId', isEqualTo: user.uid)
        .where('moduleId', isEqualTo: 'design_workshop')
        .get();

      setState(() {
      for (var doc in snapshot.docs) {
        final taskName = doc['taskName'] as String;
        _completedTasks[taskName] = true;
      }
      });
    }

  Future<void> _completeTask(String taskName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Tamamlanan görevi kaydet
    await _firestore.collection('completed_tasks').add({
      'userId': user.uid,
      'moduleId': 'design_workshop',
      'taskName': taskName,
      'completedAt': FieldValue.serverTimestamp(),
      'points': 100, // Her görev için 100 puan
    });

    // Kullanıcı ilerlemesini güncelle
    final progressDoc = await _firestore
        .collection('user_progress')
        .where('userId', isEqualTo: user.uid)
        .where('moduleId', isEqualTo: 'design_workshop')
        .get();

    if (progressDoc.docs.isEmpty) {
      // İlk kez başlıyorsa yeni ilerleme oluştur
      await _firestore.collection('user_progress').add({
        'userId': user.uid,
        'moduleId': 'design_workshop',
        'completedTaskIds': [taskName],
        'earnedBadges': [],
        'lastCompletedAt': FieldValue.serverTimestamp(),
        'currentTaskIndex': 1,
      });
    } else {
      // Mevcut ilerlemeyi güncelle
      final doc = progressDoc.docs.first;
      final completedTasks = List<String>.from(doc['completedTaskIds'] as List);
      completedTasks.add(taskName);

      await doc.reference.update({
        'completedTaskIds': completedTasks,
        'lastCompletedAt': FieldValue.serverTimestamp(),
        'currentTaskIndex': completedTasks.length,
      });
    }

    setState(() {
      _completedTasks[taskName] = true;
    });
  }

  void _showBadgeDialog(String badgeId) {
    final badge = BadgeService.getBadgeById(badgeId);
    if (badge != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => BadgeDialog(badge: badge),
      );
    }
  }

  void _handleTaskCompletion(String taskName, bool completed) async {
    if (completed) {
      try {
        // Görevi tamamla
        await _completeTask(taskName);

        // Rozet kazanma
        String? badgeId;
        switch (taskName) {
          case 'Origami Uçak':
            badgeId = 'origami_design';
            break;
          case '3D Uçak Modeli':
            badgeId = '3d_modeling';
            break;
          case 'Kanat Tasarımı':
            badgeId = 'wing_design';
            break;
          case 'Rüzgar Tüneli Testi':
            badgeId = 'wind_tunnel';
            break;
          case 'Motor Entegrasyonu':
            badgeId = 'motor_integration';
            break;
          case 'Kokpit Tasarımı':
            badgeId = 'cockpit_design';
            break;
          case 'Malzeme Seçimi':
            badgeId = 'material_selection';
            break;
          case 'Uçuş Simülasyonu':
            badgeId = 'flight_simulation';
            break;
        }

        if (badgeId != null) {
          await BadgeService.unlockBadge(badgeId);
          if (mounted) {
            _showBadgeDialog(badgeId);
          }
        }

        // Başarı mesajı göster
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$taskName görevi başarıyla tamamlandı!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Hata durumunda
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bir hata oluştu: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Görevin kilitli olup olmadığını kontrol et
  bool _isTaskLocked(String taskName) {
    final taskIndex = _taskOrder.indexOf(taskName);
    if (taskIndex == 0) return false; // İlk görev her zaman açık
    
    // Önceki görev tamamlanmamışsa kilitli
    final previousTask = _taskOrder[taskIndex - 1];
    return !_completedTasks[previousTask]!;
  }

  // Görevin ilerleme durumunu hesapla
  double _calculateTaskProgress(String taskName) {
    if (_completedTasks[taskName]!) return 1.0;
    if (_isTaskLocked(taskName)) return 0.0;
    
    final taskIndex = _taskOrder.indexOf(taskName);
    if (taskIndex == 0) return 0.8; // İlk görev için varsayılan ilerleme
    
    // Önceki görevlerin tamamlanma durumuna göre ilerleme
    int completedPreviousTasks = 0;
    for (int i = 0; i < taskIndex; i++) {
      if (_completedTasks[_taskOrder[i]]!) completedPreviousTasks++;
    }
    return (completedPreviousTasks / taskIndex) * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Arka plan gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Color(0xFF42A5F5),
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),
        // Animasyonlu yıldızlar
        ...List.generate(20, (index) {
          return Positioned(
            left: (index * 100.0) % MediaQuery.of(context).size.width,
            top: (index * 80.0) % MediaQuery.of(context).size.height,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.5 + (sin(_controller.value * 2 * pi + index) * 0.3),
                  child: Opacity(
                    opacity: 0.4 + (sin(_controller.value * 2 * pi + index) * 0.3),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                );
              },
            ),
          );
        }),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tasarım Atölyesi',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Kendi uçağını tasarla',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),
                  // Tasarım Projeleri
                  _buildProjectCard(
                    title: 'Origami Uçak',
                    description: 'Kağıttan uçak tasarımı yap ve uçuş performansını test et',
                    progress: _calculateTaskProgress('Origami Uçak'),
                    icon: Icons.art_track,
                    onTap: _isTaskLocked('Origami Uçak') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrigamiAirplaneScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Origami Uçak', true);
                      }
                    },
                    details: [
                      'Farklı kağıt türleri ile denemeler yap',
                      'Kanat açılarını optimize et',
                      'Uçuş mesafesini ölç ve kaydet',
                      'En iyi tasarımı seç ve geliştir'
                    ],
                    isCompleted: _completedTasks['Origami Uçak']!,
                    isLocked: _isTaskLocked('Origami Uçak'),
                  ),
                  _buildProjectCard(
                    title: '3D Uçak Modeli',
                    description: '3D yazıcı ile detaylı uçak modeli tasarla',
                    progress: _calculateTaskProgress('3D Uçak Modeli'),
                    icon: Icons.architecture,
                    onTap: _isTaskLocked('3D Uçak Modeli') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThreeDModelScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('3D Uçak Modeli', true);
                      }
                    },
                    details: [
                      '3D modelleme yazılımında tasarım yap',
                      'Parçaları optimize et ve birleştir',
                      '3D yazıcı ayarlarını yapılandır',
                      'Modeli yazdır ve montajla'
                    ],
                    isCompleted: _completedTasks['3D Uçak Modeli']!,
                    isLocked: _isTaskLocked('3D Uçak Modeli'),
                  ),
                  _buildProjectCard(
                    title: 'Kanat Tasarımı',
                    description: 'Farklı kanat şekilleri ve profilleri dene',
                    progress: _calculateTaskProgress('Kanat Tasarımı'),
                    icon: Icons.flight,
                    onTap: _isTaskLocked('Kanat Tasarımı') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WingDesignScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Kanat Tasarımı', true);
                      }
                    },
                    details: [
                      'Farklı kanat profillerini araştır',
                      'Kaldırma kuvveti hesaplamaları yap',
                      'Prototip kanatları test et',
                      'En verimli tasarımı seç'
                    ],
                    isCompleted: _completedTasks['Kanat Tasarımı']!,
                    isLocked: _isTaskLocked('Kanat Tasarımı'),
                  ),
                  _buildProjectCard(
                    title: 'Rüzgar Tüneli Testi',
                    description: 'Tasarımını rüzgar tünelinde test et ve optimize et',
                    progress: _calculateTaskProgress('Rüzgar Tüneli Testi'),
                    icon: Icons.speed,
                    onTap: _isTaskLocked('Rüzgar Tüneli Testi') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WindTunnelScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Rüzgar Tüneli Testi', true);
                      }
                    },
                    details: [
                      'Test parametrelerini belirle',
                      'Sürükleme kuvvetini ölç',
                      'Veri analizi yap',
                      'Tasarımı iyileştir'
                    ],
                    isCompleted: _completedTasks['Rüzgar Tüneli Testi']!,
                    isLocked: _isTaskLocked('Rüzgar Tüneli Testi'),
                  ),
                  _buildProjectCard(
                    title: 'Motor Entegrasyonu',
                    description: 'Uçak tasarımına uygun motor seçimi ve entegrasyonu',
                    progress: _calculateTaskProgress('Motor Entegrasyonu'),
                    icon: Icons.engineering,
                    onTap: _isTaskLocked('Motor Entegrasyonu') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MotorIntegrationScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Motor Entegrasyonu', true);
                      }
                    },
                    details: [
                      'Motor tiplerini araştır',
                      'Güç gereksinimlerini hesapla',
                      'Motor montajını planla',
                      'Performans testleri yap'
                    ],
                    isCompleted: _completedTasks['Motor Entegrasyonu']!,
                    isLocked: _isTaskLocked('Motor Entegrasyonu'),
                  ),
                  _buildProjectCard(
                    title: 'Kokpit Tasarımı',
                    description: 'Pilot için ergonomik kokpit tasarımı',
                    progress: _calculateTaskProgress('Kokpit Tasarımı'),
                    icon: Icons.dashboard,
                    onTap: _isTaskLocked('Kokpit Tasarımı') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CockpitDesignScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Kokpit Tasarımı', true);
                      }
                    },
                    details: [
                      'Kokpit yerleşimini planla',
                      'Göstergeleri yerleştir',
                      'Kontrolleri optimize et',
                      'Ergonomi testleri yap'
                    ],
                    isCompleted: _completedTasks['Kokpit Tasarımı']!,
                    isLocked: _isTaskLocked('Kokpit Tasarımı'),
                  ),
                  _buildProjectCard(
                    title: 'Malzeme Seçimi',
                    description: 'Uçak yapısı için en uygun malzemeleri seç',
                    progress: _calculateTaskProgress('Malzeme Seçimi'),
                    icon: Icons.construction,
                    onTap: _isTaskLocked('Malzeme Seçimi') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MaterialSelectionScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Malzeme Seçimi', true);
                      }
                    },
                    details: [
                      'Malzeme özelliklerini araştır',
                      'Maliyet analizi yap',
                      'Dayanıklılık testleri planla',
                      'Malzeme kombinasyonlarını değerlendir'
                    ],
                    isCompleted: _completedTasks['Malzeme Seçimi']!,
                    isLocked: _isTaskLocked('Malzeme Seçimi'),
                  ),
                  _buildProjectCard(
                    title: 'Uçuş Simülasyonu',
                    description: 'Tasarımını simülasyon ortamında test et',
                    progress: _calculateTaskProgress('Uçuş Simülasyonu'),
                    icon: Icons.flight_takeoff,
                    onTap: _isTaskLocked('Uçuş Simülasyonu') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FlightSimulationScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Uçuş Simülasyonu', true);
                      }
                    },
                    details: [
                      'Simülasyon parametrelerini ayarla',
                      'Farklı uçuş senaryoları test et',
                      'Performans verilerini topla',
                      'Tasarımı simülasyon sonuçlarına göre iyileştir'
                    ],
                    isCompleted: _completedTasks['Uçuş Simülasyonu']!,
                    isLocked: _isTaskLocked('Uçuş Simülasyonu'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String description,
    required double progress,
    required IconData icon,
    required VoidCallback? onTap,
    required List<String> details,
    required bool isCompleted,
    required bool isLocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isLocked ? Colors.grey.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.grey.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isLocked ? Colors.grey.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isLocked ? Colors.grey : Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isLocked ? Colors.grey : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              color: isLocked ? Colors.grey.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                      )
                    else if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 24,
                        ),
                      )
                    else
                      Icon(
                        progress >= 1.0 ? Icons.check_circle : Icons.lock_open,
                        color: progress >= 1.0 ? Colors.green : Colors.orange,
                      ),
                  ],
                ),
                if (progress > 0 && progress < 1.0) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLocked ? Colors.grey : Colors.orange,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_right,
                        color: isLocked ? Colors.grey.withOpacity(0.7) : Colors.orange.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          detail,
                          style: TextStyle(
                            color: isLocked ? Colors.grey.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                if (isLocked) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Bu görevi açmak için önceki görevi tamamlamalısın',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }
} 