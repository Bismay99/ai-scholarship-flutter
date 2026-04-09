import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/auth_provider.dart';
import '../providers/document_provider.dart';
import '../services/ai_verification_service.dart';
import '../services/groq_verification_service.dart';
import '../services/ocr_verification_service.dart';
import '../models/verification_result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoanApplicationScreen extends StatefulWidget {
  final String loanTitle;

  const LoanApplicationScreen({super.key, required this.loanTitle});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // --- Step 1: Personal Details ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  String? _aadhaarUrl;
  bool _isAadhaarVerified = false;
  String _gender = "Male";
  final TextEditingController _studentCreditScoreController = TextEditingController();
  bool _isFetchingScore = false;

  // --- Step 2: Family Details ---
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _parentCreditScoreController = TextEditingController();
  String? _incomeCertUrl;
  bool _isIncomeCertVerified = false;

  // --- Step 3: Academic Details ---
  final TextEditingController _10thController = TextEditingController();
  final TextEditingController _12thController = TextEditingController();
  final TextEditingController _latestMarksController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _streamController = TextEditingController();
  final TextEditingController _collegeNameController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  String? _bonafideUrl;
  String? _marksheetUrl;
  bool _isBonafideVerified = false;
  bool _isMarksheetVerified = false;

  // --- Step 4: Bank Details ---
  final TextEditingController _accHolderController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accNoController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  String? _passbookUrl;
  bool _isPassbookVerified = false;

  final AiVerificationService _geminiService = AiVerificationService();
  final GroqVerificationService _groqService = GroqVerificationService();
  final OcrVerificationService _ocrService = OcrVerificationService();

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _guardianNameController.dispose();
    _incomeController.dispose();
    _10thController.dispose();
    _12thController.dispose();
    _latestMarksController.dispose();
    _courseController.dispose();
    _streamController.dispose();
    _collegeNameController.dispose();
    _collegeIdController.dispose();
    _accHolderController.dispose();
    _bankNameController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    _studentCreditScoreController.dispose();
    _parentCreditScoreController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final docs = Provider.of<DocumentProvider>(context, listen: false);

      // Auto-fill from Auth
      _nameController.text = auth.userName;
      _emailController.text = auth.userEmail;
      _mobileController.text = auth.userContact;
      _dobController.text = auth.userDOB;
      _accHolderController.text = auth.userName;

      // Auto-fill from Document Vault
      final aadhaar = docs.getField('aadhaar_card');
      if (aadhaar?.status == FieldStatus.completed) {
        _aadhaarUrl = aadhaar?.value;
        _isAadhaarVerified = true;
      }
      final aadhaarNoField = docs.getField('aadhaar_number');
      // Note: Aadhaar is now handled via the upload card status instead of a text controller.

      final dobField = docs.getField('dob');
      if (dobField != null && dobField.value != null) _dobController.text = dobField.value!;

      final genderField = docs.getField('gender');
      if (genderField != null && genderField.value != null) {
        String val = genderField.value!.toLowerCase();
        if (val.contains("male") && !val.contains("female")) _gender = "Male";
        else if (val.contains("female")) _gender = "Female";
        else _gender = "Other";
      }

      final father = docs.getField('father_name');
      if (father != null && father.value != null) _fatherNameController.text = father.value!;

      final mother = docs.getField('mother_name');
      if (mother != null && mother.value != null) _motherNameController.text = mother.value!;

      final guardian = docs.getField('guardian_name');
      if (guardian != null && guardian.value != null) _guardianNameController.text = guardian.value!;

      final income = docs.getField('family_income');
      if (income?.status == FieldStatus.completed) {
        _incomeController.text = income?.value ?? "";
      }

      final m10th = docs.getField('10th_marks');
      if (m10th != null && m10th.value != null) _10thController.text = m10th.value!;

      final m12th = docs.getField('12th_marks');
      if (m12th != null && m12th.value != null) _12thController.text = m12th.value!;

      final latestMarks = docs.getField('latest_marks');
      if (latestMarks != null && latestMarks.value != null) _latestMarksController.text = latestMarks.value!;

      final course = docs.getField('course_name');
      if (course != null && course.value != null) _courseController.text = course.value!;

      final stream = docs.getField('stream');
      if (stream != null && stream.value != null) _streamController.text = stream.value!;

      final college = docs.getField('college_name');
      if (college != null && college.value != null) _collegeNameController.text = college.value!;

      final bank = docs.getField('bank_passbook');
      if (bank?.status == FieldStatus.completed) {
        _passbookUrl = bank?.value;
        _isPassbookVerified = true;
      }

      final bankNameField = docs.getField('bank_name');
      if (bankNameField != null && bankNameField.value != null) _bankNameController.text = bankNameField.value!;

      final accHolder = docs.getField('acc_holder_name');
      if (accHolder != null && accHolder.value != null) _accHolderController.text = accHolder.value!;

      final ifsc = docs.getField('ifsc_code');
      if (ifsc?.status == FieldStatus.completed) {
        _ifscController.text = ifsc?.value ?? "";
      }

      final accNo = docs.getField('account_number');
      if (accNo?.status == FieldStatus.completed) {
        _accNoController.text = accNo?.value ?? "";
      }

      setState(() {});
    });
  }

  Future<void> _pickAndVerify(String docType, Function(String, bool) onComplete) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'png'],
      withData: true,
    );

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI is verifying your $docType..."), backgroundColor: Color(0xFF7C3AED)),
      );

      Uint8List fileBytes = result.files.single.bytes!;
      String mimeType = result.files.single.name.endsWith('pdf') ? 'application/pdf' : 'image/jpeg';

      VerificationResult verification;
      
      try {
        print("Attempting primary verification with Groq API...");
        verification = await _groqService.verifyDocument(fileBytes, docType, mimeType);

        if (!verification.isValid && (verification.isConnectionError || verification.message.contains("limit") || verification.message.contains("Error"))) {
          print("Groq failed or limit exceeded, falling back to Gemini...");
          final fallbackResult = await _geminiService.verifyDocument(fileBytes, docType, mimeType);
          
          if (!fallbackResult.isValid && fallbackResult.isConnectionError && !verification.isConnectionError) {
             print("Gemini hit network error, keeping previous Groq message.");
          } else {
             verification = fallbackResult;
          }
        }

        if (!verification.isValid && (verification.isConnectionError || verification.message.contains("reached") || verification.message.contains("Error"))) {
          print("AI models busy or network error, falling back to OCR Space (Direct Scan)...");
          final ocrResult = await _ocrService.verifyDocument(fileBytes, docType, mimeType);
          
          if (!ocrResult.isValid && ocrResult.isConnectionError) {
            print("OCR Space hit host lookup error, keeping best available AI error.");
          } else {
            verification = ocrResult;
          }
        }
      } catch (e) {
        verification = VerificationResult(isValid: false, message: "Technical error: $e", isConnectionError: true);
      }

      if (verification.isValid) {
        // Upload to Firebase Storage
        final userId = Provider.of<AuthProvider>(context, listen: false).userId;
        final fileName = "${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
        final ref = FirebaseStorage.instance.ref().child('loan_docs/$userId/$docType/$fileName');
        
        await ref.putData(fileBytes);
        final url = await ref.getDownloadURL();
        
        onComplete(url, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$docType Verified! ✅"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${verification.message}"), backgroundColor: Colors.redAccent),
        );
      }
      setState(() {});
    }
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Check if attachments are verified
    if (!_isAadhaarVerified || !_isIncomeCertVerified || !_isBonafideVerified || !_isMarksheetVerified || !_isPassbookVerified) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text("Please upload and verify all required documents (Aadhaar, Income, etc.)."), backgroundColor: Colors.orange),
       );
       return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = Provider.of<AuthProvider>(context, listen: false).userId;
      
      await FirebaseFirestore.instance.collection('loan_applications').add({
        'userId': userId,
        'loanTitle': widget.loanTitle,
        'status': 'Pending',
        'submittedAt': FieldValue.serverTimestamp(),
        'personal': {
          'name': _nameController.text,
          'dob': _dobController.text,
          'gender': _gender,
          'mobile': _mobileController.text,
          'email': _emailController.text,
          'aadhaarUrl': _aadhaarUrl,
          'pan': _panController.text,
          'creditScore': _studentCreditScoreController.text,
        },
        'family': {
          'fatherName': _fatherNameController.text,
          'motherName': _motherNameController.text,
          'income': _incomeController.text,
          'incomeCertUrl': _incomeCertUrl,
          'parentCreditScore': _parentCreditScoreController.text,
        },
        'academic': {
          '10th': _10thController.text,
          '12th': _12thController.text,
          'latestMarks': _latestMarksController.text,
          'course': _courseController.text,
          'college': _collegeNameController.text,
          'bonafideUrl': _bonafideUrl,
          'marksheetUrl': _marksheetUrl,
        },
        'bank': {
          'accHolder': _accHolderController.text,
          'bankName': _bankNameController.text,
          'accNo': _accNoController.text,
          'ifsc': _ifscController.text,
          'passbookUrl': _passbookUrl,
        }
      });

      setState(() {
        _isSubmitting = false;
        _showSuccessDialog();
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Submission Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80).animate().scale(duration: 500.ms),
            SizedBox(height: 20),
            Text("Applied Successfully!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Your loan application for ${widget.loanTitle} has been submitted for review.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to card
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7C3AED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text("Return to Dashboard", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF020617),
      appBar: AppBar(
        title: Text("Loan Application", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                   _buildStep1(),
                   _buildStep2(),
                   _buildStep3(),
                   _buildStep4(),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
     return Container(
       padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
       child: Row(
         children: List.generate(4, (index) {
           bool isDone = index < _currentStep;
           bool isCurrent = index == _currentStep;
           return Expanded(
             child: Row(
               children: [
                 Container(
                   width: 32,
                   height: 32,
                   decoration: BoxDecoration(
                     color: isDone || isCurrent ? Color(0xFF7C3AED) : Color(0xFF1E293B),
                     shape: BoxShape.circle,
                   ),
                   child: Center(
                     child: isDone 
                       ? Icon(Icons.check, color: Colors.white, size: 16)
                       : Text("${index + 1}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                   ),
                 ),
                 if (index < 3)
                   Expanded(
                     child: Container(
                       height: 2,
                       color: isDone ? Color(0xFF7C3AED) : Color(0xFF1E293B),
                     ),
                   )
               ],
             ),
           );
         }),
       ),
     );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(duration: 300.ms, curve: Curves.ease),
              child: Text("Back", style: TextStyle(color: Colors.white70)),
            )
          else
            SizedBox.shrink(),
          
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 0) {
                // Step 1 Validation
                if (_studentCreditScoreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please verify your CIBIL score first.")));
                  return;
                }
              }
              
              if (_currentStep == 1) {
                // Step 2 Validation: Check eligibility
                final studentScore = int.tryParse(_studentCreditScoreController.text) ?? 0;
                final parentScore = int.tryParse(_parentCreditScoreController.text) ?? 0;
                
                if (studentScore < 700 || parentScore < 700) {
                  _showIneligibleDialog(studentScore, parentScore);
                  return;
                }
              }

              if (_currentStep < 3) {
                _pageController.nextPage(duration: 300.ms, curve: Curves.ease);
              } else {
                _submitApplication();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7C3AED),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSubmitting 
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_currentStep == 3 ? "Submit" : "Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle("Personal Details", "Step 1 of 4"),
          SizedBox(height: 24),
          _buildTextField(_nameController, "Full Name", Icons.person_outlined),
          _buildTextField(_dobController, "Date of Birth", Icons.calendar_today, isDate: true),
          _buildDropdown("Gender", _gender, ["Male", "Female", "Other"], (val) => setState(() => _gender = val!)),
          _buildTextField(_mobileController, "Mobile Number", Icons.phone, keyboardType: TextInputType.phone),
          _buildTextField(_emailController, "Email ID", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          SizedBox(height: 10),
          _buildUploadCard(
            "Aadhaar Card", 
            _isAadhaarVerified, 
            () => _pickAndVerify("Aadhaar Card", (url, status) {
              _aadhaarUrl = url;
              _isAadhaarVerified = status;
            })
          ),
          SizedBox(height: 15),
          _buildTextField(_panController, "PAN Card Number", Icons.credit_card_outlined),
          _buildCreditScoreField(_studentCreditScoreController, "Your CIBIL Score", true),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle("Family Details", "Step 2 of 4"),
          SizedBox(height: 24),
          _buildTextField(_fatherNameController, "Father’s Name", Icons.family_restroom),
          _buildTextField(_motherNameController, "Mother’s Name", Icons.woman),
          _buildTextField(_guardianNameController, "Guardian Name (Optional)", Icons.security),
          _buildTextField(_incomeController, "Family Annual Income", Icons.monetization_on_outlined, keyboardType: TextInputType.number),
          SizedBox(height: 20),
          _buildUploadCard(
            "Income Certificate", 
            _isIncomeCertVerified, 
            () => _pickAndVerify("Income Certificate", (url, status) {
              _incomeCertUrl = url;
              _isIncomeCertVerified = status;
            })
          ),
          SizedBox(height: 16),
          _buildCreditScoreField(_parentCreditScoreController, "Parent/Guardian CIBIL Score", false),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle("Academic Details", "Step 3 of 4"),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField(_10thController, "10th %", Icons.grade)),
              SizedBox(width: 15),
              Expanded(child: _buildTextField(_12thController, "12th %", Icons.grade)),
            ],
          ),
          _buildTextField(_latestMarksController, "Latest CGPA / Percentage", Icons.auto_graph),
          _buildTextField(_courseController, "Course Name", Icons.school_outlined),
          _buildTextField(_streamController, "Stream", Icons.book_outlined),
          _buildTextField(_collegeNameController, "College Name", Icons.business),
          _buildTextField(_collegeIdController, "College ID Number", Icons.vignette_outlined),
          SizedBox(height: 20),
          _buildUploadCard(
            "Bonafide Certificate", 
            _isBonafideVerified, 
            () => _pickAndVerify("Bonafide Certificate", (url, status) {
              _bonafideUrl = url;
              _isBonafideVerified = status;
            })
          ),
          SizedBox(height: 10),
          _buildUploadCard(
            "Last Exam Marksheet", 
            _isMarksheetVerified, 
            () => _pickAndVerify("Marksheet", (url, status) {
              _marksheetUrl = url;
              _isMarksheetVerified = status;
            })
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle("Bank Details", "Step 4 of 4"),
          SizedBox(height: 24),
          _buildTextField(_accHolderController, "Account Holder Name", Icons.person_pin),
          _buildTextField(_bankNameController, "Bank Name", Icons.account_balance),
          _buildTextField(_accNoController, "Account Number", Icons.numbers, keyboardType: TextInputType.number),
          _buildTextField(_ifscController, "IFSC Code", Icons.code),
          SizedBox(height: 20),
          _buildUploadCard(
            "Bank Passbook", 
            _isPassbookVerified, 
            () => _pickAndVerify("Bank Passbook", (url, status) {
              _passbookUrl = url;
              _isPassbookVerified = status;
            })
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle, style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12)),
        Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: isDate,
        onTap: isDate ? () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
            firstDate: DateTime(1990),
            lastDate: DateTime.now(),
          );
          if (picked != null) controller.text = "${picked.day}/${picked.month}/${picked.year}";
        } : null,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Color(0xFF7C3AED)),
          filled: true,
          fillColor: Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white10)),
        ),
        validator: (v) => v!.isEmpty ? "Mandatory field" : null,
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
           SizedBox(height: 8),
           Container(
             padding: EdgeInsets.symmetric(horizontal: 16),
             decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
             child: DropdownButtonHideUnderline(
               child: DropdownButton<String>(
                 value: value,
                 isExpanded: true,
                 dropdownColor: Color(0xFF0F172A),
                 style: TextStyle(color: Colors.white),
                 onChanged: onChanged,
                 items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
               ),
             ),
           ),
         ],
       ),
     );
  }

  Widget _buildUploadCard(String title, bool isVerified, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isVerified ? Colors.green.withOpacity(0.5) : Color(0xFF7C3AED).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(isVerified ? Icons.check_circle : Icons.cloud_upload_outlined, color: isVerified ? Colors.green : Color(0xFF7C3AED), size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(isVerified ? "Verified & Attached" : "Upload & Verify with AI", style: TextStyle(color: isVerified ? Colors.green : Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (!isVerified) Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditScoreField(TextEditingController controller, String label, bool canFetch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: TextFormField(
                    controller: controller,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "---", hintStyle: TextStyle(color: Colors.white24)),
                  ),
                ),
              ),
              if (canFetch) ...[
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isFetchingScore ? null : () => _simulateScoreFetch(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22D3EE).withOpacity(0.1),
                    foregroundColor: const Color(0xFF22D3EE),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF22D3EE), width: 0.5)),
                  ),
                  child: _isFetchingScore 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF22D3EE)))
                    : const Text("Fetch AI Score", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ] else if (controller.text.isEmpty) ...[
                 const SizedBox(width: 12),
                 TextButton(
                   onPressed: () => _simulateScoreFetch(controller),
                   child: const Text("Simulate Parent Score"),
                 )
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _simulateScoreFetch(TextEditingController controller) async {
    setState(() => _isFetchingScore = true);
    await Future.delayed(const Duration(seconds: 2));
    // Simulate a value between 600 and 850
    final score = 600 + (DateTime.now().millisecond % 251); 
    controller.text = score.toString();
    setState(() => _isFetchingScore = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("CIBIL Score verified: $score"), backgroundColor: Colors.green));
  }

  void _showIneligibleDialog(int student, int parent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.redAccent.withOpacity(0.3))),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 12),
            Text("Eligibility Filter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your application does not meet the minimum credit requirements for this loan.", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            _buildScoreRow("Student Score", student),
            _buildScoreRow("Guardian Score", parent),
            const Divider(color: Colors.white10, height: 30),
            const Text("Requirement: Minimum 700 CIBIL Score", style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            const Text("AI Suggestion: Clear outstanding bills or add a co-applicant with a higher credit score to qualify.", style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("I Understand", style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, int score) {
    bool isLow = score < 700;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(score.toString(), style: TextStyle(color: isLow ? Colors.redAccent : Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
