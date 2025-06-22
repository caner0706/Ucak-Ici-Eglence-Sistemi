import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Kullanıcı verileri
  String _username = '';
  String _level = '1';
  String _title = 'Gökyüzü Kâşifi';
  int _completedTasks = 0;
  int _earnedBadges = 0;
  int _totalPoints = 0;
  String _email = '';
  String _location = '';
  DateTime _joinDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _loadUserData();
    _setupUserDataListener();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Kullanıcı verilerini dinle
  void _setupUserDataListener() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _username = data['username'] ?? '';
          _level = data['level'] ?? '1';
          _title = data['title'] ?? 'Gökyüzü Kâşifi';
          _location = data['location'] ?? 'Belirtilmemiş';
          _joinDate = (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        });
      }
    });

    // Tamamlanan görevleri dinle
    _firestore
        .collection('completed_tasks')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      int totalPoints = 0;
      for (var doc in snapshot.docs) {
        totalPoints += doc.data()['points'] as int? ?? 0;
      }

      setState(() {
        _completedTasks = snapshot.docs.length;
        _earnedBadges = _completedTasks;
        _totalPoints = totalPoints;
      });
    });
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Kullanıcı bilgilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _username = data['username'] ?? '';
          _level = data['level'] ?? '1';
          _title = data['title'] ?? 'Gökyüzü Kâşifi';
          _email = user.email ?? '';
          _location = data['location'] ?? 'Belirtilmemiş';
          _joinDate = (data['joinDate'] as Timestamp?)?.toDate() ?? DateTime.now();
        });
      }

      // Tamamlanan görevleri say
      final completedTasksSnapshot = await _firestore
          .collection('completed_tasks')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Toplam puanları hesapla
      int totalPoints = 0;
      for (var doc in completedTasksSnapshot.docs) {
        totalPoints += doc.data()['points'] as int? ?? 0;
      }

      setState(() {
        _completedTasks = completedTasksSnapshot.docs.length;
        _earnedBadges = _completedTasks; // Rozet sayısı görev sayısıyla aynı
        _totalPoints = totalPoints;
      });
    } catch (e) {
      print('Kullanıcı verileri yüklenirken hata: $e');
    }
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
                  // Üst Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Profil Başlığı
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profil Fotoğrafı ve Seviye
                        Stack(
                          children: [
                            // Profil Fotoğrafı
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(70),
                                child: Image.asset(
                                  'assets/images/Mete1.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Seviye Rozeti
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _level,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(duration: 600.ms),
                        const SizedBox(height: 16),
                        // Kullanıcı Adı
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        // Kullanıcı Seviyesi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.3),
                                Colors.orange.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                  // İstatistikler
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'İstatistikler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatistic(
                              icon: Icons.task_alt,
                              value: _completedTasks.toString(),
                              label: 'Görev',
                              color: Colors.green,
                            ),
                            _buildStatistic(
                              icon: Icons.workspace_premium,
                              value: _earnedBadges.toString(),
                              label: 'Rozet',
                              color: Colors.amber,
                            ),
                            _buildStatistic(
                              icon: Icons.stars,
                              value: _totalPoints.toString(),
                              label: 'Puan',
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                  // Kullanıcı Bilgileri
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kullanıcı Bilgileri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildInfoRow(
                          icon: Icons.email,
                          label: 'E-posta',
                          value: _email,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Katılım Tarihi',
                          value: '${_joinDate.day} ${_getMonthName(_joinDate.month)} ${_joinDate.year}',
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          label: 'Konum',
                          value: _location,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistic({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Ay ismini döndüren yardımcı fonksiyon
  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
} 