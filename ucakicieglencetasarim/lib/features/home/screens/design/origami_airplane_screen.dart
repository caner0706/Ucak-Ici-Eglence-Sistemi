import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class OrigamiAirplaneScreen extends StatefulWidget {
  const OrigamiAirplaneScreen({super.key});

  @override
  State<OrigamiAirplaneScreen> createState() => _OrigamiAirplaneScreenState();
}

class _OrigamiAirplaneScreenState extends State<OrigamiAirplaneScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;
  bool _isCompleted = false;
  bool _showBadge = false;
  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Kağıt Seçimi',
      'description': 'Farklı kağıt türleri ile denemeler yap',
      'icon': Icons.description,
      'details': [
        'A4 kağıt (80 g/m²)',
        'İnce karton (120 g/m²)',
        'Kalın karton (200 g/m²)',
        'Özel origami kağıdı'
      ],
      'image': 'assets/images/paper_selection.png'
    },
    {
      'title': 'Kanat Açıları',
      'description': 'Kanat açılarını optimize et',
      'icon': Icons.arrow_forward,
      'details': [
        'Kanat açısı: 15°',
        'Kanat açıklığı: 20 cm',
        'Kuyruk açısı: 10°',
        'Burun açısı: 5°'
      ],
      'image': 'assets/images/wing_angles.png'
    },
    {
      'title': 'Uçuş Testi',
      'description': 'Uçuş mesafesini ölç ve kaydet',
      'icon': Icons.flight,
      'details': [
        'Başlangıç hızı: 2 m/s',
        'Fırlatma açısı: 45°',
        'Maksimum mesafe: 10m',
        'Uçuş süresi: 3 sn'
      ],
      'image': 'assets/images/flight_test.png'
    },
    {
      'title': 'Optimizasyon',
      'description': 'En iyi tasarımı seç ve geliştir',
      'icon': Icons.trending_up,
      'details': [
        'Aerodinamik iyileştirmeler',
        'Ağırlık optimizasyonu',
        'Stabilite ayarları',
        'Final testleri'
      ],
      'image': 'assets/images/optimization.png'
    }
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

  void _completeTask() {
    setState(() {
      _isCompleted = true;
      _showBadge = true;
    });

    // Show badge animation
    Future.delayed(const Duration(milliseconds: 500), () {
      _showBadgeDialog();
    });
  }

  void _showBadgeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withOpacity(0.9),
                  Colors.orange.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.art_track,
                    color: Colors.white,
                    size: 64,
                  ),
                ).animate()
                  .scale(duration: 600.ms)
                  .then()
                  .shake(duration: 600.ms),
                const SizedBox(height: 20),
                const Text(
                  'Tebrikler!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 10),
                const Text(
                  'Origami Uçak Rozeti Kazandın!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                  ),
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Harika!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
          child: Column(
            children: [
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
                      'Origami Uçak',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepCard(_steps[_currentStep]),
                        const SizedBox(height: 24),
                        _buildProgressIndicator(),
                        const SizedBox(height: 24),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(Map<String, dynamic> step) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    step['icon'],
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...step['details'].map<Widget>((detail) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    color: Colors.orange.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    step['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      print('Image path: ${step['image']}');
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                  size: 64,
                            color: Colors.red.withOpacity(0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Görsel yüklenemedi',
                            style: TextStyle(
                              color: Colors.red.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_steps.length, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentStep == index
                    ? Colors.orange
                    : Colors.white.withOpacity(0.3),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Adım ${_currentStep + 1}/${_steps.length}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: _currentStep > 0
              ? () {
                  setState(() {
                    _currentStep--;
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.withOpacity(0.2),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Önceki',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _currentStep < _steps.length - 1
              ? () {
                  setState(() {
                    _currentStep++;
                  });
                }
              : _isCompleted ? null : _completeTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _currentStep < _steps.length - 1 
                ? 'Sonraki' 
                : _isCompleted 
                    ? 'Tamamlandı' 
                    : 'Tamamla',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
} 