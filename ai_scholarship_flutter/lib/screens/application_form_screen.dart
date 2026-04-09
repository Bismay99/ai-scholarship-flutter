import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/document_provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  final String applicationTitle;

  const ApplicationFormScreen({super.key, required this.applicationTitle});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSuccess = false;

  // --- Student Profile Controllers ---
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _aadhaarController;
  late TextEditingController _mobileController;
  late TextEditingController _altMobileController;
  late TextEditingController _emailController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _guardianNameController;
  late TextEditingController _districtController;
  late TextEditingController _blockController;
  late TextEditingController _gpWardController;
  late TextEditingController _villageController;
  late TextEditingController _pinCodeController;
  late TextEditingController _addressController;
  late TextEditingController _academicYearController;
  late TextEditingController _departmentController;
  late TextEditingController _schemeController;
  
  String _category = "General";
  String _gender = "Male";
  String _religion = "Hinduism";

  // --- Academic Info Controllers ---
  late TextEditingController _courseController;
  late TextEditingController _boardController;
  late TextEditingController _passingYearController;
  late TextEditingController _rollNoController;
  late TextEditingController _totalMarksController;
  late TextEditingController _securedMarksController;
  late TextEditingController _percentageController;
  late TextEditingController _instituteController;
  late TextEditingController _branchController;
  late TextEditingController _natureOfCourseController;
  late TextEditingController _courseYearController;
  late TextEditingController _admissionNoController;
  late TextEditingController _admissionDateController;

  // --- Account Info Controllers ---
  late TextEditingController _ifscController;
  late TextEditingController _bankNameController;
  late TextEditingController _branchNameController;
  late TextEditingController _accHolderController;
  late TextEditingController _accNoController;
  late TextEditingController _confirmAccNoController;
  String _aadhaarLinked = "Yes";

  // --- Verification Flags ---
  bool _isAadhaarVerified = false;
  bool _isIncomeVerified = false;
  bool _isMarksVerified = false;
  bool _isBankVerified = false;
  bool _isProfileVerified = false;

  @override
  void initState() {
    super.initState();
    // Student Profile
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _aadhaarController = TextEditingController();
    _mobileController = TextEditingController();
    _altMobileController = TextEditingController();
    _emailController = TextEditingController();
    _fatherNameController = TextEditingController();
    _motherNameController = TextEditingController();
    _guardianNameController = TextEditingController();
    _districtController = TextEditingController();
    _blockController = TextEditingController();
    _gpWardController = TextEditingController();
    _villageController = TextEditingController();
    _pinCodeController = TextEditingController();
    _addressController = TextEditingController();
    _academicYearController = TextEditingController(text: "2024-25");
    _departmentController = TextEditingController();
    _schemeController = TextEditingController();

    // Academic
    _courseController = TextEditingController();
    _boardController = TextEditingController();
    _passingYearController = TextEditingController();
    _rollNoController = TextEditingController();
    _totalMarksController = TextEditingController();
    _securedMarksController = TextEditingController();
    _percentageController = TextEditingController();
    _instituteController = TextEditingController();
    _branchController = TextEditingController();
    _natureOfCourseController = TextEditingController();
    _courseYearController = TextEditingController();
    _admissionNoController = TextEditingController();
    _admissionDateController = TextEditingController();

    // Account
    _ifscController = TextEditingController();
    _bankNameController = TextEditingController();
    _branchNameController = TextEditingController();
    _accHolderController = TextEditingController();
    _accNoController = TextEditingController();
    _confirmAccNoController = TextEditingController();

    // Auto-fill logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final docs = Provider.of<DocumentProvider>(context, listen: false);

      // Auth Data
      if (auth.userName.isNotEmpty) {
        _nameController.text = auth.userName;
        _accHolderController.text = auth.userName;
        _isProfileVerified = true;
      }
      _emailController.text = auth.userEmail;
      _dobController.text = auth.userDOB;
      _mobileController.text = auth.userContact;

      // Document Vault Data
      final aadhaarField = docs.getField('aadhaar_card');
      if (aadhaarField != null && aadhaarField.status == FieldStatus.completed) {
        _isAadhaarVerified = true;
      }
      final aadhaarNo = docs.getField('aadhaar_number');
      if (aadhaarNo != null && aadhaarNo.value != null) _aadhaarController.text = aadhaarNo.value!;

      final genderField = docs.getField('gender');
      if (genderField != null && genderField.value != null) {
        String val = genderField.value!.toLowerCase();
        if (val.contains("male") && !val.contains("female")) _gender = "Male";
        else if (val.contains("female")) _gender = "Female";
        else _gender = "Other";
      }

      final religionField = docs.getField('religion');
      if (religionField != null && religionField.value != null) {
        String val = religionField.value!.toLowerCase();
        if (val.contains("hindu")) _religion = "Hinduism";
        else if (val.contains("islam") || val.contains("muslim")) _religion = "Islam";
        else if (val.contains("christ")) _religion = "Christianity";
        else if (val.contains("sikh")) _religion = "Sikhism";
        else if (val.contains("buddh")) _religion = "Buddhism";
        else if (val.contains("jain")) _religion = "Jainism";
      }

      final categoryField = docs.getField('category');
      if (categoryField != null && categoryField.value != null) {
        String val = categoryField.value!.toUpperCase();
        if (val.contains("GENERAL")) _category = "General";
        else if (val.contains("OBC")) _category = "OBC";
        else if (val.contains("SC")) _category = "SC";
        else if (val.contains("ST")) _category = "ST";
      }

      final addrField = docs.getField('full_address');
      if (addrField != null && addrField.value != null) _addressController.text = addrField.value!;

      final distField = docs.getField('district');
      if (distField != null && distField.value != null) _districtController.text = distField.value!;

      final blockField = docs.getField('block');
      if (blockField != null && blockField.value != null) _blockController.text = blockField.value!;

      final gpField = docs.getField('gp_ward');
      if (gpField != null && gpField.value != null) _gpWardController.text = gpField.value!;

      final villField = docs.getField('village');
      if (villField != null && villField.value != null) _villageController.text = villField.value!;

      final pinField = docs.getField('pincode');
      if (pinField != null && pinField.value != null) _pinCodeController.text = pinField.value!;

      final father = docs.getField('father_name');
      if (father != null && father.value != null) _fatherNameController.text = father.value!;

      final mother = docs.getField('mother_name');
      if (mother != null && mother.value != null) _motherNameController.text = mother.value!;

      final guardian = docs.getField('guardian_name');
      if (guardian != null && guardian.value != null) _guardianNameController.text = guardian.value!;

      final marksField = docs.getField('marksheet');
      if (marksField != null && marksField.status == FieldStatus.completed) {
        _isMarksVerified = true;
      }
      final latestMarks = docs.getField('latest_marks');
      if (latestMarks != null && latestMarks.value != null) _percentageController.text = latestMarks.value!;

      final course = docs.getField('course_name');
      if (course != null && course.value != null) _courseController.text = course.value!;

      final college = docs.getField('college_name');
      if (college != null && college.value != null) _instituteController.text = college.value!;

      final streamField = docs.getField('stream');
      if (streamField != null && streamField.value != null) _branchController.text = streamField.value!;

      final incomeField = docs.getField('family_income');
      if (incomeField != null && incomeField.status == FieldStatus.completed) {
        _isIncomeVerified = true;
      }

      final bankPassbook = docs.getField('bank_passbook');
      if (bankPassbook != null && bankPassbook.status == FieldStatus.completed) {
        _isBankVerified = true;
      }

      final ifscField = docs.getField('ifsc_code');
      if (ifscField != null && ifscField.status == FieldStatus.completed) {
         _ifscController.text = ifscField.value ?? "";
      }

      final accField = docs.getField('account_number');
      if (accField != null && accField.status == FieldStatus.completed) {
         _accNoController.text = accField.value ?? "";
         _confirmAccNoController.text = accField.value ?? "";
      }

      final fNameField = docs.getField('father_name');
      if (fNameField != null && fNameField.status == FieldStatus.completed) {
         _fatherNameController.text = fNameField.value ?? "";
      }

      final mNameField = docs.getField('mother_name');
      if (mNameField != null && mNameField.status == FieldStatus.completed) {
         _motherNameController.text = mNameField.value ?? "";
      }
      
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _aadhaarController.dispose();
    _mobileController.dispose();
    _altMobileController.dispose();
    _emailController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _guardianNameController.dispose();
    _districtController.dispose();
    _blockController.dispose();
    _gpWardController.dispose();
    _villageController.dispose();
    _pinCodeController.dispose();
    _addressController.dispose();
    _academicYearController.dispose();
    _departmentController.dispose();
    _schemeController.dispose();
    _courseController.dispose();
    _boardController.dispose();
    _passingYearController.dispose();
    _rollNoController.dispose();
    _totalMarksController.dispose();
    _securedMarksController.dispose();
    _percentageController.dispose();
    _instituteController.dispose();
    _branchController.dispose();
    _natureOfCourseController.dispose();
    _courseYearController.dispose();
    _admissionNoController.dispose();
    _admissionDateController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _accHolderController.dispose();
    _accNoController.dispose();
    _confirmAccNoController.dispose();
    super.dispose();
  }

  void _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Application', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApplicationContextCard(),
            const SizedBox(height: 30),
            
            // --- SECTION 1: Student Profile ---
            _buildSectionHeader("1) Student Profile Information", Icons.person_add_alt_1),
            _buildFormCard([
              _buildTextField(label: "Applicant Full Name", icon: Icons.person_outline, controller: _nameController, isVerified: _isProfileVerified, delay: 100),
              _buildRow([
                _buildDropdownField("Category", _category, ["General", "OBC", "SC", "ST"], (v) => setState(() => _category = v!), 150),
                _buildDropdownField("Gender", _gender, ["Male", "Female", "Other"], (v) => setState(() => _gender = v!), 150),
              ]),
              _buildRow([
                _buildDropdownField("Religion", _religion, ["Hinduism", "Islam", "Christianity", "Sikhism", "Buddhism", "Jainism"], (v) => setState(() => _religion = v!), 200),
                _buildTextField(label: "Date of Birth", icon: Icons.calendar_today, controller: _dobController, delay: 200),
              ]),
              _buildTextField(label: "Aadhaar Number", icon: Icons.fingerprint, controller: _aadhaarController, keyboardType: TextInputType.number, isVerified: _isAadhaarVerified, delay: 250),
              _buildRow([
                _buildTextField(label: "Mobile Number", icon: Icons.phone, controller: _mobileController, keyboardType: TextInputType.phone, delay: 300),
                _buildTextField(label: "Alternative Mobile", icon: Icons.phone_android, controller: _altMobileController, keyboardType: TextInputType.phone, delay: 300),
              ]),
              _buildTextField(label: "Email ID", icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress, delay: 350),
              _buildTextField(label: "Father’s Name", icon: Icons.family_restroom, controller: _fatherNameController, delay: 400),
              _buildTextField(label: "Mother’s Name", icon: Icons.woman, controller: _motherNameController, delay: 450),
              _buildTextField(label: "Guardian Name", icon: Icons.security, controller: _guardianNameController, delay: 500),
              _buildRow([
                _buildTextField(label: "District", icon: Icons.location_city, controller: _districtController, delay: 550),
                _buildTextField(label: "Block / ULB", icon: Icons.map_outlined, controller: _blockController, delay: 550),
              ]),
              _buildRow([
                _buildTextField(label: "GP / Ward", icon: Icons.apartment, controller: _gpWardController, delay: 600),
                _buildTextField(label: "Village", icon: Icons.home_outlined, controller: _villageController, delay: 600),
              ]),
              _buildRow([
                _buildTextField(label: "Pin Code", icon: Icons.pin_drop, controller: _pinCodeController, keyboardType: TextInputType.number, delay: 650),
                _buildTextField(label: "Academic Year", icon: Icons.event, controller: _academicYearController, delay: 650),
              ]),
              _buildTextField(label: "Full Address", icon: Icons.location_on_outlined, controller: _addressController, delay: 700),
              _buildRow([
                _buildTextField(label: "Department", icon: Icons.business, controller: _departmentController, delay: 750),
                _buildTextField(label: "Scheme", icon: Icons.list_alt, controller: _schemeController, delay: 750),
              ]),
            ]),
            
            const SizedBox(height: 30),
            
            // --- SECTION 2: Academic Info ---
            _buildSectionHeader("2) Academic Information", Icons.school),
            _buildFormCard([
              _buildTextField(label: "Course / Degree", icon: Icons.book_outlined, controller: _courseController, delay: 100),
              _buildTextField(label: "Board / University", icon: Icons.gavel_outlined, controller: _boardController, delay: 150),
              _buildRow([
                _buildTextField(label: "Passing Year", icon: Icons.calendar_month, controller: _passingYearController, delay: 200),
                _buildTextField(label: "Roll Number", icon: Icons.numbers, controller: _rollNoController, delay: 200),
              ]),
              _buildRow([
                _buildTextField(label: "Total Marks", icon: Icons.summarize_outlined, controller: _totalMarksController, keyboardType: TextInputType.number, delay: 250),
                _buildTextField(label: "Secured Marks", icon: Icons.grade_outlined, controller: _securedMarksController, keyboardType: TextInputType.number, delay: 250),
              ]),
              _buildTextField(label: "Percentage (%)", icon: Icons.percent, controller: _percentageController, keyboardType: TextInputType.number, isVerified: _isMarksVerified, delay: 300),
              _buildTextField(label: "Institute Name", icon: Icons.account_balance, controller: _instituteController, delay: 350),
              _buildTextField(label: "Branch / Stream", icon: Icons.mediation, controller: _branchController, delay: 400),
              _buildRow([
                _buildTextField(label: "Nature of Course", icon: Icons.timer_outlined, controller: _natureOfCourseController, delay: 450),
                _buildTextField(label: "Course Year", icon: Icons.format_list_numbered, controller: _courseYearController, delay: 450),
              ]),
              _buildTextField(label: "Admission / Reg No", icon: Icons.vignette_outlined, controller: _admissionNoController, delay: 500),
              _buildTextField(label: "Admission Date", icon: Icons.date_range, controller: _admissionDateController, delay: 550),
            ]),

            const SizedBox(height: 30),
            
            // --- SECTION 3: Account Info ---
            _buildSectionHeader("3) Account Information", Icons.account_balance_wallet_outlined),
            _buildFormCard([
              _buildTextField(label: "IFSC Code", icon: Icons.code, controller: _ifscController, isVerified: _isBankVerified, delay: 100),
              _buildTextField(label: "Bank Name", icon: Icons.business, controller: _bankNameController, delay: 150),
              _buildTextField(label: "Branch Name", icon: Icons.villa_outlined, controller: _branchNameController, delay: 200),
              _buildTextField(label: "Account Holder Name", icon: Icons.person_pin, controller: _accHolderController, delay: 250),
              _buildTextField(label: "Account Number", icon: Icons.credit_card, controller: _accNoController, keyboardType: TextInputType.number, delay: 300),
              _buildTextField(label: "Re-type Account Number", icon: Icons.lock_outline, controller: _confirmAccNoController, keyboardType: TextInputType.number, delay: 350),
              _buildDropdownField("Aadhaar Linked?", _aadhaarLinked, ["Yes", "No"], (v) => setState(() => _aadhaarLinked = v!), 400),
            ]),

            const SizedBox(height: 30),
            
            // --- SECTION 4: Checklist ---
            _buildSectionHeader("Documents Checklist", Icons.fact_check_outlined),
            _buildFormCard([
               _buildRequirementItem("Aadhaar Card", 'aadhaar_card', 100),
               _buildRequirementItem("Passport Size Photo", 'passport_photo', 150),
               _buildRequirementItem("Bank Passbook (Front Page)", 'bank_passbook', 200),
               _buildRequirementItem("All Marksheets", 'marksheet', 250),
               _buildRequirementItem("Admission Proof / ID Card", 'college_id', 300),
            ]),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF1E3A8A)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
                  ]
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Scholarship Application", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationContextCard() {
     return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.school, color: Color(0xFF22D3EE), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SCHOLARSHIP SCHEME:", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(widget.applicationTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF22D3EE), size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.2)),
      ),
      child: Column(children: children.expand((w) => [w, const SizedBox(height: 15)]).toList()..removeLast()),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.key < children.length - 1 ? 12 : 0),
          child: e.value,
        ),
      )).toList(),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged, int delay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F172A),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: onChanged,
              items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms);
  }

  Widget _buildTextField({
    String? label, 
    required IconData icon, 
    TextInputType? keyboardType, 
    required int delay,
    TextEditingController? controller,
    bool isVerified = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF22D3EE), size: 18),
            suffixIcon: isVerified ? const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Tooltip(
                message: "Verified & Auto-filled",
                child: Icon(Icons.verified, color: Color(0xFF34D399), size: 16),
              ),
            ) : null,
            filled: true,
            fillColor: const Color(0xFF1E293B),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFF1E3A8A).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF22D3EE)),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms);
  }

  Widget _buildRequirementItem(String title, String fieldId, int delay) {
    final docs = Provider.of<DocumentProvider>(context);
    final field = docs.getField(fieldId);
    final isDone = field?.status == FieldStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDone ? const Color(0xFF34D399).withOpacity(0.3) : const Color(0xFF1E3A8A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.pending_outlined,
            color: isDone ? const Color(0xFF34D399) : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isDone ? Colors.white : Colors.white54,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isDone)
            const Text("Auto-Attached", style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 80),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 30),
          const Text(
            "Application Submitted\nSuccessfully!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.2),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFBBF24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.pending_actions, color: Color(0xFFFBBF24), size: 20),
                SizedBox(width: 10),
                Text("Status: Pending", style: TextStyle(color: Color(0xFFFBBF24), fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 50),
          OutlinedButton.icon(
             onPressed: () => Navigator.pop(context),
             icon: const Icon(Icons.home, color: Color(0xFF22D3EE)),
             label: const Text("Return to Dashboard", style: TextStyle(color: Color(0xFF22D3EE), fontSize: 16, fontWeight: FontWeight.bold)),
             style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF22D3EE)),
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             ),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }
}
