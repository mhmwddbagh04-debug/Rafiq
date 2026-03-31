import 'dart:async';

import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/choose-language');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xffDCF8FC), Color(0xFFFFFFFF)],
          ),
        ),
        child: Center(
          child: Column(
            spacing: 18,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/image/logo.png'),
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  children: [
                    TextSpan(
                      text: '202',
                      style: TextStyle(color: Color(0xFF000000), fontSize: 32),
                    ),
                    TextSpan(
                      text: '6',
                      style: TextStyle(color: Color(0xFF234CE4), fontSize: 32),
                    ),
                  ],
                ),
              ),

              Text(
                'لأن صحتك تستحق \n رفيقًا تثق به',
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF0D1B3D),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              Text(
                'Because your health deserves a  \n  companion you can trust',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF051D40),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
