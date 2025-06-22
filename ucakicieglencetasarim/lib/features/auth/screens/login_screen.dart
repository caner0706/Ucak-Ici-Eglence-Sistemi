import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ucakicieglencetasarim/features/auth/screens/register_screen.dart';
import 'package:ucakicieglencetasarim/features/auth/screens/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
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
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Bir hata oluştu';
        
        if (e.code == 'user-not-found') {
          message = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı';
        } else if (e.code == 'wrong-password') {
          message = 'Hatalı şifre';
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
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Animasyonlu bulutlar (optimize edilmiş)
          ...List.generate(3, (index) {
            return Positioned(
              left: index * 200.0,
              top: 50.0 + (index * 100.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final cloudPosition = (_controller.value * 600.0) % (screenWidth + 200.0);
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
                        size: 60.0,
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
                        'Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SkyPals\'a giriş yapın ve gökyüzünde keşfe çıkın',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                      ),
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
                          return null;
                        },
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Şifremi Unuttum',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Login Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D47A1),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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
                      ),
                      const SizedBox(height: 12),
                      // Social Login Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            icon: Icons.g_mobiledata,
                            label: 'Google',
                            onTap: () {},
                          ),
                          const SizedBox(width: 12),
                          _buildSocialButton(
                            icon: Icons.apple,
                            label: 'Apple',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabınız yok mu?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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