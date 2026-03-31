import 'package:Rafiq/presentation/auth/login_page.dart';
import 'package:Rafiq/presentation/auth/otp_page.dart';
import 'package:Rafiq/presentation/auth/otp_page_2.dart';
import 'package:Rafiq/presentation/auth/register_page.dart';
import 'package:Rafiq/presentation/auth/reset_password.dart';
import 'package:Rafiq/presentation/home/home_page.dart';
import 'package:Rafiq/presentation/language.dart';
import 'package:Rafiq/presentation/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/choose-language': (context) => const ChooseLanguagePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
         '/otp': (context) => const OtpPage(),
         '/otp_confirm': (context) => const OtpConfirmPage(),
         '/reset': (context) => const ResetPasswordPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
