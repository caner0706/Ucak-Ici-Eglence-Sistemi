import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/services/badge_service.dart';
import '../../../../shared/widgets/badge_dialog.dart';
import 'final_project_screen.dart';
import 'aerodynamics_lab_screen.dart';
import 'engine_lab_screen.dart';
import 'material_lab_screen.dart';
import 'electronics_lab_screen.dart';
import 'fuel_lab_screen.dart';
import 'climate_lab_screen.dart';
import 'sound_lab_screen.dart';
import 'structure_lab_screen.dart';
import 'simulation_lab_screen.dart';

class ScienceLabScreen extends StatefulWidget {
  const ScienceLabScreen({super.key});

  @override
  State<ScienceLabScreen> createState() => _ScienceLabScreenState();
}

class _ScienceLabScreenState extends State<ScienceLabScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, bool> _completedTasks = {
    'Aerodinamik Deneyleri': false,
    'Motor Testleri': false,
    'Malzeme Testleri': false,
    'Elektronik Sistemler': false,
    'Yakıt Testleri': false,
    'İklim Testleri': false,
    'Ses Testleri': false,
    'Yapı Testleri': false,
    'Simülasyon Testleri': false,
    'Final Projesi': false,
  };

  // Görev sıralaması
  final List<String> _taskOrder = [
    'Aerodinamik Deneyleri',
    'Motor Testleri',
    'Malzeme Testleri',
    'Elektronik Sistemler',
    'Yakıt Testleri',
    'İklim Testleri',
    'Ses Testleri',
    'Yapı Testleri',
    'Simülasyon Testleri',
    'Final Projesi',
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
        .where('moduleId', isEqualTo: 'science_lab')
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
      'moduleId': 'science_lab',
      'taskName': taskName,
      'completedAt': FieldValue.serverTimestamp(),
      'points': 100, // Her görev için 100 puan
    });

    // Kullanıcı ilerlemesini güncelle
    final progressDoc = await _firestore
        .collection('user_progress')
        .where('userId', isEqualTo: user.uid)
        .where('moduleId', isEqualTo: 'science_lab')
        .get();

    if (progressDoc.docs.isEmpty) {
      // İlk kez başlıyorsa yeni ilerleme oluştur
      await _firestore.collection('user_progress').add({
        'userId': user.uid,
        'moduleId': 'science_lab',
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
          case 'Aerodinamik Deneyleri':
            badgeId = 'aerodynamics_lab';
            break;
          case 'Motor Testleri':
            badgeId = 'engine_lab';
            break;
          case 'Malzeme Testleri':
            badgeId = 'material_lab';
            break;
          case 'Elektronik Sistemler':
            badgeId = 'electronics_lab';
            break;
          case 'Yakıt Testleri':
            badgeId = 'fuel_lab';
            break;
          case 'İklim Testleri':
            badgeId = 'climate_lab';
            break;
          case 'Ses Testleri':
            badgeId = 'sound_lab';
            break;
          case 'Yapı Testleri':
            badgeId = 'structure_lab';
            break;
          case 'Simülasyon Testleri':
            badgeId = 'simulation_lab';
            break;
          case 'Final Projesi':
            badgeId = 'final_project';
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
                        'Bilim Laboratuvarı',
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
                    'Uçak sistemlerini laboratuvar ortamında test et',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),
                  // Laboratuvar Kartları
                  _buildLabCard(
                    title: 'Aerodinamik Deneyleri',
                    description: 'Hava akışı ve kaldırma kuvveti deneyleri',
                    progress: _calculateTaskProgress('Aerodinamik Deneyleri'),
                    icon: Icons.science,
                    onTap: _isTaskLocked('Aerodinamik Deneyleri') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AerodynamicsLabScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Aerodinamik Deneyleri', true);
                      }
                    },
                    details: [
                      'Hava akışı deneyleri yap',
                      'Kaldırma kuvvetini ölç',
                      'Sürükleme kuvvetini analiz et',
                      'Test sonuçlarını değerlendir'
                    ],
                    isCompleted: _completedTasks['Aerodinamik Deneyleri']!,
                    isLocked: _isTaskLocked('Aerodinamik Deneyleri'),
                  ),
                  _buildLabCard(
                    title: 'Motor Testleri',
                    description: 'Jet motorları ve pervanelerin çalışma prensipleri',
                    progress: _calculateTaskProgress('Motor Testleri'),
                    icon: Icons.precision_manufacturing,
                    onTap: _isTaskLocked('Motor Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EngineLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Motor Testleri', true);
                      }
                    },
                    details: [
                      'Motor tiplerini incele',
                      'Çalışma prensiplerini öğren',
                      'Performans testleri yap',
                      'Verimlilik analizi yap'
                    ],
                    isCompleted: _completedTasks['Motor Testleri']!,
                    isLocked: _isTaskLocked('Motor Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Malzeme Testleri',
                    description: 'Uçak malzemelerinin dayanıklılık testleri',
                    progress: _calculateTaskProgress('Malzeme Testleri'),
                    icon: Icons.architecture,
                    onTap: _isTaskLocked('Malzeme Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MaterialLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Malzeme Testleri', true);
                      }
                    },
                    details: [
                      'Malzeme özelliklerini test et',
                      'Dayanıklılık analizi yap',
                      'Ağırlık-mukavemet oranını hesapla',
                      'Malzeme seçimini optimize et'
                    ],
                    isCompleted: _completedTasks['Malzeme Testleri']!,
                    isLocked: _isTaskLocked('Malzeme Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Elektronik Sistemler',
                    description: 'Uçak elektronik sistemlerinin testleri',
                    progress: _calculateTaskProgress('Elektronik Sistemler'),
                    icon: Icons.electric_bolt,
                    onTap: _isTaskLocked('Elektronik Sistemler') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ElectronicsLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Elektronik Sistemler', true);
                      }
                    },
                    details: [
                      'Elektronik sistemleri test et',
                      'İletişim sistemlerini kontrol et',
                      'Güvenlik sistemlerini doğrula',
                      'Sistem entegrasyonunu test et'
                    ],
                    isCompleted: _completedTasks['Elektronik Sistemler']!,
                    isLocked: _isTaskLocked('Elektronik Sistemler'),
                  ),
                  _buildLabCard(
                    title: 'Yakıt Testleri',
                    description: 'Uçak yakıtlarının özellikleri ve testleri',
                    progress: _calculateTaskProgress('Yakıt Testleri'),
                    icon: Icons.local_gas_station,
                    onTap: _isTaskLocked('Yakıt Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FuelLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Yakıt Testleri', true);
                      }
                    },
                    details: [
                      'Yakıt özelliklerini analiz et',
                      'Verimlilik testleri yap',
                      'Yakıt tüketimini ölç',
                      'Yakıt sistemini optimize et'
                    ],
                    isCompleted: _completedTasks['Yakıt Testleri']!,
                    isLocked: _isTaskLocked('Yakıt Testleri'),
                  ),
                  _buildLabCard(
                    title: 'İklim Testleri',
                    description: 'Aşırı hava koşullarında uçak testleri',
                    progress: _calculateTaskProgress('İklim Testleri'),
                    icon: Icons.thermostat,
                    onTap: _isTaskLocked('İklim Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ClimateLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('İklim Testleri', true);
                      }
                    },
                    details: [
                      'Sıcaklık testleri yap',
                      'Nem etkisini ölç',
                      'Basınç testleri uygula',
                      'İklim koşullarını simüle et'
                    ],
                    isCompleted: _completedTasks['İklim Testleri']!,
                    isLocked: _isTaskLocked('İklim Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Ses Testleri',
                    description: 'Uçak gürültü seviyesi ve ses yalıtımı testleri',
                    progress: _calculateTaskProgress('Ses Testleri'),
                    icon: Icons.volume_up,
                    onTap: _isTaskLocked('Ses Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SoundLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Ses Testleri', true);
                      }
                    },
                    details: [
                      'Gürültü seviyesini ölç',
                      'Ses yalıtımını test et',
                      'Akustik analiz yap',
                      'Ses optimizasyonu uygula'
                    ],
                    isCompleted: _completedTasks['Ses Testleri']!,
                    isLocked: _isTaskLocked('Ses Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Yapı Testleri',
                    description: 'Uçak yapısal bütünlük testleri',
                    progress: _calculateTaskProgress('Yapı Testleri'),
                    icon: Icons.construction,
                    onTap: _isTaskLocked('Yapı Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StructureLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Yapı Testleri', true);
                      }
                    },
                    details: [
                      'Yapısal bütünlüğü test et',
                      'Stres analizi yap',
                      'Dayanıklılık testleri uygula',
                      'Yapısal optimizasyon yap'
                    ],
                    isCompleted: _completedTasks['Yapı Testleri']!,
                    isLocked: _isTaskLocked('Yapı Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Simülasyon Testleri',
                    description: 'Uçuş simülasyonları ve testleri',
                    progress: _calculateTaskProgress('Simülasyon Testleri'),
                    icon: Icons.sim_card,
                    onTap: _isTaskLocked('Simülasyon Testleri') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SimulationLabScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Simülasyon Testleri', true);
                      }
                    },
                    details: [
                      'Uçuş simülasyonları yap',
                      'Farklı senaryoları test et',
                      'Performans verilerini topla',
                      'Simülasyon sonuçlarını analiz et'
                    ],
                    isCompleted: _completedTasks['Simülasyon Testleri']!,
                    isLocked: _isTaskLocked('Simülasyon Testleri'),
                  ),
                  _buildLabCard(
                    title: 'Final Projesi',
                    description: 'Tüm laboratuvar deneyimlerini birleştir',
                    progress: _calculateTaskProgress('Final Projesi'),
                    icon: Icons.emoji_events,
                    onTap: _isTaskLocked('Final Projesi') ? null : () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FinalProjectScreen(),
                          ),
                        );
                        if (result == true) {
                        _handleTaskCompletion('Final Projesi', true);
                      }
                    },
                    details: [
                      'Tüm test sonuçlarını birleştir',
                      'Kapsamlı analiz yap',
                      'Rapor hazırla',
                      'Sunum yap'
                    ],
                    isCompleted: _completedTasks['Final Projesi']!,
                    isLocked: _isTaskLocked('Final Projesi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabCard({
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