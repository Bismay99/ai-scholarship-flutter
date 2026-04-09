import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/vapi_service.dart';
import '../providers/chatbot_provider.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool _callStarted = false;

  void _startCall(CallLanguage lang) {
    final voice = Provider.of<VoiceAssistantService>(context, listen: false);
    final chatbot = Provider.of<ChatbotProvider>(context, listen: false);

    // Connect voice to Gemini AI with language awareness
    voice.onUserSpeech = (userText, language) async {
      final response = await chatbot.sendMessageAndGetResponse(
        userText,
        respondInHindi: language == CallLanguage.hindi,
      );
      return response;
    };

    voice.startCall(lang: lang);
    setState(() => _callStarted = true);
  }

  void _endCall() {
    final voice = Provider.of<VoiceAssistantService>(context, listen: false);
    voice.endCall();
    Navigator.of(context).pop();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    if (!_callStarted) {
      return _buildLanguagePicker();
    }

    return Consumer<VoiceAssistantService>(
      builder: (context, voice, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E1A),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Language badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    voice.language == CallLanguage.hindi ? "🇮🇳 हिंदी" : "🇬🇧 English",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),

                // Call Status Header
                Text(
                  _getStatusTitle(voice.callState, voice.language),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDuration(voice.callDuration),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),

                const Spacer(flex: 1),

                // Pulsing Avatar
                _buildAvatar(voice),

                const SizedBox(height: 30),

                // AI Name
                Text(
                  voice.language == CallLanguage.hindi 
                      ? "वित्तीय सहायता सहायक" 
                      : "Financial Aid Assistant",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  voice.language == CallLanguage.hindi 
                      ? "AI आवाज सहायक" 
                      : "AI Voice Assistant",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // Live Transcript
                _buildTranscript(voice),

                const Spacer(flex: 2),

                // Call Controls
                _buildCallControls(voice),

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Language selection screen shown before call starts
  Widget _buildLanguagePicker() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF7C3AED), const Color(0xFF22D3EE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 45),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 30),

            const Text(
              "Choose Language",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select the language for your voice call",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              "कॉल के लिए भाषा चुनें",
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            ),

            const SizedBox(height: 50),

            // English Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: () => _startCall(CallLanguage.english),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22D3EE).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🇬🇧", style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        "English",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

            const SizedBox(height: 20),

            // Hindi Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GestureDetector(
                onTap: () => _startCall(CallLanguage.hindi),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("🇮🇳", style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        "हिंदी (Hindi)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
          ],
        ),
      ),
    );
  }

  String _getStatusTitle(CallState state, CallLanguage lang) {
    final isHindi = lang == CallLanguage.hindi;
    switch (state) {
      case CallState.connecting:
        return isHindi ? "कनेक्ट हो रहा है..." : "CONNECTING...";
      case CallState.listening:
        return isHindi ? "सुन रहा हूँ" : "LISTENING";
      case CallState.thinking:
        return isHindi ? "AI सोच रहा है..." : "AI IS THINKING...";
      case CallState.speaking:
        return isHindi ? "AI बोल रहा है" : "AI IS SPEAKING";
      case CallState.idle:
        return isHindi ? "कॉल समाप्त" : "CALL ENDED";
    }
  }

  Widget _buildAvatar(VoiceAssistantService voice) {
    final isActive = voice.callState == CallState.listening ||
        voice.callState == CallState.speaking;
    final color = voice.callState == CallState.listening
        ? const Color(0xFF22D3EE)
        : voice.callState == CallState.speaking
            ? const Color(0xFF7C3AED)
            : voice.callState == CallState.thinking
                ? Colors.orange
                : const Color(0xFF22D3EE);

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isActive)
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1.seconds)
           .fadeOut(begin: 1, duration: 1.seconds),

        if (isActive)
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.2), width: 2),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            voice.callState == CallState.listening
                ? Icons.mic
                : voice.callState == CallState.speaking
                    ? Icons.volume_up
                    : voice.callState == CallState.thinking
                        ? Icons.psychology
                        : Icons.phone,
            color: Colors.white,
            size: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildTranscript(VoiceAssistantService voice) {
    if (voice.currentTranscript.isEmpty) return const SizedBox.shrink();

    final isHindi = voice.language == CallLanguage.hindi;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            voice.callState == CallState.listening
                ? (isHindi ? "आप" : "You")
                : voice.callState == CallState.thinking
                    ? (isHindi ? "प्रोसेसिंग..." : "Processing...")
                    : (isHindi ? "AI सहायक" : "AI Assistant"),
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            voice.currentTranscript,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(VoiceAssistantService voice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _endCall,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x66EF4444),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }
}
