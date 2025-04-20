import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'experiments_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          // Ana içerik
          SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                // Ana Sayfa
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Başlık
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Text(
                              'Gökyüzü Akademisi',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(duration: 600.ms),
                            const SizedBox(height: 8),
                            const Text(
                              'Hezarfen\'in Kanatlarında Öğren!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ).animate().fadeIn(duration: 600.ms),
                          ],
                        ),
                      ),
                      // AR/VR Seçenekleri
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Eğitim Aktiviteleri',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildExperienceCard(
                              icon: Icons.science,
                              title: 'Bilim Deneyleri',
                              description: 'Havacılık ve bilim deneyleri yap',
                              onTap: () {},
                            ),
                            _buildExperienceCard(
                              icon: Icons.engineering,
                              title: 'Uçak Tasarımı',
                              description: 'Kendi uçağını tasarla ve test et',
                              onTap: () {},
                            ),
                            _buildExperienceCard(
                              icon: Icons.art_track,
                              title: 'Sanat Atölyesi',
                              description: 'Origami ve boyama aktiviteleri',
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Aktif Görevler
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Günlük Görevler',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMissionCard(
                              title: 'Rüzgar Değirmeni Yapımı',
                              progress: 0.6,
                              reward: 'Yeşil Mühendis Rozeti',
                            ),
                            _buildMissionCard(
                              title: 'Işık Deneyi',
                              progress: 0.3,
                              reward: 'Mini Bilim İnsanı Rozeti',
                            ),
                            _buildMissionCard(
                              title: 'Origami Uçak',
                              progress: 0.8,
                              reward: 'Sanatçı Kâşif Rozeti',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Hezarfen'in Maceraları
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hezarfen\'in Maceraları',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStoryText(
                              title: 'İlk Uçuş',
                              description: '1632 yılında Galata Kulesi\'nden Üsküdar\'a kadar uçarak tarihe geçti. Bu uçuş, insanlık tarihinin ilk başarılı uçuş denemelerinden biri olarak kabul edilir. Hezarfen, kendi tasarladığı kanatlarla bu tarihi uçuşu gerçekleştirdi.',
                            ),
                            _buildStoryText(
                              title: 'Bilim İnsanı',
                              description: 'Hezarfen Ahmed Çelebi, matematik, astronomi ve fizik alanlarında çalışmalar yaptı. Uçuş denemelerinden önce kuşların uçuşunu uzun süre gözlemledi ve bu gözlemlerini bilimsel çalışmalarına yansıttı.',
                            ),
                            _buildStoryText(
                              title: 'Gençlik Yılları',
                              description: 'İstanbul\'da doğan Hezarfen, genç yaşta bilime merak sardı. Kuşların uçuşunu inceleyerek kendi kanatlarını tasarladı. Bu dönemde yaptığı çalışmalar, onun gelecekteki başarısının temelini oluşturdu.',
                            ),
                            _buildStoryText(
                              title: 'Büyük Başarı',
                              description: 'Uçuşundan sonra Sultan IV. Murad tarafından ödüllendirildi. Bu başarı, Osmanlı İmparatorluğu\'nda bilim ve teknolojinin gelişimine katkı sağladı. Hezarfen\'in çalışmaları, havacılık tarihinde önemli bir dönüm noktası oldu.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Deneyler
                const ExperimentsScreen(),
                // Profil
                const ProfileScreen(),
                // Ayarlar
                const SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Akademi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.science),
              label: 'Deneyler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        onTap: onTap,
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildMissionCard({
    required String title,
    required double progress,
    required String reward,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ödül: $reward',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Devam Et',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStoryText({
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }
} 