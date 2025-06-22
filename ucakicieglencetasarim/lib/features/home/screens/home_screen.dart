import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/settings_screen.dart';
import 'basic_labs/science_lab_screen.dart';
import 'design/design_workshop_screen.dart';
import 'design/flight_simulation_screen.dart';
import 'education/basic_education_screen.dart';
import 'flight_simulator/flight_simulator_screen.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showWelcome = true;
  bool _showAcademy = false;
  int _selectedIndex = 0;
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // 3 saniye sonra akademi ekranına geç
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showWelcome = false;
        _showAcademy = true;
      });
    });

    // Örnek aktiviteleri ekle
    _initializeActivities();
  }

  void _initializeActivities() {
    final activities = [
      Activity(
        id: 'light_experiment',
        title: 'Işık Deneyi',
        description: 'Işığın yansıma ve kırılması',
        progress: 0.6,
        icon: Icons.lightbulb,
        color: Colors.yellow,
        category: 'laboratory',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Activity(
        id: 'origami_airplane',
        title: 'Origami Uçak',
        description: 'Kağıttan uçak tasarımı',
        progress: 0.8,
        icon: Icons.art_track,
        color: Colors.orange,
        category: 'design',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Activity(
        id: 'air_pressure',
        title: 'Hava Basıncı',
        description: 'Hava basıncının etkileri',
        progress: 0.3,
        icon: Icons.air,
        color: Colors.blue,
        category: 'education',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    for (var activity in activities) {
      _activityService.addActivity(activity);
    }
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
        // Karşılama ekranı
        if (_showWelcome)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Karşılama fotoğrafı
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.35,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/Hezarfen1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(duration: 800.ms)
                  .scale(duration: 800.ms),
                const SizedBox(height: 40),
                // Başlık
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                  'Gökyüzü Akademisine\nHoş Geldin!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                      fontWeight: FontWeight.w300,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                      letterSpacing: 1,
                      height: 1.3,
                    ),
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: 20),
                // Alt başlık
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                  'Bilim ve hayal gücünün\nsınırsız dünyasına hazır mısın?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                      fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    decoration: TextDecoration.none,
                      letterSpacing: 0.5,
                      height: 1.4,
                    ),
                  ),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        // Ana içerik
        if (_showAcademy)
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          // Gökyüzü Akademisi
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gökyüzü Akademisi',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                    ),
                                  ).animate().fadeIn(duration: 600.ms),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Hezarfen\'in Kanatlarında Öğren!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                      decoration: TextDecoration.none,
                                    ),
                                  ).animate().fadeIn(duration: 600.ms),
                                  const SizedBox(height: 32),
                                  _buildAcademyMap(),
                                ],
                              ),
                            ),
                          ),
                          // Profil
                          const ProfileScreen(),
                          // Ayarlar
                          const SettingsScreen(),
                        ],
                      ),
                    ),
                    // Bottom Navigation Bar
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
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
                            icon: Icon(Icons.school),
                            label: 'Akademi',
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
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAcademyMap() {
    return Column(
      children: [
        _buildMapItem(
          title: 'Temel Eğitim',
          description: 'Havacılığın temellerini öğren',
          icon: Icons.school,
          color: Colors.blue,
          isCompleted: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BasicEducationScreen(),
              ),
            );
          },
        ),
        _buildMapItem(
          title: 'Bilim Laboratuvarı',
          description: 'Deneylerle öğren',
          icon: Icons.science,
          color: Colors.green,
          isCompleted: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScienceLabScreen(),
              ),
            );
          },
        ),
        _buildMapItem(
          title: 'Tasarım Atölyesi',
          description: 'Kendi uçağını tasarla',
          icon: Icons.architecture,
          color: Colors.orange,
          isCompleted: false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DesignWorkshopScreen(),
              ),
            );
          },
        ),
        _buildExperienceCard(
          title: 'Uçuş Simülatörü',
          description: 'Gerçekçi uçuş deneyimi yaşa',
          icon: Icons.flight,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FlightSimulatorScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMapItem({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isCompleted ? Icons.check_circle : Icons.lock,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildExperienceCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }
} 