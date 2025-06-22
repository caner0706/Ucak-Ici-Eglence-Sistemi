import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../../../shared/services/badge_service.dart';
import '../../../../shared/widgets/badge_dialog.dart';
import 'aviation_intro_screen.dart';
import 'first_flight_screen.dart';
import 'airplane_parts_screen.dart';
import 'air_flow_screen.dart';
import 'meteorology_screen.dart';
import 'safety_rules_screen.dart';
import 'emergency_screen.dart';

class BasicTrainingScreen extends StatefulWidget {
  const BasicTrainingScreen({super.key});

  @override
  State<BasicTrainingScreen> createState() => _BasicTrainingScreenState();
}

class _BasicTrainingScreenState extends State<BasicTrainingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<String, bool> _completedTasks = {
    'Havacılığa Giriş': false,
    'İlk Uçuşlar': false,
    'Uçak Parçaları': false,
    'Hava Akışı': false,
    'Meteoroloji': false,
    'Güvenlik Kuralları': false,
    'Acil Durumlar': false,
  };

  // Görev sıralaması
  final List<String> _taskOrder = [
    'Havacılığa Giriş',
    'İlk Uçuşlar',
    'Uçak Parçaları',
    'Hava Akışı',
    'Meteoroloji',
    'Güvenlik Kuralları',
    'Acil Durumlar',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  void _handleTaskCompletion(String taskName, bool completed) {
    if (completed) {
      setState(() {
        _completedTasks[taskName] = true;
      });
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
                    description: 'Uçakların nasıl uçtuğunu ve temel prensipleri öğren',
                    progress: _calculateTaskProgress('Havacılığa Giriş'),
                    icon: Icons.flight,
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
                    title: 'İlk Uçuşlar',
                    description: 'Havacılık tarihindeki önemli ilk uçuşları keşfet',
                    progress: _calculateTaskProgress('İlk Uçuşlar'),
                    icon: Icons.history_edu,
                    onTap: _isTaskLocked('İlk Uçuşlar') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FirstFlightScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('İlk Uçuşlar', true);
                      }
                    },
                    details: [
                      'Hezarfen\'in ilk uçuşu',
                      'Wright Kardeşler',
                      'İlk Türk pilot',
                      'Modern havacılık'
                    ],
                    isCompleted: _completedTasks['İlk Uçuşlar']!,
                    isLocked: _isTaskLocked('İlk Uçuşlar'),
                  ),
                  _buildTrainingCard(
                    title: 'Uçak Parçaları',
                    description: 'Uçağın temel parçalarını ve işlevlerini öğren',
                    progress: _calculateTaskProgress('Uçak Parçaları'),
                    icon: Icons.architecture,
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
                    title: 'Hava Akışı',
                    description: 'Hava akışı ve aerodinamik prensipleri keşfet',
                    progress: _calculateTaskProgress('Hava Akışı'),
                    icon: Icons.air,
                    onTap: _isTaskLocked('Hava Akışı') ? null : () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AirFlowScreen(),
                        ),
                      );
                      if (result == true) {
                        _handleTaskCompletion('Hava Akışı', true);
                      }
                    },
                    details: [
                      'Hava akışı prensipleri',
                      'Kaldırma kuvveti',
                      'Sürükleme kuvveti',
                      'Aerodinamik tasarım'
                    ],
                    isCompleted: _completedTasks['Hava Akışı']!,
                    isLocked: _isTaskLocked('Hava Akışı'),
                  ),
                  _buildTrainingCard(
                    title: 'Meteoroloji',
                    description: 'Hava durumu ve uçuş üzerindeki etkilerini öğren',
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
                    title: 'Güvenlik Kuralları',
                    description: 'Uçuş güvenliği ve temel kuralları öğren',
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
                    title: 'Acil Durumlar',
                    description: 'Acil durum prosedürlerini ve güvenlik önlemlerini öğren',
                    progress: _calculateTaskProgress('Acil Durumlar'),
                    icon: Icons.emergency,
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