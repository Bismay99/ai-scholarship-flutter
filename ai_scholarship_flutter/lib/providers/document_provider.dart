import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'dart:io';
import '../services/ai_verification_service.dart';
import '../services/groq_verification_service.dart';
import '../services/ocr_verification_service.dart';
import '../models/verification_result.dart';

enum FieldType { file, text, number }
enum FieldStatus { pending, processing, completed, failed }

class VerificationField {
  final String id;
  final String title;
  final FieldType type;
  final bool isMandatory;
  FieldStatus status;
  String? value; // Text content or File URL/Name
  String? errorMessage;

  VerificationField({
    required this.id,
    required this.title,
    required this.type,
    this.isMandatory = true,
    this.status = FieldStatus.pending,
    this.value,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'status': status.index,
    'value': value,
  };

  void fromJson(Map<String, dynamic> json) {
    status = FieldStatus.values[json['status'] ?? 0];
    value = json['value'];
  }
}

class DocumentProvider with ChangeNotifier {
  String? _currentUserId;

  final Map<String, List<VerificationField>> sections = {
    'Personal': [
      VerificationField(id: 'aadhaar_card', title: 'Aadhaar Card', type: FieldType.file),
      VerificationField(id: 'aadhaar_number', title: 'Aadhaar Number', type: FieldType.text),
      VerificationField(id: 'pan_card', title: 'PAN Card', type: FieldType.file),
      VerificationField(id: 'pan_number', title: 'PAN Number', type: FieldType.text),
      VerificationField(id: 'gender', title: 'Gender', type: FieldType.text),
      VerificationField(id: 'dob', title: 'Date of Birth', type: FieldType.text),
      VerificationField(id: 'religion', title: 'Religion', type: FieldType.text),
      VerificationField(id: 'category', title: 'Category', type: FieldType.text),
      VerificationField(id: 'full_address', title: 'Full Address', type: FieldType.text),
      VerificationField(id: 'district', title: 'District', type: FieldType.text),
      VerificationField(id: 'block', title: 'Block / ULB', type: FieldType.text),
      VerificationField(id: 'gp_ward', title: 'GP / Ward', type: FieldType.text),
      VerificationField(id: 'village', title: 'Village', type: FieldType.text),
      VerificationField(id: 'pincode', title: 'Pin Code', type: FieldType.number),
      VerificationField(id: 'passport_photo', title: 'Passport Size Photo', type: FieldType.file),
    ],
    'Academic': [
      VerificationField(id: '10th_cert', title: '10th Certificate', type: FieldType.file),
      VerificationField(id: '10th_marks', title: '10th Marks (%)', type: FieldType.number),
      VerificationField(id: '12th_cert', title: '12th Certificate', type: FieldType.file),
      VerificationField(id: '12th_marks', title: '12th Marks (%)', type: FieldType.number),
      VerificationField(id: 'marksheet', title: 'Last Exam Marksheet', type: FieldType.file),
      VerificationField(id: 'latest_marks', title: 'Latest Marks (CGPA/%)', type: FieldType.number),
      VerificationField(id: 'bonafide', title: 'Bonafide Certificate', type: FieldType.file),
      VerificationField(id: 'course_name', title: 'Current Course', type: FieldType.text),
      VerificationField(id: 'stream', title: 'Stream', type: FieldType.text),
      VerificationField(id: 'college_name', title: 'College Name', type: FieldType.text),
      VerificationField(id: 'college_id', title: 'College ID Card', type: FieldType.file),
      VerificationField(id: 'college_id_number', title: 'College ID Number', type: FieldType.text),
      VerificationField(id: 'academic_year', title: 'Academic Year', type: FieldType.text),
    ],
    'Family': [
      VerificationField(id: 'father_name', title: 'Father\'s Name', type: FieldType.text),
      VerificationField(id: 'mother_name', title: 'Mother\'s Name', type: FieldType.text),
      VerificationField(id: 'guardian_name', title: 'Guardian Name', type: FieldType.text),
      VerificationField(id: 'family_income', title: 'Family Income (Annual)', type: FieldType.number),
      VerificationField(id: 'income_cert', title: 'Income Certificate', type: FieldType.file),
    ],
    'Bank': [
      VerificationField(id: 'acc_holder_name', title: 'Account Holder Name', type: FieldType.text),
      VerificationField(id: 'bank_name', title: 'Bank Name', type: FieldType.text),
      VerificationField(id: 'bank_passbook', title: 'Bank Passbook', type: FieldType.file),
      VerificationField(id: 'account_number', title: 'Account Number', type: FieldType.number),
      VerificationField(id: 'ifsc_code', title: 'IFSC Code', type: FieldType.text),
    ],
  };

