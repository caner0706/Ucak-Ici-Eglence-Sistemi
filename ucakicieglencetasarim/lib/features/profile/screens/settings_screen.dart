import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çıkış yapılırken bir hata oluştu')),
        );
      }
    }
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E).withOpacity(0.95),
                const Color(0xFF0D47A1).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.privacy_tip,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Gizlilik Politikası',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Veri Toplama ve Kullanım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Kullanıcı adı ve e-posta adresi gibi temel bilgileriniz güvenli bir şekilde saklanır.\n'
                  '• Konum bilgisi sadece siz izin verdiğinizde kullanılır.\n'
                  '• Görev tamamlama ve puan bilgileriniz sadece size özeldir.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Veri Güvenliği',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Tüm verileriniz Firebase güvenlik sistemi ile korunur.\n'
                  '• Şifreleriniz her zaman şifrelenmiş olarak saklanır.\n'
                  '• Düzenli güvenlik güncellemeleri yapılır.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Anladım',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E).withOpacity(0.95),
                const Color(0xFF0D47A1).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.help_outline,
                        color: Colors.green,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Yardım ve Destek',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Sık Sorulan Sorular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHelpItem(
                  question: 'Nasıl puan kazanabilirim?',
                  answer: 'Görevleri tamamlayarak ve deneyleri başarıyla bitirerek puan kazanabilirsiniz.',
                ),
                _buildHelpItem(
                  question: 'Rozetler nasıl kazanılır?',
                  answer: 'Belirli görevleri tamamladığınızda ve başarılar elde ettiğinizde rozetler kazanırsınız.',
                ),
                _buildHelpItem(
                  question: 'Şifremi unuttum, ne yapmalıyım?',
                  answer: 'Giriş ekranındaki "Şifremi Unuttum" seçeneğini kullanarak şifrenizi sıfırlayabilirsiniz.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'İletişim',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sorun yaşıyorsanız veya yardıma ihtiyacınız varsa:\n'
                  '• E-posta: destek@ucakicieglence.com\n'
                  '• Telefon: +90 (212) 123 45 67\n'
                  '• Çalışma Saatleri: Hafta içi 09:00 - 18:00',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Anladım',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E).withOpacity(0.95),
                const Color(0xFF0D47A1).withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Uygulama Hakkında',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.flight,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Uçak İçi Eğlence',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Versiyon 1.0.0',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Uygulama Hakkında',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Uçak İçi Eğlence, uçuş sürenizi daha keyifli hale getirmek için tasarlanmış bir eğlence ve öğrenme platformudur. Uçuş sırasında eğlenceli deneyler yapabilir, görevleri tamamlayabilir ve rozetler kazanabilirsiniz.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Özellikler',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  icon: Icons.science,
                  title: 'Eğlenceli Deneyler',
                  description: 'Uçuş sırasında yapabileceğiniz ilginç deneyler',
                ),
                _buildFeatureItem(
                  icon: Icons.emoji_events,
                  title: 'Görevler ve Rozetler',
                  description: 'Tamamladıkça rozet kazandığınız görevler',
                ),
                _buildFeatureItem(
                  icon: Icons.leaderboard,
                  title: 'Puan Sistemi',
                  description: 'Deneyler ve görevlerle puan kazanın',
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Anladım',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q: $question',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'A: $answer',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                  const Text(
                    'Ayarlar',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  const Text(
                    'Uygulama tercihlerini yönet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      decoration: TextDecoration.none,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 32),
                  // Bildirim Ayarları
                  _buildSettingsSection(
                    title: 'Bildirimler',
                    icon: Icons.notifications,
                    color: Colors.blue,
                    children: [
                      _buildSwitchTile(
                        title: 'Deney Bildirimleri',
                        subtitle: 'Yeni deneyler ve güncellemeler',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      _buildSwitchTile(
                        title: 'Başarı Bildirimleri',
                        subtitle: 'Kazanılan rozetler ve ödüller',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Görünüm Ayarları
                  _buildSettingsSection(
                    title: 'Görünüm',
                    icon: Icons.palette,
                    color: Colors.purple,
                    children: [
                      _buildSwitchTile(
                        title: 'Karanlık Mod',
                        subtitle: 'Göz yorgunluğunu azalt',
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Dil ve Para Birimi
                  _buildSettingsSection(
                    title: 'Dil ve Para Birimi',
                    icon: Icons.language,
                    color: Colors.green,
                    children: [
                      _buildDropdownTile(
                        title: 'Dil',
                        value: _selectedLanguage,
                        items: ['Türkçe', 'English', 'Deutsch', 'Français'],
                        onChanged: (value) {
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                      ),
                      _buildDropdownTile(
                        title: 'Para Birimi',
                        value: _selectedCurrency,
                        items: ['TL', 'USD', 'EUR', 'GBP'],
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Hesap Ayarları
                  _buildSettingsSection(
                    title: 'Hesap',
                    icon: Icons.account_circle,
                    color: Colors.orange,
                    children: [
                      _buildSettingsTile(
                        title: 'Gizlilik',
                        subtitle: 'Veri ve gizlilik ayarları',
                        icon: Icons.privacy_tip,
                        onTap: _showPrivacyDialog,
                      ),
                      _buildSettingsTile(
                        title: 'Yardım',
                        subtitle: 'Sık sorulan sorular ve destek',
                        icon: Icons.help,
                        onTap: _showHelpDialog,
                      ),
                      _buildSettingsTile(
                        title: 'Uygulama Hakkında',
                        subtitle: 'Versiyon 1.0.0',
                        icon: Icons.info,
                        onTap: _showAboutDialog,
                      ),
                      _buildSettingsTile(
                        title: 'Çıkış Yap',
                        subtitle: 'Hesabınızdan güvenli çıkış yapın',
                        icon: Icons.logout,
                        onTap: _signOut,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: SwitchListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          trailing: SizedBox(
            width: 80,
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1A237E),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              underline: Container(),
              isExpanded: true,
              isDense: true,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white70,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              decoration: TextDecoration.none,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
} 