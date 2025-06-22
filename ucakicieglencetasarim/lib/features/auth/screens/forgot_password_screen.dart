import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _controller;
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
    _emailController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Bir hata oluştu';
        
        if (e.code == 'user-not-found') {
          message = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
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
                      const Icon(
                        Icons.lock_reset,
                        color: Colors.white,
                        size: 80,
                      ).animate().fadeIn(duration: 600.ms).scale(),
                      const SizedBox(height: 24),
                      const Text(
                        'Şifremi Unuttum',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                      const SizedBox(height: 8),
                      const Text(
                        'E-posta adresinizi girin, size şifre sıfırlama bağlantısı gönderelim',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 24),
                      // Reset Button
                      ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0D47A1),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Şifremi Sıfırla',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      const SizedBox(height: 16),
                      // Back to Login
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Giriş sayfasına dön',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
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
} 