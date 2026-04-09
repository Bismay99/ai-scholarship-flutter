import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/chat_message.dart';
import '../services/api_config.dart';

class ChatbotProvider extends ChangeNotifier {
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<ChatMessage> _messages = [
    ChatMessage(
      role: 'model',
      text: "Hi! Ask me anything about your loan eligibility or scholarships."
    )
  ];
  List<ChatMessage> get messages => _messages;

  // Draggable properties
  double? _top;
  double? _left;
  double? get top => _top;
  double? get left => _left;

  final Dio _dio = Dio();

  void updatePosition(double dy, double dx, Size size) {
    if (_top == null || _left == null) {
      _top = size.height - 150;
      _left = size.width - 90;
    }
    _top = _top! + dy;
    _left = _left! + dx;
    if (_top! < 50) _top = 50;
    if (_left! < 10) _left = 10;
    if (_top! > size.height - 100) _top = size.height - 100;
    if (_left! > size.width - 80) _left = size.width - 80;
    notifyListeners();
  }

  void toggleExpanded() {
    _isExpanded = !_isExpanded;
    notifyListeners();
  }
  
  void collapse() {
    _isExpanded = false;
    notifyListeners();
  }

  void addMessage(String role, String text) {
    _messages.add(ChatMessage(role: role, text: text));
    notifyListeners();
  }

  void _removeLastIfError() {
    if (_messages.isNotEmpty && _messages.last.isError) {
      _messages.removeLast();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> _getMessageHistory() {
    List<Map<String, dynamic>> history = [];
    for (var m in _messages) {
      if (m.text.contains("Hi! Ask me anything") || m.text.contains("unavailable")) continue;
      history.add({
        "role": m.role == "model" ? "assistant" : m.role,
        "content": m.text
      });
    }
    return history;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    addMessage('user', text.trim());
    _isLoading = true;
    notifyListeners();

    await _performApiRequest();
  }

  /// Sends a message and returns the AI response text (used by Voice Assistant)
  Future<String> sendMessageAndGetResponse(String text, {bool respondInHindi = false}) async {
    if (text.trim().isEmpty) return '';
    
    addMessage('user', text.trim());
    _isLoading = true;
    notifyListeners();

    await _performApiRequest(respondInHindi: respondInHindi);

    // Return the last model message
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'model') {
        return _messages[i].text;
      }
    }
    return respondInHindi 
        ? 'माफ़ कीजिए, मैं जवाब नहीं दे सका।' 
        : 'Sorry, I could not generate a response.';
  }

  Future<void> retryLast() async {
    _removeLastIfError();
    _isLoading = true;
    notifyListeners();
    await _performApiRequest();
  }

  Future<void> _performApiRequest({bool respondInHindi = false}) async {
    try {
      final String systemPrompt = respondInHindi 
        ? "You are a professional AI Financial Advisor and Senior Loan Analyst. Respond in friendly 'Hinglish' (a natural mix of Hindi and English) that Indian students commonly use. Help them with loan eligibility, credit scores, and scholarships. Keep it conversational, concise, and very clear."
        : "You are a professional AI Financial Advisor and Senior Loan Analyst for a student fintech application. You help users understand their loan eligibility, credit score, missing documents, and perfectly matching scholarships. Keep responses concise, supportive, and formatted cleanly.";

      final List<Map<String, dynamic>> messages = [
        {
          "role": "system",
          "content": systemPrompt
        },
        ..._getMessageHistory(),
      ];

      final apiKey = ApiConfig.groqApiKey;
      const url = 'https://api.groq.com/openai/v1/chat/completions';

      final response = await _dio.post(
        url,
        data: {
          "model": "llama-3.3-70b-versatile",
          "messages": messages,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
            'X-Title': 'AI Scholarship Assistant',
          },
          sendTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 25),
        ),
      );

      if (response.statusCode == 200) {
        final aiText = response.data['choices'][0]['message']['content'] as String;
        addMessage('model', aiText);
      } else {
        addMessage('model', "AI is currently unavailable, please try again. (${response.statusCode})");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        addMessage('model', "AI is currently unavailable, please try again. (Timeout)");
      } else {
        final errText = e.response?.data?['error']?['message'] ?? e.message;
        addMessage('model', "AI is currently unavailable, please try again. ($errText)");
      }
    } catch (e) {
      addMessage('model', "AI is currently unavailable, please try again. (Network Error)");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
