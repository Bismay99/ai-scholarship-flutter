import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'dart:convert';
import '../models/verification_result.dart';

class AiVerificationService {
  final Dio _dio = Dio();
  
  // Using Gemini 2.5 Flash as of April 2026 for vision processing
  String get _geminiUrl => "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-latest:generateContent?key=${ApiConfig.geminiApiKey}";

  AiVerificationService();

  Future<VerificationResult> verifyDocument(Uint8List fileBytes, String docType, String mimeType) async {
    return _verifyWithRetry(fileBytes, docType, mimeType, 0);
  }

  Future<VerificationResult> _verifyWithRetry(Uint8List fileBytes, String docType, String mimeType, int retryCount) async {
    const int maxRetries = 3;
    
    try {
      final String base64Image = base64Encode(fileBytes);
      final String prompt = _buildPrompt(docType);

      final response = await _dio.post(
        _geminiUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          // Ensure we don't throw for 429 so we can handle it manually if preferred, 
          // but Dio usually throws DioException for >= 400.
        ),
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inline_data": {
                    "mime_type": mimeType,
                    "data": base64Image
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "responseMimeType": "application/json",
            "temperature": 0.1,
          }
        },
      );

      final responseData = response.data;
      
      // Gemini response parsing
      final String? content = responseData['candidates']?[0]?['content']?['parts']?[0]?['text'];

      if (content == null || content.isEmpty) {
        return VerificationResult(isValid: false, message: "Gemini failed to analyze the document. Please try a clearer photo.");
      }

      // Sometimes Gemini wraps JSON in markdown blocks
      String cleanJson = content.trim();
      if (cleanJson.startsWith("```json")) {
        cleanJson = cleanJson.substring(7, cleanJson.length - 3).trim();
      } else if (cleanJson.startsWith("```")) {
        cleanJson = cleanJson.substring(3, cleanJson.length - 3).trim();
      }

      final data = jsonDecode(cleanJson);
      
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
        final statusCode = e.response?.statusCode;
        final isConnError = e.type == DioExceptionType.connectionTimeout || 
                           e.type == DioExceptionType.sendTimeout || 
                           e.type == DioExceptionType.receiveTimeout ||
                           e.message?.contains("lookup") == true;
        
        // Handle Rate Limiting (429) or Server Overload (503)
        if ((statusCode == 429 || statusCode == 503) && retryCount < maxRetries) {
          final waitSeconds = (retryCount + 1) * 3; // 3s, 6s, 9s backoff
          print("Gemini Quota Hit ($statusCode). Retrying in ${waitSeconds}s... (Attempt ${retryCount + 1})");
          
          await Future.delayed(Duration(seconds: waitSeconds));
          return _verifyWithRetry(fileBytes, docType, mimeType, retryCount + 1);
        }

        if (statusCode == 429) {
          return VerificationResult(
            isValid: false, 
            message: "Verify limit reached. Please wait a minute and try again. Our AI is currently in high demand.",
            isConnectionError: false,
          );
        }

        final errorMsg = e.response?.data?['error']?['message'] ?? e.message;
        return VerificationResult(isValid: false, message: "Verification API Error: $errorMsg", isConnectionError: isConnError);
      }
      return VerificationResult(isValid: false, message: "Verification Technical Error: ${e.toString()}", isConnectionError: false);
    }
  }

  String _buildPrompt(String docType) {
    return """
    You are a professional document verification expert for Indian student applications.
    The user has uploaded a document claiming it is a: **$docType**.
    
    CRITICAL TASKS:
    1. Look at the visual content of the provided image/document.
    2. Explicitly verify if the document is ACTUALLY a **$docType**.
    3. If the document is something else (e.g. they uploaded an Aadhaar card but claimed it is a Marksheet), you MUST set "isAuthentic" to false.
    4. Extract key details ONLY if the document is authentic.
    
    REQUIRED JSON RESPONSE FORMAT:
    {
      "isAuthentic": boolean,
      "reason": "Explain EXACTLY why it was rejected if isAuthentic is false (e.g. 'The uploaded document appears to be an Aadhaar card, but a $docType was expected').",
      "extractedData": {
        "Name": "Full name on doc",
        "ID Number": "Unique number/ID",
        ... other relevant fields
      }
    }
    
    SPECIFIC GUIDELINES FOR **$docType**:
    ${_getDocSpecificFields(docType)}
    
    IMPORTANT: Be extremely strict. Do not verify if there is any doubt or if the document type is incorrect. Respond ONLY with valid JSON.
    """;
  }

  String _getDocSpecificFields(String docType) {
    final type = docType.toLowerCase();
    
    if (type.contains("aadhaar")) {
      return "Must have a 12-digit number (XXXX XXXX XXXX). Must contain the word 'Aadhaar' UIDAI.";
    } else if (type.contains("pan")) {
      return "Must be an Income Tax Department Issued Permanent Account Number Card. Look for 10 alphanumeric chars (e.g., ABCDE1234F).";
    } else if (type.contains("income")) {
      return "Must state it is an 'Income Certificate' or from a 'Revenue' department. Must show an annual income amount.";
    } else if (type.contains("marksheet") || type.contains("certificate")) {
      return "Must be a transcript, grade sheet, or certificate. Look for 'Marks', 'Percentage', or 'CGPA'. Extract the total secured marks or percentage as a number.";
    } else if (type.contains("bonafide")) {
      return "Must be from an educational institution. Look for phrases like 'Bonafide Student', 'Studying in', 'Principal signature/stamp'.";
    } else if (type.contains("bank") || type.contains("passbook")) {
      return "Must be the front page of a bank passbook or statement. Extract Account Number and IFSC code.";
    } else {
      return "Verify the document against common official Indian formats for $docType.";
    }
  }
}


