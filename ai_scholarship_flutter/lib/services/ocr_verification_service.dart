import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_config.dart';
import 'dart:convert';
import '../models/verification_result.dart';

class OcrVerificationService {
  final Dio _dio = Dio();
  final String _ocrUrl = "https://api.ocr.space/parse/image";

  OcrVerificationService();

  Future<VerificationResult> verifyDocument(Uint8List fileBytes, String docType, String mimeType) async {
    try {
      final String base64Image = base64Encode(fileBytes);
      
      final formData = FormData.fromMap({
        'base64Image': "data:$mimeType;base64,$base64Image",
        'apikey': ApiConfig.ocrApiKey,
        'language': 'eng',
        'isOverlayRequired': false,
        'FileType': mimeType.contains('pdf') ? 'PDF' : 'IMAGE',
      });

      final response = await _dio.post(
        _ocrUrl,
        data: formData,
      );

      if (response.data == null || response.data['ParsedResults'] == null) {
        return VerificationResult(isValid: false, message: "OCR Service failed to parse document.");
      }

      final String parsedText = response.data['ParsedResults'][0]['ParsedText'] ?? "";
      
      if (parsedText.trim().isEmpty) {
        return VerificationResult(isValid: false, message: "No text found in the document. Please ensure it is clear.");
      }

      return _validateContent(parsedText, docType);
    } catch (e) {
      if (e is DioException) {
        final isConnError = e.type == DioExceptionType.connectionTimeout || 
                           e.type == DioExceptionType.sendTimeout || 
                           e.type == DioExceptionType.receiveTimeout ||
                           e.message?.contains("lookup") == true;
        final errorMsg = e.response?.data?['ErrorMessage'] ?? e.message;
        return VerificationResult(isValid: false, message: "OCR Error: $errorMsg", isConnectionError: isConnError);
      }
      return VerificationResult(isValid: false, message: "OCR Technical Error: ${e.toString()}", isConnectionError: false);
    }
  }

  VerificationResult _validateContent(String text, String docType) {
    final Map<String, String> extractedData = {};
    bool isValid = false;
    String message = "Document format not recognized.";

    switch (docType) {
      case "Aadhaar Card":
        // Pattern for 12-digit Aadhaar (XXXX XXXX XXXX or XXXXXXXXXXXX)
        final aadhaarRegex = RegExp(r"\d{4}\s?\d{4}\s?\d{4}");
        final match = aadhaarRegex.firstMatch(text);
        if (match != null) {
          isValid = true;
          message = "Aadhaar Card successfully verified!";
          extractedData["ID Number"] = match.group(0)!;
          // Try to find a name (heuristic: first two words after common headings)
          _extractHeuristicData(text, extractedData);
        } else {
          message = "Valid 12-digit Aadhaar number not found. Please upload a clear image.";
        }
        break;

      case "Income Certificate":
        final incomeTerms = ["Income", "Certificate", "Tahsil", "Revenue"];
        int matchCount = incomeTerms.where((term) => text.contains(RegExp(term, caseSensitive: false))).length;
        if (matchCount >= 2) {
          isValid = true;
          message = "Income Certificate verified!";
          // Try to extract amount
          final amountRegex = RegExp(r"Rs\.?\s?\d+[\d,]*");
          final amountMatch = amountRegex.firstMatch(text);
          if (amountMatch != null) extractedData["Annual Income"] = amountMatch.group(0)!;
        } else {
          message = "This does not appear to be an official Income Certificate.";
        }
        break;

      case "Marksheet":
        final marksheetTerms = ["Marks", "Statement", "Examination", "Board", "University"];
        int matchCount = marksheetTerms.where((term) => text.contains(RegExp(term, caseSensitive: false))).length;
        if (matchCount >= 2) {
          isValid = true;
          message = "Marksheet verified!";
          // Try to extract roll number
          final rollRegex = RegExp(r"(Roll|No)\.?\s?\d+", caseSensitive: false);
          final rollMatch = rollRegex.firstMatch(text);
          if (rollMatch != null) extractedData["Roll Number"] = rollMatch.group(0)!;
        } else {
          message = "Document keyword analysis failed for Marksheet verification.";
        }
        break;

      default:
        isValid = text.length > 50; // Simple length check for fallback
        message = isValid ? "Document uploaded and basic scan complete." : "Document too short or unreadable.";
        break;
    }

    return VerificationResult(
      isValid: isValid,
      message: message,
      extractedData: extractedData.isEmpty ? null : extractedData,
    );
  }

  void _extractHeuristicData(String text, Map<String, String> data) {
    // Simple heuristic to find names or dates
    final lines = text.split("\n");
    for (var line in lines) {
      if (line.contains(RegExp(r"DOB|Birth", caseSensitive: false))) {
        final dateRegex = RegExp(r"\d{2}/\d{2}/\d{4}");
        final match = dateRegex.firstMatch(line);
        if (match != null) data["DOB"] = match.group(0)!;
      }
    }
  }
}
