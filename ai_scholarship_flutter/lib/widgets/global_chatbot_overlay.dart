import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/chatbot_provider.dart';
import '../services/vapi_service.dart';

class GlobalChatbotOverlay extends StatefulWidget {
  final Widget child;
  const GlobalChatbotOverlay({super.key, required this.child});

  @override
  State<GlobalChatbotOverlay> createState() => _GlobalChatbotOverlayState();
}

class _GlobalChatbotOverlayState extends State<GlobalChatbotOverlay> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _voiceConnected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Connect voice assistant to Gemini chatbot
    if (!_voiceConnected) {
      final voice = Provider.of<VoiceAssistantService>(context, listen: false);
      final chatbot = Provider.of<ChatbotProvider>(context, listen: false);
      voice.onUserSpeech = (userText, language) async {
        final response = await chatbot.sendMessageAndGetResponse(
          userText,
          respondInHindi: language == CallLanguage.hindi,
        );
        _scrollToBottom();
        return response;
      };
      _voiceConnected = true;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(ChatbotProvider provider) {
    if (_textController.text.isNotEmpty) {
      provider.sendMessage(_textController.text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Consumer2<ChatbotProvider, VoiceAssistantService>(
      builder: (context, provider, voice, _) {
        return Stack(
          children: [
            widget.child,

            // Idle Draggable Button
            if (!provider.isExpanded)
              Positioned(
                top: provider.top,
                left: provider.left,
                bottom: provider.top == null ? 100 : null,
                right: provider.left == null ? 20 : null,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    provider.updatePosition(details.delta.dy, details.delta.dx, size);
                  },
                  onTap: () {
                    provider.toggleExpanded();
                    _scrollToBottom();
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.secondary, colorScheme.primary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.secondary.withOpacity(0.5),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: Image.asset(
                            'assets/images/bot_mascot.png',
                            width: 55,
                            height: 55,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .shimmer(delay: 2.seconds, duration: 1.5.seconds, color: Colors.white24)
                   .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.08, 1.08), duration: 800.ms, curve: Curves.easeInOut),
                ),
              ),

            // Expanded Chat UI
            if (provider.isExpanded)
              Positioned.fill(
                child: Material(
                  color: isDark ? Colors.black54 : Colors.black26,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: provider.collapse,
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      Container(
                        height: size.height * 0.75,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0A0E21) : Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -5))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          child: Stack(
                            children: [
                              // Mesh Gradient Elements
                              Positioned(
                                top: -50,
                                right: -50,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 5.seconds, curve: Curves.easeInOut),
                              ),
                              Positioned(
                                bottom: 100,
                                left: -50,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.secondary.withOpacity(isDark ? 0.15 : 0.05),
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                 .scale(begin: const Offset(1, 1), end: const Offset(1.8, 1.8), duration: 7.seconds, curve: Curves.easeInOut),
                              ),
                              
                              // Main content on top of mesh
                              Column(
                                children: [
                                  // Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15),
                                                child: Image.asset('assets/images/bot_mascot.png', width: 24, height: 24),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text("AI Analyst", style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.onSurface.withOpacity(0.7)),
                                          onPressed: provider.collapse,
                                        )
                                      ],
                                    ),
                                  ),
                                  Divider(color: theme.dividerColor, height: 1),
                                  
                                  // Quick Questions UI
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: Row(
                                      children: [
                                        _buildQuickChip("Am I eligible?", provider, theme),
                                        const SizedBox(width: 10),
                                        _buildQuickChip("Why was my loan rejected?", provider, theme),
                                        const SizedBox(width: 10),
                                        _buildQuickChip("Available Scholarships?", provider, theme),
                                      ],
                                    ),
                                  ),

                                  // Chat Messages Area
                                  Expanded(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      itemCount: provider.messages.length,
                                      itemBuilder: (context, index) {
                                        final msg = provider.messages[index];
                                        return Row(
                                          mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if (!msg.isUser) ...[
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 4)
                                                  ],
                                                ),
                                                child: CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: Colors.transparent,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(15),
                                                    child: Image.asset('assets/images/bot_mascot.png', width: 22, height: 22),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(bottom: 8),
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                    decoration: BoxDecoration(
                                                      gradient: msg.isUser 
                                                        ? LinearGradient(colors: [colorScheme.secondary, colorScheme.secondary.withOpacity(0.85)]) 
                                                        : LinearGradient(colors: [
                                                            isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFF5F5F7),
                                                            isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5E7),
                                                          ]),
                                                      border: (!msg.isUser && !msg.isError) ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
                                                      borderRadius: BorderRadius.only(
                                                        topLeft: const Radius.circular(22),
                                                        topRight: const Radius.circular(22),
                                                        bottomLeft: msg.isUser ? const Radius.circular(22) : const Radius.circular(4),
                                                        bottomRight: msg.isUser ? const Radius.circular(4) : const Radius.circular(22),
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 4),
                                                        ),
                                                        if (msg.isUser)
                                                          BoxShadow(color: colorScheme.secondary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      msg.text,
                                                      style: TextStyle(
                                                        color: msg.isUser ? colorScheme.onSecondary : colorScheme.onSurface,
                                                        fontSize: 15,
                                                        height: 1.4,
                                                        fontWeight: msg.isUser ? FontWeight.w600 : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                  if (msg.isError && !msg.isUser) 
                                                    GestureDetector(
                                                      onTap: () {
                                                        provider.retryLast();
                                                        _scrollToBottom();
                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(bottom: 15, left: 10),
                                                        child: Text("Tap here to Retry", style: TextStyle(color: colorScheme.error, fontSize: 13, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            if (msg.isUser) ...[
                                              const SizedBox(width: 8),
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: colorScheme.secondary,
                                                child: Icon(Icons.person, color: colorScheme.onSecondary, size: 18),
                                              ),
                                            ],
                                          ],
                                        );
                                      },
                                    ),
                                  ),

                                  // Typing Indicator
                                  if (provider.isLoading)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 15, left: 20),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(color: colorScheme.primary, strokeWidth: 2),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "AI is typing...",
                                            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7), fontSize: 13, fontStyle: FontStyle.italic),
                                          )
                                        ],
                                      ),
                                    ),

                                  // Floating User Input
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF161B33) : Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: TextField(
                                              controller: _textController,
                                              style: TextStyle(color: colorScheme.onSurface),
                                              enabled: !provider.isLoading,
                                              decoration: InputDecoration(
                                                hintText: "Ask AI anything...",
                                                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                              ),
                                              onSubmitted: (_) => _sendMessage(provider),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Chat Send Button
                                          GestureDetector(
                                            onTap: provider.isLoading ? null : () => _sendMessage(provider),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                                                ],
                                              ),
                                              child: Icon(Icons.arrow_upward_rounded, color: colorScheme.onPrimary, size: 22),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildQuickChip(String label, ChatbotProvider provider, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        _textController.text = label;
        _sendMessage(provider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
