import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class ScienceExperimentsMap extends StatefulWidget {
  const ScienceExperimentsMap({super.key});

  @override
  State<ScienceExperimentsMap> createState() => _ScienceExperimentsMapState();
}

class _ScienceExperimentsMapState extends State<ScienceExperimentsMap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentLevel = 0;
  final List<Map<String, dynamic>> _experiments = [
    {
      'title': 'Işık Deneyi',
      'description': 'Işığın yansıma ve kırılmasını keşfet',
      'icon': Icons.lightbulb,
      'progress': 0.6,
      'position': Offset(0.2, 0.3),
      'rewards': ['Işık Uzmanı Rozeti', '50 Puan'],
      'tasks': [
        'Işık kaynağını keşfet',
        'Yansıma deneyini yap',
        'Kırılma deneyini tamamla',
      ],
    },
    {
      'title': 'Ses Dalgaları',
      'description': 'Sesin nasıl yayıldığını gör',
      'icon': Icons.volume_up,
      'progress': 0.4,
      'position': Offset(0.5, 0.5),
      'rewards': ['Ses Uzmanı Rozeti', '75 Puan'],
      'tasks': [
        'Ses kaynağını bul',
        'Dalga deneyini yap',
        'Frekans deneyini tamamla',
      ],
    },
    {
      'title': 'Hava Basıncı',
      'description': 'Hava basıncının etkilerini öğren',
      'icon': Icons.compress,
      'progress': 0.2,
      'position': Offset(0.8, 0.7),
      'rewards': ['Hava Uzmanı Rozeti', '100 Puan'],
      'tasks': [
        'Basınç ölçümü yap',
        'Vakum deneyini tamamla',
        'Hava akışını gözlemle',
      ],
    },
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
        // Ana içerik
        SafeArea(
          child: Column(
            children: [
              // Başlık
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bilim Deneyleri Haritası',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Harita
              Expanded(
                child: Stack(
                  children: [
                    // Yol çizgileri
                    CustomPaint(
                      painter: PathPainter(_experiments),
                      size: Size.infinite,
                    ),
                    // Deney noktaları
                    ..._experiments.map((experiment) {
                      return Positioned(
                        left: experiment['position'].dx * MediaQuery.of(context).size.width,
                        top: experiment['position'].dy * MediaQuery.of(context).size.height,
                        child: GestureDetector(
                          onTap: () => _showExperimentDetails(experiment),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  experiment['icon'],
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  experiment['title'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                LinearProgressIndicator(
                                  value: experiment['progress'],
                                  backgroundColor: Colors.green.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExperimentDetails(Map<String, dynamic> experiment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(experiment['icon'], color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Text(
                  experiment['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              experiment['description'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Görevler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...experiment['tasks'].map<Widget>((task) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            const Text(
              'Ödüller',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...experiment['rewards'].map<Widget>((reward) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reward,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Deneyi başlat
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Deneyi Başlat',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Map<String, dynamic>> experiments;

  PathPainter(this.experiments);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    for (var i = 0; i < experiments.length - 1; i++) {
      final start = Offset(
        experiments[i]['position'].dx * size.width,
        experiments[i]['position'].dy * size.height,
      );
      final end = Offset(
        experiments[i + 1]['position'].dx * size.width,
        experiments[i + 1]['position'].dy * size.height,
      );

      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      }
      path.lineTo(end.dx, end.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 