  /// Initialize and load data for a specific user
  Future<void> loadForUser(String userId) async {
    if (_currentUserId == userId) return; // Already loaded
    
    _currentUserId = userId;
    reset(); // Clear old data

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('data').doc('verification').get();
      if (doc.exists) {
        final data = doc.data()!;
        for (var section in sections.values) {
          for (var field in section) {
            if (data.containsKey(field.id)) {
              field.fromJson(data[field.id]);
              
              // REPAIR: Clear old mock values from previous faulty versions
              if (field.value != null && field.value!.startsWith('verified_local_backup')) {
                print("Repairing field ${field.id}: Clearing old mock local path.");
                field.value = null;
                field.status = FieldStatus.pending;
              }
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      print("Error loading verification data: $e");
    }
  }

  /// Reset all fields
  void reset() {
    for (var section in sections.values) {
      for (var field in section) {
        field.status = FieldStatus.pending;
        field.value = null;
        field.errorMessage = null;
      }
    }
    notifyListeners();
  }

  /// Get a specific field
  VerificationField? getField(String id) {
    for (var section in sections.values) {
      for (var field in section) {
        if (field.id == id) return field;
      }
    }
    return null;
  }

  /// Update text field value
  void updateTextField(String id, String value) {
    final field = getField(id);
    if (field != null) {
      field.value = value.trim();
      field.status = field.value!.isNotEmpty ? FieldStatus.completed : FieldStatus.pending;
      notifyListeners();
    }
  }

  final AiVerificationService _geminiService = AiVerificationService();
  final GroqVerificationService _groqService = GroqVerificationService();
  final OcrVerificationService _ocrService = OcrVerificationService();

  /// Upload file to Firebase Storage
  Future<void> pickAndUploadFile(String id) async {
    if (_currentUserId == null) return;
    
    final field = getField(id);
    if (field == null || field.type != FieldType.file) return;

    // Prevent duplicate processing
    if (field.status == FieldStatus.processing) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      if (result.files.single.bytes == null && result.files.single.path == null) {
        field.status = FieldStatus.failed;
        field.errorMessage = "Could not read file data.";
        notifyListeners();
        return;
      }

      field.status = FieldStatus.processing;
      field.errorMessage = null;
      notifyListeners();

      // Prepare bytes for AI verification and upload
      Uint8List fileBytes;
      if (result.files.single.bytes != null) {
        fileBytes = result.files.single.bytes!;
      } else {
        fileBytes = File(result.files.single.path!).readAsBytesSync();
      }

      // 1. AI VISION VERIFICATION (Multi-service Fallback)
      String mimeType = 'image/jpeg';
      if (result.files.single.name.toLowerCase().endsWith('pdf')) mimeType = 'application/pdf';
      if (result.files.single.name.toLowerCase().endsWith('png')) mimeType = 'image/png';

      try {
        VerificationResult verificationResult;
        
        print("Attempting primary verification with Groq API...");
        verificationResult = await _groqService.verifyDocument(fileBytes, field.title, mimeType);

        if (!verificationResult.isValid && (verificationResult.isConnectionError || verificationResult.message.contains("limit") || verificationResult.message.contains("Error"))) {
          print("Groq failed or limit exceeded, falling back to Gemini...");
          final fallbackResult = await _geminiService.verifyDocument(fileBytes, field.title, mimeType);
          
          // If fallback is a connection error and primary was a quota error, keep primary
          if (!fallbackResult.isValid && fallbackResult.isConnectionError && !verificationResult.isConnectionError) {
             print("Gemini hit network error, keeping previous Groq error message.");
          } else {
             verificationResult = fallbackResult;
          }
        }

        if (!verificationResult.isValid && (verificationResult.isConnectionError || verificationResult.message.contains("reached") || verificationResult.message.contains("Error"))) {
          print("AI models busy or network error, falling back to OCR Space (Direct Scan)...");
          final ocrResult = await _ocrService.verifyDocument(fileBytes, field.title, mimeType);
          
          // Only use OCR result if it's NOT a connection error (like host lookup)
          if (!ocrResult.isValid && ocrResult.isConnectionError) {
            print("OCR Space hit host lookup error, ignoring and keeping best AI error message.");
          } else {
            verificationResult = ocrResult;
          }
        }

        if (!verificationResult.isValid) {
          field.status = FieldStatus.failed;
          // Specialized message for quota exceeded
          if (verificationResult.message.contains("limit reached")) {
            field.errorMessage = "Quota Limit Reached: Please try again in 1 minute.";
          } else {
            field.errorMessage = verificationResult.message;
          }
          notifyListeners();
          return; // Halt upload if AI verification fails
        }

        // --- NEW: AUTO-FILL EXTRACTIONS ---
        if (verificationResult.extractedData != null) {
          _applyExtractions(id, verificationResult.extractedData!);
        }

        // 2. FIREBASE STORAGE UPLOAD
        try {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('verifications/$_currentUserId/$id/$fileName');

          final uploadTask = storageRef.putData(fileBytes);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          field.status = FieldStatus.completed;
          field.value = downloadUrl;
        } catch (e) {
          print("Storage Upload Error: $e");
          
          try {
            // Save to local storage as fallback
            final directory = await getApplicationDocumentsDirectory();
            final vaultPath = Directory('${directory.path}/vault');
            if (!await vaultPath.exists()) {
              await vaultPath.create(recursive: true);
            }
            
            final fileExtension = p.extension(result.files.single.name);
            final localFileName = '${id}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
            final localFile = File('${vaultPath.path}/$localFileName');
            await localFile.writeAsBytes(fileBytes);
            
            field.status = FieldStatus.completed;
            field.value = localFile.path; // Store ABSOLUTE LOCAL PATH
            print("Document verified by AI, but storage failed. Saved to local vault: ${localFile.path}");
          } catch (localError) {
            print("Local Save Error: $localError");
            field.status = FieldStatus.completed;
            field.value = "verified_local_backup/${result.files.single.name}";
          }
          field.errorMessage = null;
        }
      } catch (e) {
        print("Verification Error: $e");
        field.status = FieldStatus.failed;
        field.errorMessage = "Connection error during verification. Check your internet or try again later.";
      }
      
      notifyListeners();
      
      // Auto-save so data isn't lost if connection is interrupted
      saveToFirestore();
    }
  }

  /// Auto-fill text fields based on AI extraction
  void _applyExtractions(String docId, Map<String, String> data) {
    print("Applying extractions for $docId: $data");

    if (docId == 'aadhaar_card') {
      _updateIfPresent(data, ['ID Number', 'Aadhaar Number'], 'aadhaar_number');
      _updateIfPresent(data, ['Name', 'Full Name'], 'acc_holder_name'); // Potentially same as bank holder
      _updateIfPresent(data, ['DOB', 'Date of Birth'], 'dob');
      _updateIfPresent(data, ['Gender'], 'gender');
    } else if (docId == 'pan_card') {
      _updateIfPresent(data, ['ID Number', 'PAN Number'], 'pan_number');
      _updateIfPresent(data, ['Name', 'Full Name'], 'acc_holder_name');
    } else if (docId == 'bank_passbook') {
      _updateIfPresent(data, ['Account Number'], 'account_number');
      _updateIfPresent(data, ['IFSC Code'], 'ifsc_code');
      _updateIfPresent(data, ['Name', 'Account Holder'], 'acc_holder_name');
    } else if (docId == '10th_cert') {
      _updateIfPresent(data, ['Marks', 'Percentage', '10th Marks'], '10th_marks');
    } else if (docId == '12th_cert') {
      _updateIfPresent(data, ['Marks', 'Percentage', '12th Marks'], '12th_marks');
    } else if (docId == 'marksheet') {
      _updateIfPresent(data, ['Marks', 'Percentage', 'Latest Marks', 'CGPA'], 'latest_marks');
    }
    
    notifyListeners();
  }

  void _updateIfPresent(Map<String, String> data, List<String> aiKeys, String fieldId) {
    for (var key in aiKeys) {
      if (data.containsKey(key) && data[key]!.isNotEmpty) {
        final field = getField(fieldId);
        if (field != null) {
          field.value = data[key];
          field.status = FieldStatus.completed;
          print("Auto-filled $fieldId with ${data[key]}");
          return;
        }
      }
    }
  }

  /// Overall verification stats
  bool get isFullyVerified {
    return sections.values.expand((section) => section).where((f) => f.isMandatory).every((f) => f.status == FieldStatus.completed);
  }

  double get verificationProgress {
    final mandatoryFields = sections.values.expand((section) => section).where((f) => f.isMandatory).toList();
    if (mandatoryFields.isEmpty) return 1.0;
    
    final completedCount = mandatoryFields.where((f) => f.status == FieldStatus.completed).length;
    return completedCount / mandatoryFields.length;
  }

  String get verificationStatusText {
    final progress = verificationProgress;
    if (progress == 0) return "Verification Pending";
    if (progress < 1.0) return "Partially Completed";
    return "All Documents Verified";
  }

  /// Save all field states to Firestore
  Future<bool> saveToFirestore() async {
    if (_currentUserId == null) return false;

    // Optional: Validate that required fields are filled
    final dataToSave = <String, dynamic>{};
    for (var section in sections.values) {
      for (var field in section) {
        dataToSave[field.id] = field.toJson();
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('data')
          .doc('verification')
          .set(dataToSave, SetOptions(merge: true));
      return true;
    } catch (e) {
      print("Error saving to Firestore: $e");
      return false;
    }
  }
}
