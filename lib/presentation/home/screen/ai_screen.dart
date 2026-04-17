import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.gradientLight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Image.asset('assets/image/logo.png', height: 40),
                    const SizedBox(width: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "Ai ",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: "chat",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: Colors.blue),
                  ],
                ),
              ),

              // Chat Area
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildChatBubble("What can I help with", isAi: true),
                    _buildChatBubble("", isAi: false),
                    _buildChatBubble("", isAi: true),
                    _buildChatBubble("", isAi: false),
                    _buildChatBubble("", isAi: true),
                  ],
                ),
              ),

              // Bottom Input Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300), // أضفنا الحواف هنا
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "ask anything...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.send_rounded, color: Color(0xff1C2B4A)),
                    const SizedBox(width: 10),
                    const Icon(Icons.mic_none_rounded, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, {required bool isAi}) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 250,
          minHeight: 60,
        ),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isAi ? null : Border.all(color: Colors.black45),
          boxShadow: isAi
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(text, style: const TextStyle(color: Colors.black54)),
      ),
    );
  }
}
