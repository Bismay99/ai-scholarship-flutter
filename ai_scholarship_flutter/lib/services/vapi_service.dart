import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum CallState { idle, connecting, listening, thinking, speaking }
enum CallLanguage { english, hindi }

class VoiceAssistantService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  CallState _callState = CallState.idle;
  bool _isInCall = false;
  bool _isInitialized = false;
  String _lastWords = '';
  String _currentTranscript = '';
  String? _errorMessage;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  CallLanguage _language = CallLanguage.english;

  // Callback to send recognized speech to AI and get response
  Future<String> Function(String, CallLanguage)? onUserSpeech;

  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;

  VoiceAssistantService._internal() {
    _initTts();
  }

  CallState get callState => _callState;
  bool get isInCall => _isInCall;
  bool get isListening => _callState == CallState.listening;
  bool get isSpeaking => _callState == CallState.speaking;
  bool get isThinking => _callState == CallState.thinking;
  bool get isActive => _isInCall;
  String get lastWords => _lastWords;
  String get currentTranscript => _currentTranscript;
  String? get errorMessage => _errorMessage;
  Duration get callDuration => _callDuration;
  CallLanguage get language => _language;

  String get _speechLocale => _language == CallLanguage.hindi ? 'hi-IN' : 'en-US';
  String get _ttsLanguage => _language == CallLanguage.hindi ? 'hi-IN' : 'en-US';

  Future<void> _initTts() async {
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (_isInCall) {
        // After AI finishes speaking, start listening again automatically
        _startListeningLoop();
      } else {
        _callState = CallState.idle;
        notifyListeners();
      }
    });

    _tts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      if (_isInCall) {
        _startListeningLoop();
      }
    });
  }

  Future<void> _configureTtsForLanguage() async {
    await _tts.setLanguage(_ttsLanguage);
    await _tts.setSpeechRate(_language == CallLanguage.hindi ? 0.45 : 0.5);
  }

  Future<bool> _initSpeech() async {
    if (_isInitialized) return true;

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _errorMessage = _language == CallLanguage.hindi 
          ? "माइक्रोफोन की अनुमति नहीं दी गई" 
          : "Microphone permission denied";
      notifyListeners();
      return false;
    }

    _isInitialized = await _speech.initialize(
      onError: (error) {
        debugPrint("Speech error: ${error.errorMsg}");
        if (_isInCall && error.errorMsg != 'error_busy') {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_isInCall) _startListeningLoop();
          });
        }
      },
      onStatus: (status) {
        debugPrint("Speech status: $status");
      },
    );

    if (!_isInitialized) {
      _errorMessage = "Speech recognition not available on this device";
      notifyListeners();
    }

    return _isInitialized;
  }

  /// Start a voice call session with specified language
  Future<void> startCall({CallLanguage lang = CallLanguage.english}) async {
    _errorMessage = null;
    _language = lang;

    final ready = await _initSpeech();
    if (!ready) return;

    await _configureTtsForLanguage();

    _isInCall = true;
    _callState = CallState.connecting;
    _callDuration = Duration.zero;
    notifyListeners();

    // Start call timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration = Duration(seconds: timer.tick);
      notifyListeners();
    });

    // Greet the user in selected language (Hinglish style for Hindi)
    _callState = CallState.speaking;
    _currentTranscript = _language == CallLanguage.hindi
        ? "नमस्ते! मैं आपकी Financial Aid Assistant हूँ. मैं आज आपकी कैसे help कर सकती हूँ?"
        : "Hello! I'm your Financial Aid Assistant. How can I help you today?";
    notifyListeners();
    await _tts.speak(_currentTranscript);
  }

  /// End the voice call
  Future<void> endCall() async {
    _isInCall = false;
    _callState = CallState.idle;
    _callTimer?.cancel();
    _callTimer = null;

    await _speech.stop();
    await _tts.stop();

    _currentTranscript = '';
    _lastWords = '';
    notifyListeners();
  }

  /// Toggle call on/off
  Future<void> toggleVoice() async {
    if (_isInCall) {
      await endCall();
    } else {
      await startCall();
    }
  }

  /// Internal: start listening loop for continuous conversation
  Future<void> _startListeningLoop() async {
    if (!_isInCall) return;

    _callState = CallState.listening;
    _lastWords = '';
    _currentTranscript = _language == CallLanguage.hindi ? 'सुन रहा हूँ...' : 'Listening...';
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          _currentTranscript = _lastWords.isNotEmpty 
              ? _lastWords 
              : (_language == CallLanguage.hindi ? 'सुन रहा हूँ...' : 'Listening...');
          notifyListeners();

          if (result.finalResult && _lastWords.isNotEmpty) {
            _processUserSpeech(_lastWords);
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 2),
        listenMode: stt.ListenMode.dictation,
        localeId: _speechLocale,
      );
    } catch (e) {
      debugPrint("Listen error: $e");
      if (_isInCall) {
        Future.delayed(const Duration(seconds: 1), () {
          if (_isInCall) _startListeningLoop();
        });
      }
    }
  }

  Future<void> _processUserSpeech(String userText) async {
    if (!_isInCall) return;

    await _speech.stop();

    _callState = CallState.thinking;
    _currentTranscript = _language == CallLanguage.hindi ? 'सोच रहा हूँ...' : 'Thinking...';
    notifyListeners();

    debugPrint("Voice Call heard [$_speechLocale]: $userText");

    if (onUserSpeech == null) {
      _currentTranscript = "Voice assistant not connected to AI";
      _callState = CallState.speaking;
      notifyListeners();
      await _tts.speak(_language == CallLanguage.hindi 
          ? "माफ़ कीजिए, AI सेवा कनेक्ट नहीं है।" 
          : "Sorry, the AI service is not connected.");
      return;
    }

    try {
      final aiResponse = await onUserSpeech!(userText, _language);
      debugPrint("AI Response: $aiResponse");

      if (!_isInCall) return;

      _callState = CallState.speaking;
      _currentTranscript = aiResponse;
      notifyListeners();

      await _tts.speak(aiResponse);
    } catch (e) {
      debugPrint("Error processing voice: $e");
      if (_isInCall) {
        _callState = CallState.speaking;
        _currentTranscript = _language == CallLanguage.hindi 
            ? "माफ़ कीजिए, एक त्रुटि हुई। कृपया फिर से प्रयास करें।" 
            : "Sorry, I encountered an error. Please try again.";
        notifyListeners();
        await _tts.speak(_currentTranscript);
      }
    }
  }

  @override
  void dispose() {
    endCall();
    super.dispose();
  }
}
