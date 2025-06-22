import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class ExperimentsScreen extends StatefulWidget {
  const ExperimentsScreen({super.key});

  @override
  State<ExperimentsScreen> createState() => _ExperimentsScreenState();
}

class _ExperimentsScreenState extends State<ExperimentsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A237E), // Koyu lacivert
                  Color(0xFF0D47A1), // Koyu mavi
                  Color(0xFF1976D2), // Orta mavi
                  Color(0xFF42A5F5), // Açık mavi
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Bilim Deneyleri',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        const Text(
                          'Eğlenerek Öğren!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                  // Deney Kategorileri
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildExperimentCategory(
                          icon: Icons.airplanemode_active,
                          title: 'Havacılık Deneyleri',
                          experiments: [
                            'Kağıt Uçak Yarışı',
                            'Rüzgar Tüneli Deneyi',
                            'Paraşüt Tasarımı',
                          ],
                          color: Colors.blue,
                        ),
                        _buildExperimentCategory(
                          icon: Icons.science,
                          title: 'Bilim Deneyleri',
                          experiments: [
                            'Işık ve Gölge',
                            'Hava Basıncı',
                            'Yerçekimi Deneyi',
                          ],
                          color: Colors.green,
                        ),
                        _buildExperimentCategory(
                          icon: Icons.engineering,
                          title: 'Mühendislik Deneyleri',
                          experiments: [
                            'Rüzgar Değirmeni',
                            'Basit Makineler',
                            'Köprü Tasarımı',
                          ],
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Günün Deneyi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Günün Deneyi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDailyExperiment(
                          title: 'Kağıt Uçak Yarışı',
                          description: 'En uzağa giden kağıt uçağı tasarla!',
                          materials: ['Kağıt', 'Makas', 'Cetvel'],
                          steps: [
                            'Kağıdı katla',
                            'Kanatları ayarla',
                            'Test et ve uçur',
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentCategory({
    required IconData icon,
    required String title,
    required List<String> experiments,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...experiments.map((experiment) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border(
                top: BorderSide(
                  color: color.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  experiment,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildDailyExperiment({
    required String title,
    required String description,
    required List<String> materials,
    required List<String> steps,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gerekli Malzemeler:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...materials.map((material) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        material,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                const Text(
                  'Adımlar:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...steps.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }
} 