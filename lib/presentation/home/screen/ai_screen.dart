import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"text": "مرحباً! أنا رفيق الذكي، كيف يمكنني مساعدتك في رحلتك اليوم؟", "isAi": true},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"text": _controller.text, "isAi": false});
      _controller.clear();
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            "text": "سأقوم بالبحث عن أفضل الخيارات المتاحة لك فوراً.. 🚀",
            "isAi": true,
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية الملونة المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE0F2F1),
                  Color(0xFFE8EAF6),
                  Color(0xFFF3E5F5),
                ],
              ),
            ),
          ),
          
          // 2. محتوى الصفحة
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildGlassBubble(msg["text"], msg["isAi"]);
                    },
                  ),
                ),
                _buildModernInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Rafiq AI",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E)),
              ),
              Text("Smart Assistant", style: TextStyle(fontSize: 12, color: Colors.indigo)),
            ],
          ),
          const Spacer(),
          const CircleAvatar(
            backgroundColor: Colors.white54,
            child: Icon(Icons.bolt, color: Colors.amber),
          )
        ],
      ),
    );
  }

  Widget _buildGlassBubble(String text, bool isAi) {
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAi ? 0 : 20),
            bottomRight: Radius.circular(isAi ? 20 : 0),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isAi 
                    ? Colors.white.withOpacity(0.7) 
                    : const Color(0xFF1A237E).withOpacity(0.8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isAi ? Colors.black87 : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type something...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 50,
              width: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3949AB), Color(0xFF1A237E)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.indigo, blurRadius: 10, offset: Offset(0, 4))
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
