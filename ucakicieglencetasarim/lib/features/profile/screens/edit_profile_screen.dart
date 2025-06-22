import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ucakicieglencetasarim/features/profile/screens/profile_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Form değişkenleri
  String _username = '';
  String _email = '';
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';
  String _location = '';

  // Seçili işlem
  String? _selectedOperation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()?['username'] ?? '';
          _email = user.email ?? '';
          _location = userDoc.data()?['location'] ?? '';
        });
      }
    } catch (e) {
      print('Kullanıcı verileri yüklenirken hata: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      switch (_selectedOperation) {
        case 'username':
          await _firestore.collection('users').doc(user.uid).update({
            'username': _username,
          });
          break;

        case 'password':
          if (_newPassword.isNotEmpty) {
            if (_currentPassword.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mevcut şifrenizi girmelisiniz')),
              );
              return;
            }

            // Mevcut şifreyi doğrula
            final credential = EmailAuthProvider.credential(
              email: user.email!,
              password: _currentPassword,
            );
            await user.reauthenticateWithCredential(credential);

            // Yeni şifreyi ayarla
            await user.updatePassword(_newPassword);

            // Firestore'da şifre değişikliği tarihini güncelle
            await _firestore.collection('users').doc(user.uid).update({
              'lastPasswordChange': FieldValue.serverTimestamp(),
            });
          }
          break;

        case 'location':
          await _firestore.collection('users').doc(user.uid).update({
            'location': _location,
          });
          break;
      }

      if (mounted) {
        // Başarılı değişiklik mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _selectedOperation == 'username'
                      ? 'Kullanıcı adı başarıyla güncellendi'
                      : _selectedOperation == 'password'
                          ? 'Şifre başarıyla güncellendi'
                          : 'Konum başarıyla güncellendi',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        setState(() {
          _selectedOperation = null;
          _currentPassword = '';
          _newPassword = '';
          _confirmPassword = '';
        });
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Bir hata oluştu';
      
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Mevcut şifre yanlış';
          break;
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf. En az 6 karakter kullanın';
          break;
        case 'requires-recent-login':
          errorMessage = 'Güvenlik nedeniyle tekrar giriş yapmanız gerekiyor';
          break;
        default:
          errorMessage = e.message ?? 'Bir hata oluştu';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Hata: ${e.toString()}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildOperationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOperationCard(
          title: 'Kullanıcı Adını Değiştir',
          icon: Icons.person,
          operation: 'username',
        ),
        const SizedBox(height: 16),
        _buildOperationCard(
          title: 'Şifreyi Değiştir',
          icon: Icons.lock,
          operation: 'password',
        ),
        const SizedBox(height: 16),
        _buildOperationCard(
          title: 'Konum Ayarları',
          icon: Icons.location_on,
          operation: 'location',
        ),
      ],
    );
  }

  Widget _buildOperationCard({
    required String title,
    required IconData icon,
    required String operation,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedOperation = operation),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kullanıcı Adını Değiştir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(
                  labelText: 'Yeni Kullanıcı Adı',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kullanıcı adı gerekli';
                  }
                  return null;
                },
                onChanged: (value) => _username = value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Şifreyi Değiştir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                onChanged: (value) => _currentPassword = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Şifre en az 6 karakter olmalı';
                  }
                  return null;
                },
                onChanged: (value) => _newPassword = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre Tekrar',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                validator: (value) {
                  if (value != _newPassword) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
                onChanged: (value) => _confirmPassword = value,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konum Ayarları',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _location,
                decoration: InputDecoration(
                  labelText: 'Konum',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.location_on, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konum gerekli';
                  }
                  return null;
                },
                onChanged: (value) => _location = value,
              ),
              const SizedBox(height: 16),
              const Text(
                'Not: Konum bilginiz, size özel deneyler ve görevler sunmak için kullanılır.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedOperation == null ? 'Hesap Ayarları' : 'Değişiklik Yap'),
        backgroundColor: const Color(0xFF1A237E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedOperation != null) {
              setState(() {
                _selectedOperation = null;
                _currentPassword = '';
                _newPassword = '';
                _confirmPassword = '';
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedOperation == null) ...[
                    const SizedBox(height: 20),
                    _buildOperationSelection(),
                  ] else ...[
                    const SizedBox(height: 20),
                    if (_selectedOperation == 'username') _buildUsernameForm(),
                    if (_selectedOperation == 'password') _buildPasswordForm(),
                    if (_selectedOperation == 'location') _buildLocationForm(),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Değişiklikleri Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 