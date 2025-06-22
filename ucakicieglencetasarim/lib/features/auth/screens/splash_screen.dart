import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 4 saniye sonra login ekranına yönlendir
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
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
          // Animasyonlu uçaklar
          ...List.generate(3, (index) {
            return Positioned(
              left: index * 200.0,
              top: 150.0 + (index * 100.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final planePosition = (_controller.value * 1200.0) % (screenWidth + 300.0);
                  return Transform.translate(
                    offset: Offset(
                      planePosition - 150.0,
                      (index * 30.0) + (sin(_controller.value * 3 * pi) * 30.0),
                    ),
                    child: Transform.rotate(
                      angle: sin(_controller.value * 3 * pi) * 0.2,
                      child: Icon(
                        Icons.airplanemode_active,
                        color: Colors.white.withOpacity(0.8),
                        size: 50.0,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Animasyonlu gezegenler
          ...List.generate(2, (index) {
            return Positioned(
              left: (index * 300.0) + 100.0,
              top: 300.0 + (index * 200.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (sin(_controller.value * 2 * pi + index) * 0.1),
                    child: Opacity(
                      opacity: 0.6 + (sin(_controller.value * 2 * pi + index) * 0.2),
                      child: Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? Colors.orange.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Animasyonlu balonlar
          ...List.generate(5, (index) {
            final colors = [
              Colors.red.withOpacity(0.6),
              Colors.blue.withOpacity(0.6),
              Colors.green.withOpacity(0.6),
              Colors.yellow.withOpacity(0.6),
              Colors.purple.withOpacity(0.6),
            ];
            return Positioned(
              left: (index * 200.0) % MediaQuery.of(context).size.width,
              top: 100.0 + (index * 150.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final balloonPosition = (_controller.value * 800.0) % (screenHeight + 200.0);
                  return Transform.translate(
                    offset: Offset(
                      (index * 20.0) + (sin(_controller.value * 2 * pi + index) * 20.0),
                      -balloonPosition,
                    ),
                    child: Transform.rotate(
                      angle: sin(_controller.value * 2 * pi + index) * 0.1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.0,
                              ),
                            ),
                          ),
                          Container(
                            width: 2.0,
                            height: 20.0,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Ana içerik
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animasyonu
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.airplanemode_active,
                      color: Colors.white,
                      size: 60,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scaleXY(duration: 2.seconds, begin: 0.8, end: 1.2)
                      .then()
                      .scaleXY(duration: 2.seconds, begin: 1.2, end: 0.8),
                  const SizedBox(height: 40),
                  const Text(
                    'SkyPals',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scaleXY(begin: 0.8, end: 1.0)
                      .then()
                      .shimmer(duration: 1.seconds),
                  const SizedBox(height: 20),
                  const Text(
                    'Gökyüzünde Keşfe Çık',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 40),
                  // Yükleme animasyonu
                  Container(
                    width: 200,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: 200 * _controller.value,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 