import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'dart:convert';
import '../models/verification_result.dart';

class GroqVerificationService {
  final Dio _dio = Dio();
  
  static const String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  static const String _model = "llama-3.2-11b-vision-preview";

  GroqVerificationService();

  Future<VerificationResult> verifyDocument(Uint8List fileBytes, String docType, String mimeType) async {
    try {
      final String base64Image = base64Encode(fileBytes);
      final String prompt = _buildPrompt(docType);

      final response = await _dio.post(
        _groqUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${ApiConfig.groqApiKey}",
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
        data: {
          "model": _model,
          "messages": [
            {
              "role": "user",
              "content": [
                {"type": "text", "text": prompt},
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:$mimeType;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "temperature": 0.1,
          "response_format": {"type": "json_object"}
        },
      );

      final responseData = response.data;
      final String? content = responseData['choices']?[0]?['message']?['content'];

      if (content == null || content.isEmpty) {
        return VerificationResult(isValid: false, message: "Groq failed to analyze the document.");
      }

      final data = jsonDecode(content);
      
      final bool isAuthentic = data['isAuthentic'] ?? false;
      final String reason = data['reason'] ?? "Verification failed for unknown reason.";
      final Map<String, dynamic>? rawData = data['extractedData'];
      
      Map<String, String>? extractedData;
      if (rawData != null && rawData.isNotEmpty) {
        extractedData = rawData.map((key, value) => MapEntry(key, value.toString()));
      }

      return VerificationResult(
        isValid: isAuthentic,
        message: isAuthentic ? "Document successfully verified!" : reason,
        extractedData: extractedData,
      );
    } catch (e) {
      if (e is DioException) {
        final isConnError = e.type == DioExceptionType.connectionTimeout || 
                           e.type == DioExceptionType.sendTimeout || 
                           e.type == DioExceptionType.receiveTimeout ||
                           e.message?.contains("lookup") == true;
        final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
        return VerificationResult(isValid: false, message: "Groq API Error: $errorMsg", isConnectionError: isConnError);
      }
      return VerificationResult(isValid: false, message: "Groq Technical Error: ${e.toString()}", isConnectionError: false);
    }
  }

  String _buildPrompt(String docType) {
    return """
    You are a professional document verification expert for Indian student applications.
    The user has uploaded a document claiming it is a: **$docType**.
    
    CRITICAL TASKS:
    1. Look at the image content.
    2. Verify if it is ACTUALLY a **$docType**.
    3. If not, set "isAuthentic" to false and explain why in "reason".
    4. Extract key details (Name, ID Number, etc.) ONLY if authentic.
    
    RESPONSE FORMAT (JSON):
    {
      "isAuthentic": boolean,
      "reason": "Clear explanation of results",
      "extractedData": {
        "Name": "Full name",
        "ID Number": "Unique ID",
      }
    }
    
    SPECIFIC GUIDELINES FOR **$docType**:
    - Aadhaar: 12 digits.
    - PAN: 10 alphanumeric chars.
    - Income Cert: Must have name and income amount.
    - Marksheet: Must have marks/grades.
    
    Respond ONLY with valid JSON.
    """;
  }
}
