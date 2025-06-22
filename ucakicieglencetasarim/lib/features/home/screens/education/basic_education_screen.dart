import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/badge_service.dart';
import '../../../../shared/widgets/badge_dialog.dart';
import 'aviation_intro_screen.dart';
import 'air_flow_screen.dart';
import 'airplane_parts_screen.dart';
import 'first_flight_screen.dart';
import 'safety_rules_screen.dart';
import 'meteorology_screen.dart';
import 'navigation_screen.dart';
import 'communication_screen.dart';
import 'flight_planning_screen.dart';
import 'emergency_screen.dart';

class BasicEducationScreen extends StatefulWidget {
  const BasicEducationScreen({super.key});

  @override
  State<BasicEducationScreen> createState() => _BasicEducationScreenState();
}

class _BasicEducationScreenState extends State<BasicEducationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, bool> _completedTasks = {
    'Havacılığa Giriş': false,
    'Hava Akımı': false,
    'Uçak Parçaları': false,
    'İlk Uçuş Deneyimi': false,
    'Güvenlik Kuralları': false,
    'Meteoroloji': false,
    'Navigasyon': false,
    'İletişim': false,
    'Uçuş Planlaması': false,
    'Acil Durumlar': false,
  };

  // Görev sıralaması
  final List<String> _taskOrder = [
    'Havacılığa Giriş',
    'Hava Akımı',
    'Uçak Parçaları',
    'İlk Uçuş Deneyimi',
    'Güvenlik Kuralları',
    'Meteoroloji',
    'Navigasyon',
    'İletişim',
    'Uçuş Planlaması',
    'Acil Durumlar',
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
        .where('moduleId', isEqualTo: 'basic_education')
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
      'moduleId': 'basic_education',
      'taskName': taskName,
      'completedAt': FieldValue.serverTimestamp(),
      'points': 100, // Her görev için 100 puan
    });

    // Kullanıcı ilerlemesini güncelle
    final progressDoc = await _firestore
        .collection('user_progress')
        .where('userId', isEqualTo: user.uid)
        .where('moduleId', isEqualTo: 'basic_education')
        .get();

    if (progressDoc.docs.isEmpty) {
      // İlk kez başlıyorsa yeni ilerleme oluştur
      await _firestore.collection('user_progress').add({
        'userId': user.uid,
        'moduleId': 'basic_education',
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

      // Rozet kontrolü
      final earnedBadges = List<String>.from(doc['earnedBadges'] as List);
      if (completedTasks.length == _taskOrder.length) {
        earnedBadges.add('Temel Eğitim Tamamlama Rozeti');
      } else if (completedTasks.length % 3 == 0) {
        earnedBadges.add('Temel Eğitim İlerleme Rozeti ${(completedTasks.length / 3).toInt()}');
      }

      await doc.reference.update({
        'completedTaskIds': completedTasks,
        'earnedBadges': earnedBadges,
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
          case 'Havacılığa Giriş':
            badgeId = 'aviation_intro';
            break;
          case 'Hava Akımı':
            badgeId = 'air_flow';
            break;
          case 'Uçak Parçaları':
            badgeId = 'airplane_parts';
            break;
          case 'İlk Uçuş Deneyimi':
            badgeId = 'first_flight';
            break;
          case 'Güvenlik Kuralları':
            badgeId = 'safety_rules';
            break;
          case 'Meteoroloji':
            badgeId = 'meteorology';
            break;
          case 'Navigasyon':
            badgeId = 'navigation';
            break;
          case 'İletişim':
            badgeId = 'communication';
            break;
          case 'Uçuş Planlaması':
            badgeId = 'flight_planning';
            break;
          case 'Acil Durumlar':
            badgeId = 'emergency';
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
                        'Temel Eğitim',
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
                    'Havacılığın temellerini öğren',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),
                  // Eğitim Kartları
                  _buildTrainingCard(
                    title: 'Havacılığa Giriş',
                    description: 'Uçaklar nasıl uçar? Temel prensipleri öğren',
                    progress: _calculateTaskProgress('Havacılığa Giriş'),
                    icon: Icons.flight_takeoff,
                    onTap: _isTaskLocked('Havacılığa Giriş') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AviationIntroScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Havacılığa Giriş', true);
                      }
                    },
                    details: [
                      'Uçakların uçuş prensipleri',
                      'Bernoulli prensibi',
                      'Uçuş kontrolleri',
                      'Temel havacılık terimleri'
                    ],
                    isCompleted: _completedTasks['Havacılığa Giriş']!,
                    isLocked: _isTaskLocked('Havacılığa Giriş'),
                  ),
                  _buildTrainingCard(
                    title: 'Hava Akımı',
                    description: 'Rüzgar ve hava akımının uçuşa etkisi',
                    progress: _calculateTaskProgress('Hava Akımı'),
                    icon: Icons.air,
                    onTap: _isTaskLocked('Hava Akımı') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AirFlowScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Hava Akımı', true);
                      }
                    },
                    details: [
                      'Hava akışı prensipleri',
                      'Kaldırma kuvveti',
                      'Sürükleme kuvveti',
                      'Aerodinamik tasarım'
                    ],
                    isCompleted: _completedTasks['Hava Akımı']!,
                    isLocked: _isTaskLocked('Hava Akımı'),
                  ),
                  _buildTrainingCard(
                    title: 'Uçak Parçaları',
                    description: 'Uçağın temel bileşenlerini tanı',
                    progress: _calculateTaskProgress('Uçak Parçaları'),
                    icon: Icons.engineering,
                    onTap: _isTaskLocked('Uçak Parçaları') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AirplanePartsScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Uçak Parçaları', true);
                      }
                    },
                    details: [
                      'Kanatlar ve kuyruk',
                      'Motor sistemleri',
                      'Kokpit kontrolleri',
                      'İniş takımı'
                    ],
                    isCompleted: _completedTasks['Uçak Parçaları']!,
                    isLocked: _isTaskLocked('Uçak Parçaları'),
                  ),
                  _buildTrainingCard(
                    title: 'İlk Uçuş Deneyimi',
                    description: 'Hezarfen\'in ilk uçuşunu keşfet',
                    progress: _calculateTaskProgress('İlk Uçuş Deneyimi'),
                    icon: Icons.history_edu,
                    onTap: _isTaskLocked('İlk Uçuş Deneyimi') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FirstFlightScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('İlk Uçuş Deneyimi', true);
                      }
                    },
                    details: [
                      'Hezarfen\'in ilk uçuşu',
                      'Wright Kardeşler',
                      'İlk Türk pilot',
                      'Modern havacılık'
                    ],
                    isCompleted: _completedTasks['İlk Uçuş Deneyimi']!,
                    isLocked: _isTaskLocked('İlk Uçuş Deneyimi'),
                  ),
                  _buildTrainingCard(
                    title: 'Güvenlik Kuralları',
                    description: 'Havacılıkta güvenlik önlemleri',
                    progress: _calculateTaskProgress('Güvenlik Kuralları'),
                    icon: Icons.security,
                    onTap: _isTaskLocked('Güvenlik Kuralları') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafetyRulesScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Güvenlik Kuralları', true);
                      }
                    },
                    details: [
                      'Kalkış ve iniş kuralları',
                      'Oksijen maskesi kullanımı',
                      'Acil çıkış prosedürleri',
                      'Türbülans güvenliği'
                    ],
                    isCompleted: _completedTasks['Güvenlik Kuralları']!,
                    isLocked: _isTaskLocked('Güvenlik Kuralları'),
                  ),
                  _buildTrainingCard(
                    title: 'Meteoroloji',
                    description: 'Hava durumunun uçuşa etkileri',
                    progress: _calculateTaskProgress('Meteoroloji'),
                    icon: Icons.cloud,
                    onTap: _isTaskLocked('Meteoroloji') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeteorologyScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Meteoroloji', true);
                      }
                    },
                    details: [
                      'Hava durumu faktörleri',
                      'Rüzgar etkileri',
                      'Türbülans',
                      'Uçuş planlaması'
                    ],
                    isCompleted: _completedTasks['Meteoroloji']!,
                    isLocked: _isTaskLocked('Meteoroloji'),
                  ),
                  _buildTrainingCard(
                    title: 'Navigasyon',
                    description: 'Yön bulma ve harita okuma',
                    progress: _calculateTaskProgress('Navigasyon'),
                    icon: Icons.explore,
                    onTap: _isTaskLocked('Navigasyon') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavigationScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Navigasyon', true);
                      }
                    },
                    details: [
                      'Harita okuma',
                      'Yön bulma teknikleri',
                      'Navigasyon cihazları',
                      'Rota planlaması'
                    ],
                    isCompleted: _completedTasks['Navigasyon']!,
                    isLocked: _isTaskLocked('Navigasyon'),
                  ),
                  _buildTrainingCard(
                    title: 'İletişim',
                    description: 'Havacılıkta iletişim ve sinyaller',
                    progress: _calculateTaskProgress('İletişim'),
                    icon: Icons.radio,
                    onTap: _isTaskLocked('İletişim') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CommunicationScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('İletişim', true);
                      }
                    },
                    details: [
                      'Radyo iletişimi',
                      'Havacılık sinyalleri',
                      'İletişim protokolleri',
                      'Acil durum iletişimi'
                    ],
                    isCompleted: _completedTasks['İletişim']!,
                    isLocked: _isTaskLocked('İletişim'),
                  ),
                  _buildTrainingCard(
                    title: 'Uçuş Planlaması',
                    description: 'Güvenli uçuş için planlama adımları',
                    progress: _calculateTaskProgress('Uçuş Planlaması'),
                    icon: Icons.flight,
                    onTap: _isTaskLocked('Uçuş Planlaması') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlightPlanningScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Uçuş Planlaması', true);
                      }
                    },
                    details: [
                      'Uçuş rotası planlaması',
                      'Yakıt hesaplaması',
                      'Hava durumu kontrolü',
                      'Alternatif planlar'
                    ],
                    isCompleted: _completedTasks['Uçuş Planlaması']!,
                    isLocked: _isTaskLocked('Uçuş Planlaması'),
                  ),
                  _buildTrainingCard(
                    title: 'Acil Durumlar',
                    description: 'Acil durum prosedürleri ve önlemler',
                    progress: _calculateTaskProgress('Acil Durumlar'),
                    icon: Icons.warning,
                    onTap: _isTaskLocked('Acil Durumlar') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmergencyScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Acil Durumlar', true);
                      }
                    },
                    details: [
                      'Motor arızası prosedürleri',
                      'Kabin basınç kaybı',
                      'Acil iniş prosedürleri',
                      'Yangın durumu'
                    ],
                    isCompleted: _completedTasks['Acil Durumlar']!,
                    isLocked: _isTaskLocked('Acil Durumlar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingCard({
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
            isLocked ? Colors.grey.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? Colors.grey.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
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
                        color: isLocked ? Colors.grey.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: isLocked ? Colors.grey : Colors.blue,
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
                        color: progress >= 1.0 ? Colors.green : Colors.blue,
                    ),
                  ],
                ),
                if (progress > 0 && progress < 1.0) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isLocked ? Colors.grey : Colors.blue,
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
                        color: isLocked ? Colors.grey.withOpacity(0.7) : Colors.blue.withOpacity(0.7),
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