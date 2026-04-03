import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xff6A8FB6);
  static const Color darkBlue = Color(0xff153E90);
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  // ================================
  // Light Mode
  // ================================
  static const Color backgroundLight = Color(0xffDFF6FA);
  static const Color cardLight = white;
  static const Color mainTextLight = Color(0xff1C2B4A);
  static const Color secTextLight = grey;
  static const Color buttonLight = darkBlue;
  static const List<Color> gradientLight = [
    Color(0xffDCF8FC),
    Color(0xFFFFFFFF),
  ];

  // ================================
  // Dark Mode
  // ================================
  static const Color backgroundDark = Color(0xff0D1B3E);
  static const Color cardDark =white;
  static const Color mainTextDark = white;
  static const Color secTextDark = grey;
  static const Color buttonDark = primaryBlue;
  static const List<Color> gradientDark = [
    Color(0xff173E90),
    Color(0xff0D1B3E),
  ];
}
