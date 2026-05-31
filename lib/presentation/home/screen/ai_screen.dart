import 'package:flutter/material.dart';
import 'package:Rafiq/core/api/ai_service.dart';
import 'package:Rafiq/core/app_colors.dart';
import 'package:icons_plus/icons_plus.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatSession {
  final String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.title,
    required this.messages,
  });
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AiService();

  bool _isLoading = false;

  List<ChatSession> chats = [
    ChatSession(
      title: "محادثة جديدة",
      messages: [],
    ),
  ];

  int currentChat = 0;

  List<ChatMessage> get messages => chats[currentChat].messages;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );

      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final response = await _aiService.askAi(text);

      setState(() {
        messages.add(
          ChatMessage(
            text: response,
            isUser: false,
          ),
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add(
          ChatMessage(
            text: "حدث خطأ أثناء الاتصال بالخادم. يرجى المحاولة مرة أخرى.",
            isUser: false,
          ),
        );

        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _createNewChat() {
    setState(() {
      chats.insert(
        0,
        ChatSession(
          title: "محادثة جديدة",
          messages: [],
        ),
      );
      currentChat = 0;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark ? AppColors.gradientDark : AppColors.gradientLight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: _buildDrawer(isDark),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.darkBlue),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.magic_star_bold, size: 20, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                "رفيق الذكي",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.darkBlue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: messages.isEmpty ? _buildEmptyState(isDark) : _buildChatList(isDark),
            ),
            if (_isLoading) _buildGeminiLoading(isDark),
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.darkBlue, AppColors.primaryBlue],
                ).createShader(bounds),
                child: const Icon(
                  Iconsax.magic_star_bold,
                  size: 70,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "مرحباً بك، أنا رفيق",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "كيف يمكنني أن أجعل يومك أفضل؟",
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            _buildSuggestionChips(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(bool isDark) {
    final suggestions = [
      "نصائح لزيادة المناعة 🛡️",
      "بدائل طبيعية للصداع 💊",
      "فوائد الزنك للجسم ✨",
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) => InkWell(
        onTap: () {
          _controller.text = s.split(' ').sublist(0, s.split(' ').length - 1).join(' ');
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: Text(
            s,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.darkBlue,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildChatList(bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildGeminiMessage(msg, isDark);
      },
    );
  }

  Widget _buildGeminiMessage(ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (msg.isUser) ...[
                const Spacer(),
                const Text(
                  "أنت",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryBlue,
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ] else ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.darkBlue, AppColors.primaryBlue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.magic_star_outline, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 8),
                const Text(
                  "رفيق",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkBlue),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? (isDark ? AppColors.darkBlue : AppColors.darkBlue.withOpacity(0.8))
                    : (isDark ? AppColors.cardDark : Colors.white.withOpacity(0.9)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(msg.isUser ? 20 : 5),
                  bottomRight: Radius.circular(msg.isUser ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Text(
                msg.text,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: msg.isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiLoading(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.primaryBlue]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.magic_star_outline, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 12),
              const Text("رفيق يفكر...", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 12),
          _buildLoadingBar(isDark, 0.7),
          const SizedBox(height: 8),
          _buildLoadingBar(isDark, 0.5),
        ],
      ),
    );
  }

  Widget _buildLoadingBar(bool isDark, double widthFactor) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: 8,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 1.5),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Positioned.fill(
                      left: constraints.maxWidth * value,
                      child: Container(
                        width: constraints.maxWidth * 0.4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.primaryBlue.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.magic_star_outline, color: AppColors.primaryBlue),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                textDirection: TextDirection.rtl,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "اسأل رفيق عن أي دواء أو نصيحة...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: const BoxDecoration(
                color: AppColors.darkBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 20, right: 20, left: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.primaryBlue]),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.message_2_bold, color: Colors.white, size: 30),
                const SizedBox(width: 15),
                const Text(
                  "سجل المحادثات",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _createNewChat,
              icon: const Icon(Icons.add),
              label: const Text("محادثة جديدة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final isSelected = currentChat == index;
                return ListTile(
                  leading: Icon(
                    Iconsax.message_outline,
                    color: isSelected ? AppColors.darkBlue : Colors.grey,
                  ),
                  title: Text(
                    chats[index].title,
                    style: TextStyle(
                      color: isSelected ? AppColors.darkBlue : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() => currentChat = index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
