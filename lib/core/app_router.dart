import 'package:Rafiq/presentation/home/screen/ai_screen.dart';
import 'package:Rafiq/presentation/product/item_screen.dart';
import 'package:Rafiq/presentation/product/all_products_screen.dart'; // سننشئ هذا الملف
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
  static const String ai = '/ai';
  static const String item = '/item';
  static const String allProducts = '/all-products';

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
      ai: (context) => const AiScreen(),
      item: (context) => const ItemScreen(),
      allProducts: (context) => const AllProductsScreen(),
    };
  }
}
