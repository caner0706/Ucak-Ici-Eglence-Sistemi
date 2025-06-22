import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ucakicieglencetasarim/features/auth/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _controller;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifreler eşleşmiyor')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Auth ile kullanıcı oluştur
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Firestore'a kullanıcı bilgilerini kaydet
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'role': 'user',
          'profileCompleted': false,
          'settings': {
            'notifications': true,
            'darkMode': true,
            'language': 'tr'
          }
        });

        if (mounted) {
          // Başarılı kayıt sonrası ana sayfaya yönlendir
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Bir hata oluştu';
        
        if (e.code == 'weak-password') {
          message = 'Şifre çok zayıf';
        } else if (e.code == 'email-already-in-use') {
          message = 'Bu e-posta adresi zaten kullanımda';
        } else if (e.code == 'invalid-email') {
          message = 'Geçersiz e-posta adresi';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bir hata oluştu')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0D47A1), // Koyu mavi
                  Color(0xFF1976D2), // Orta mavi
                  Color(0xFF42A5F5), // Açık mavi
                  Color(0xFFBBDEFB), // Çok açık mavi
                ],
                stops: [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
          // Animasyonlu bulutlar
          ...List.generate(5, (index) {
            return Positioned(
              left: index * 150.0,
              top: 50.0 + (index * 80.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cloudPosition = (_controller.value * 800.0) % (screenWidth + 200.0);
                  return Transform.translate(
                    offset: Offset(
                      cloudPosition - 100.0,
                      0.0,
                    ),
                    child: Opacity(
                      opacity: 0.2 + (index * 0.15),
                      child: const Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 80.0,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          // Animasyonlu uçaklar
          ...List.generate(2, (index) {
            return Positioned(
              left: index * 300.0,
              top: 200.0 + (index * 150.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final planePosition = (_controller.value * 1000.0) % (screenWidth + 200.0);
                  return Transform.translate(
                    offset: Offset(
                      planePosition - 100.0,
                      (index * 20.0) + (sin(_controller.value * 2 * pi) * 20.0),
                    ),
                    child: Transform.rotate(
                      angle: sin(_controller.value * 2 * pi) * 0.1,
                      child: const Icon(
                        Icons.airplanemode_active,
                        color: Colors.white,
                        size: 40.0,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                      const SizedBox(height: 4),
                      const Text(
                        'SkyPals\'a katılın ve gökyüzünde keşfe çıkın',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                      const SizedBox(height: 20),
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Ad Soyad',
                          prefixIcon: const Icon(Icons.person, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen adınızı ve soyadınızı girin';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-posta',
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen e-posta adresinizi girin';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi girin';
                          }
                          if (value.length < 6) {
                            return 'Şifre en az 6 karakter olmalıdır';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 8),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Şifre Tekrar',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: !_isConfirmPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen şifrenizi tekrar girin';
                          }
                          if (value != _passwordController.text) {
                            return 'Şifreler eşleşmiyor';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 12),
                      // Register Button
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 12),
                      // Divider
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white30)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'veya',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white30)),
                        ],
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 12),
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onTap: () {},
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.3, end: 0)
                            .then()
                            .shimmer(duration: 1.seconds)
                            .then()
                            .shake(duration: 400.ms, hz: 4),
                          const SizedBox(width: 12),
                          _buildSocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onTap: () {},
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: 0.3, end: 0)
                            .then()
                            .shimmer(duration: 1.seconds)
                            .then()
                            .shake(duration: 400.ms, hz: 4),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Zaten hesabınız var mı?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 