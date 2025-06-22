import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';

class StructureLabScreen extends StatefulWidget {
  const StructureLabScreen({super.key});

  @override
  State<StructureLabScreen> createState() => _StructureLabScreenState();
}

class _StructureLabScreenState extends State<StructureLabScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    try {
      await _audioPlayer.setAsset('assets/Voices/StructureLabScreen/StructureLabScreen${_currentPage + 1}.mp3');
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
                    Expanded(
                      child: Text(
                        'Yapı Laboratuvarı',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _toggleAudio,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) async {
                    if (_isPlaying) {
                      await _audioPlayer.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    }
                    
                    setState(() {
                      _currentPage = index;
                    });
                    
                    await _loadAudio();
                    
                    if (_isPlaying) {
                      await _audioPlayer.play();
                    }
                  },
                  children: [
                    _buildPage(
                      title: 'Yapısal Analiz',
                      content: 'Uçak yapısı, güvenlik ve performans için kritik öneme sahiptir. Gövde, kanatlar ve kuyruk gibi ana bileşenlerin tasarımı ve malzeme seçimi, uçuş karakteristiklerini belirler. Yapısal analiz, güvenli uçuş için önemlidir.',
                      image: Icons.architecture,
                      animation: 'Yapı Analizi',
                    ),
                    _buildPage(
                      title: 'Malzeme Bilimi',
                      content: 'Uçak yapısında kullanılan malzemeler, hafiflik ve dayanıklılık arasında denge sağlar. Alüminyum alaşımları, kompozit malzemeler ve titanyum, modern uçaklarda yaygın olarak kullanılır. Malzeme seçimi, uçuş performansını etkiler.',
                      image: Icons.science,
                      animation: 'Malzeme Testi',
                    ),
                    _buildPage(
                      title: 'Yapısal Testler',
                      content: 'Uçak yapısı, çeşitli testlere tabi tutulur. Statik testler, yorulma testleri ve çarpışma testleri, yapının güvenliğini ve dayanıklılığını değerlendirir. Bu testler, uçuş güvenliği için gereklidir.',
                      image: Icons.build,
                      animation: 'Test Analizi',
                    ),
                    _buildPage(
                      title: 'Yapısal İyileştirmeler',
                      content: 'Uçak yapısında sürekli iyileştirmeler yapılır. Aerodinamik optimizasyon, ağırlık azaltma ve malzeme geliştirmeleri, uçuş performansını artırır. Bu iyileştirmeler, yakıt verimliliği ve çevresel etkiyi iyileştirir.',
                      image: Icons.trending_up,
                      animation: 'İyileştirme Analizi',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < 3) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context, true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < 3 ? 'Devam Et' : 'Deneyi Tamamla',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
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

  Widget _buildPage({
    required String title,
    required String content,
    required IconData image,
    required String animation,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  image,
                  size: 100,
                  color: Colors.white,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(duration: 600.ms),
            ),
            const SizedBox(height: 32),
            Text(
              content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                height: 1.5,
                decoration: TextDecoration.none,
              ),
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Center(
              child: Text(
                animation,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 