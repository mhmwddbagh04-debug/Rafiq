import 'package:flutter/material.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/otp_page.dart';
import '../presentation/auth/otp_page_2.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/auth/reset_password.dart';
import '../presentation/home/home_page.dart';
import '../presentation/language.dart';
import '../presentation/splash.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String chooseLanguage = '/choose-language';
  static const String register = '/register';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String otpConfirm = '/otp_confirm';
  static const String reset = '/reset';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashPage(),
      chooseLanguage: (context) => const ChooseLanguagePage(),
      register: (context) => const RegisterPage(),
      login: (context) => const LoginPage(),
      otp: (context) => const OtpPage(),
      otpConfirm: (context) => const OtpConfirmPage(),
      reset: (context) => const ResetPasswordPage(),
      home: (context) => const HomePage(),
    };
  }
}
