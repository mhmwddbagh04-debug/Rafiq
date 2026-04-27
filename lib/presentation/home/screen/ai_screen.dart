import 'package:flutter/material.dart';
import 'package:Rafiq/core/api/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
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

class _AiScreenState extends State<AiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _aiService = AiService();

  bool _isLoading = false;

  List<ChatSession> chats = [
    ChatSession(
      title: "محادثة جديدة",
      messages: [
        ChatMessage(
          text: "مرحباً بك في رفيق 👋\nكيف يمكنني مساعدتك اليوم؟",
          isUser: false,
        ),
      ],
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
            text: "حدث خطأ أثناء الاتصال بالخادم",
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
          title: "محادثة ${chats.length + 1}",
          messages: [
            ChatMessage(
              text: "مرحباً 👋 كيف يمكنني مساعدتك؟",
              isUser: false,
            ),
          ],
        ),
      );

      currentChat = 0;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF0B1020) : const Color(0xFFF5F7FF),

      drawer: Drawer(
        backgroundColor:
        isDark ? const Color(0xFF111827) : Colors.white,

        child: Column(
          children: [

            /// HEADER
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF48C9B0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "رفيق الذكي",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                      isDark ? Colors.white : Colors.black,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "AI Medical Assistant",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white54
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            /// NEW CHAT BUTTON
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _createNewChat,
                  icon: const Icon(Icons.add),
                  label: const Text("محادثة جديدة"),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// CHAT LIST
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,

                itemBuilder: (_, index) {
                  final chat = chats[index];

                  final selected =
                      currentChat == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),

                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),

                      tileColor: selected
                          ? const Color(0xFF6C63FF)
                          .withOpacity(.15)
                          : Colors.transparent,

                      leading: Icon(
                        Icons.chat_bubble_outline,
                        color: selected
                            ? const Color(0xFF6C63FF)
                            : null,
                      ),

                      title: Text(
                        chat.title,
                        style: TextStyle(
                          color: selected
                              ? const Color(0xFF6C63FF)
                              : isDark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),

                      onTap: () {
                        setState(() {
                          currentChat = index;
                        });

                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      /// APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        isDark ? const Color(0xFF111827) : Colors.white,

        centerTitle: true,

        title: Column(
          children: [
            Text(
              chats[currentChat].title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              "Online",
              style: TextStyle(
                fontSize: 11,
                color:
                isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),

      /// BODY
      body: Column(
        children: [

          /// MESSAGES
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,

              itemBuilder: (_, index) {
                final msg = messages[index];

                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,

                  child: Container(
                    margin:
                    const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),

                    constraints: BoxConstraints(
                      maxWidth:
                      MediaQuery.of(context).size.width *
                          .75,
                    ),

                    decoration: BoxDecoration(
                      gradient: msg.isUser
                          ? const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF8B85FF),
                        ],
                      )
                          : null,

                      color: msg.isUser
                          ? null
                          : isDark
                          ? const Color(0xFF1E293B)
                          : Colors.white,

                      borderRadius: BorderRadius.only(
                        topLeft:
                        const Radius.circular(22),
                        topRight:
                        const Radius.circular(22),
                        bottomLeft: Radius.circular(
                            msg.isUser ? 22 : 6),
                        bottomRight: Radius.circular(
                            msg.isUser ? 6 : 22),
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black.withOpacity(.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Text(
                      msg.text,
                      textDirection: TextDirection.rtl,

                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,

                        color: msg.isUser
                            ? Colors.white
                            : isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// LOADING
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: const [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),

                  SizedBox(width: 10),

                  Text("يتم توليد الرد..."),
                ],
              ),
            ),

          /// INPUT AREA
          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              20,
            ),

            decoration: BoxDecoration(
              color:
              isDark ? const Color(0xFF111827) : Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 10,
                ),
              ],
            ),

            child: Row(
              children: [

                /// TEXT FIELD
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textDirection: TextDirection.rtl,

                    style: TextStyle(
                      color:
                      isDark ? Colors.white : Colors.black,
                    ),

                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك...",

                      filled: true,

                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),

                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    onSubmitted: (_) =>
                        _sendMessage(),
                  ),
                ),

                const SizedBox(width: 10),

                /// SEND BUTTON
                GestureDetector(
                  onTap: _sendMessage,

                  child: Container(
                    width: 55,
                    height: 55,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF48C9B0),
                        ],
                      ),

                      borderRadius:
                      BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF)
                              .withOpacity(.35),

                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}