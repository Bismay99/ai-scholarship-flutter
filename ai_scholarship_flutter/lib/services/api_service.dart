import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late final Dio _dio;
  late final String baseUrl;

  ApiService() {
    baseUrl = dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000'; // Default Android Emulator to localhost
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  // POST /predict-loan
  Future<Map<String, dynamic>> predictLoan(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/predict-loan', data: data);
      return response.data;
    } catch (e) {
      return {
        "status": "error",
        "message": "Failed to predict loan eligibility: $e",
        "isApproved": true, // Fallback for UI simulation
        "confidenceScore": 88
      };
    }
  }

  // POST /upload-documents
  Future<Map<String, dynamic>> uploadDocument(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: "document.jpg"),
      });
      final response = await _dio.post('/upload-documents', data: formData);
      return response.data;
    } catch (e) {
      return {
        "status": "error",
        "message": "Mock OCR extraction fallback",
        "data": {
          "Name": "Alex Johnson",
          "Income": "\$45,000 / year",
          "ID Number": "STU-992-881",
        }
      };
    }
  }

  // GET /scholarships
  Future<List<dynamic>> getScholarships() async {
    try {
      final response = await _dio.get('/scholarships');
      return response.data;
    } catch (e) {
      // Mock data for UI simulation if backend is down
      return [
        {
          "title": "National Merit Tech Grant",
          "amount": "\$5,000",
          "matchPercentage": 92,
          "matchedFactors": ["High GPA", "CS Major"],
          "missedFactors": [],
        },
        {
          "title": "Global AI Innovators Fund",
          "amount": "\$10,000",
          "matchPercentage": 85,
          "matchedFactors": ["CS Major", "Income Bracket"],
          "missedFactors": ["Requires AI Project"],
        }
      ];
    }
  }
}
