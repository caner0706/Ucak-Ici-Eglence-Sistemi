import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedCurrency = 'TL';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ayarlar',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                        const SizedBox(height: 8),
                        const Text(
                          'Uygulama tercihlerinizi buradan yönetebilirsiniz',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                  // Bildirim Ayarları
                  _buildSettingsSection(
                    title: 'Bildirimler',
                    children: [
                      _buildSettingsItem(
                        icon: Icons.notifications,
                        title: 'Bildirimler',
                        subtitle: 'Uçuş bildirimlerini al',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF0D47A1),
                        ),
                      ),
                      _buildSettingsItem(
                        icon: Icons.email,
                        title: 'E-posta Bildirimleri',
                        subtitle: 'Promosyon ve güncellemeleri al',
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: const Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                  // Görünüm Ayarları
                  _buildSettingsSection(
                    title: 'Görünüm',
                    children: [
                      _buildSettingsItem(
                        icon: Icons.dark_mode,
                        title: 'Karanlık Mod',
                        subtitle: 'Karanlık temayı kullan',
                        trailing: Switch(
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            setState(() {
                              _darkModeEnabled = value;
                            });
                          },
                          activeColor: const Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                  // Dil ve Para Birimi
                  _buildSettingsSection(
                    title: 'Dil ve Para Birimi',
                    children: [
                      _buildSettingsItem(
                        icon: Icons.language,
                        title: 'Dil',
                        subtitle: _selectedLanguage,
                        trailing: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: const Color(0xFF1A237E),
                          style: const TextStyle(color: Colors.white),
                          underline: Container(),
                          items: ['Türkçe', 'English', 'Deutsch', 'Français']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedLanguage = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      _buildSettingsItem(
                        icon: Icons.attach_money,
                        title: 'Para Birimi',
                        subtitle: _selectedCurrency,
                        trailing: DropdownButton<String>(
                          value: _selectedCurrency,
                          dropdownColor: const Color(0xFF1A237E),
                          style: const TextStyle(color: Colors.white),
                          underline: Container(),
                          items: ['TL', 'USD', 'EUR', 'GBP']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCurrency = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  // Hesap Ayarları
                  _buildSettingsSection(
                    title: 'Hesap',
                    children: [
                      _buildSettingsItem(
                        icon: Icons.security,
                        title: 'Gizlilik',
                        subtitle: 'Gizlilik ayarlarını yönet',
                        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        icon: Icons.help,
                        title: 'Yardım ve Destek',
                        subtitle: 'Sorularınız için bize ulaşın',
                        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                        onTap: () {},
                      ),
                      _buildSettingsItem(
                        icon: Icons.info,
                        title: 'Hakkında',
                        subtitle: 'Uygulama versiyonu 1.0.0',
                        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
} 