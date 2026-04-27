import 'dart:async';
import 'package:Rafiq/core/api/token_manager.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final token = await TokenManager.getToken();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (token != null && token.isNotEmpty) {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.chooseLanguage);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // التحقق من وضع النظام (ليلي أم نهاري)
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode ? AppColors.gradientDark : AppColors.gradientLight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image/logo.png', height: 120),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                          text: '202',
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        TextSpan(
                          text: '6',
                          style: TextStyle(color: isDarkMode ? AppColors.primaryBlue : const Color(0xFF234CE4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لأن صحتك تستحق \n رفيقًا تثق به',
                    style: TextStyle(
                      fontSize: 26,
                      color: isDarkMode ? Colors.white : AppColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Because your health deserves a \n companion you can trust',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? Colors.white70 : AppColors.mainTextLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDarkMode ? Colors.white24 : AppColors.primaryBlue.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
