import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class ApiConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get ocrApiKey => dotenv.env['OCR_API_KEY'] ?? '';

  static String get aiScoreBaseUrl {
    final envUrl = dotenv.env['AI_SCORE_BASE_URL'];
    String url;
    
    if (envUrl != null && envUrl.isNotEmpty) {
      url = envUrl;
    } else {
      // Default fallback logic for local development
      if (kIsWeb) {
        url = 'http://127.0.0.1:3000';
      } else if (Platform.isAndroid) {
        url = 'http://10.0.2.2:3000';
      } else {
        url = 'http://127.0.0.1:3000';
      }
    }
    
    // ignore: avoid_print
    print('AI Score API Base URL: $url');
    return url;
  }
}
