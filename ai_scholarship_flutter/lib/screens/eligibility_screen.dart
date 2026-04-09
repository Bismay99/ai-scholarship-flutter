import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_config.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form State Values
  String _gender = 'Male';
  String? _category;
  String? _specialCategory;
  String? _qualification;
  String? _course;
  String? _institutionType;
  String _studyingInOdisha = 'Yes';
  String _kaliaBeneficiary = 'Yes';
  String _labourCard = 'Yes';
  String? _income;
  final TextEditingController _marksController = TextEditingController();

  bool _isChecking = false;
  bool _showResults = false;
  Map<String, dynamic>? _resultData;

  // Dropdown Options
  final List<String> _categoryOptions = ['General', 'OBC', 'SC', 'ST'];
  final List<String> _specialOptions = ['None', 'PWD', 'Single Girl Child'];
  final List<String> _qualOptions = ['10th Pass', '12th Pass', 'Graduate', 'Post Graduate'];
  final List<String> _courseOptions = ['B.Tech', 'MBA', 'Medical', 'Arts', 'Science'];
  final List<String> _institutionOptions = ['Government', 'Private', 'Aided'];
  final List<String> _incomeOptions = ['< 2 Lakh', '2-5 Lakh', '> 5 Lakh'];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_category == null || _qualification == null || _course == null || _institutionType == null || _income == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all dropdowns')));
        return;
      }

      setState(() {
        _isChecking = true;
        _showResults = false;
      });

      try {
        // Map UI values to existing backend payload roughly
        int incomeVal = 300000;
        if (_income == '< 2 Lakh') incomeVal = 150000;
        if (_income == '> 5 Lakh') incomeVal = 600000;

        String loc = _studyingInOdisha == 'Yes' ? 'Rural' : 'Urban';

        final apiUrl = Uri.parse('${ApiConfig.aiScoreBaseUrl}/calculate-score');

        final response = await http.post(
          apiUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'income': incomeVal,
            'marks': _marksController.text,
            'location': loc,
            'category': _category ?? 'General',
            'creditScore': null,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (mounted) {
            setState(() {
              _resultData = data;
              _showResults = true;
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Server Error (${response.statusCode}): Failed to fetch eligibility score at ${ApiConfig.aiScoreBaseUrl}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          String baseUrl = ApiConfig.aiScoreBaseUrl;
          String errorMsg = "AI Server unreachable ($baseUrl). Please verify your backend is running and the IP is correct.";
          if (e.toString().contains("TimeoutException")) {
            errorMsg = "Request timed out ($baseUrl). The server might be slow or unreachable from this network.";
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg'), duration: const Duration(seconds: 5)),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isChecking = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _marksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Check Eligibility'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Check your eligibility",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 5),
              Text(
                "Help us to find the best Scholarship schemes for you",
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              
              const SizedBox(height: 35),
              
              // Gender Toggle
              _buildLabel("Choose your gender *", theme),
              _buildToggleList(
                options: ['Male', 'Female', 'Others'],
                selectedValue: _gender,
                onChanged: (val) => setState(() => _gender = val),
                 theme: theme,
              ),
              
              const SizedBox(height: 25),
              
              // Row 1: Category & Special Category
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownLabel("Select your category *", _category, _categoryOptions, (val) => setState(() => _category = val), theme),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildDropdownLabel("Special category", _specialCategory, _specialOptions, (val) => setState(() => _specialCategory = val), theme),
                  ),
                ],
              ),
              
              const SizedBox(height: 25),
              
              // Row 2: Qualification & Course
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownLabel("Highest qualification *", _qualification, _qualOptions, (val) => setState(() => _qualification = val), theme),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildDropdownLabel("Course you are pursuing to study *", _course, _courseOptions, (val) => setState(() => _course = val), theme),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Row 3: Institution & Odisha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownLabel("Institution Type *", _institutionType, _institutionOptions, (val) => setState(() => _institutionType = val), theme),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Studying in Odisha *", theme),
                        _buildToggleList(
                          options: ['Yes', 'No'],
                          selectedValue: _studyingInOdisha,
                          onChanged: (val) => setState(() => _studyingInOdisha = val),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Row 4: KALIA & Labour Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("KALIA beneficiary? *", theme),
                        _buildToggleList(
                          options: ['Yes', 'No'],
                          selectedValue: _kaliaBeneficiary,
                          onChanged: (val) => setState(() => _kaliaBeneficiary = val),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Parent labour card? *", theme),
                        _buildToggleList(
                          options: ['Yes', 'No'],
                          selectedValue: _labourCard,
                          onChanged: (val) => setState(() => _labourCard = val),
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Row 5: Income & Marks
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDropdownLabel("Yearly family income *", _income, _incomeOptions, (val) => setState(() => _income = val), theme),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         _buildLabel("Total marks in last exam *", theme),
                         TextFormField(
                           controller: _marksController,
                           keyboardType: TextInputType.number,
                           style: TextStyle(color: colorScheme.onSurface),
                           decoration: _getInputDecoration(theme).copyWith(
                             suffixIcon: Padding(
                               padding: const EdgeInsets.all(12.0),
                               child: Text("%", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 16)),
                             ),
                           ),
                           validator: (v) {
                             if (v == null || v.isEmpty) return "Required";
                             if (double.tryParse(v) == null) return "Enter a valid number";
                             final val = double.parse(v);
                             if (val < 0 || val > 100) return "Must be 0-100";
                             return null;
                           },
                         ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    shadowColor: colorScheme.primary.withOpacity(0.5)
                  ),
                  child: _isChecking
                    ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: theme.scaffoldBackgroundColor, strokeWidth: 3))
                    : const Text("Check Eligibility", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 40),

              // Results render
              if (_showResults && _resultData != null)
                _buildResultsPanel(theme).animate().fadeIn().slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _getInputDecoration(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? theme.dividerColor : Colors.grey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      errorStyle: TextStyle(color: theme.colorScheme.error),
    );
  }

  Widget _buildDropdownLabel(String label, String? selectedVal, List<String> items, ValueChanged<String?> onChanged, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, theme),
        DropdownButtonFormField<String>(
          value: selectedVal,
          dropdownColor: theme.cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface),
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
          decoration: _getInputDecoration(theme),
          hint: Text("Select", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
               value: value,
               child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToggleList({required List<String> options, required String selectedValue, required ValueChanged<String> onChanged, required ThemeData theme}) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? theme.dividerColor : Colors.grey.withOpacity(0.4);
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(30),
        color: theme.cardColor,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsPanel(ThemeData theme) {
    int score = _resultData!['score'] ?? 0;
    int probability = _resultData!['probability'] ?? 0;
    String risk = _resultData!['risk'] ?? '';
    List<dynamic> explanations = _resultData!['explanations'] ?? [];

    Color riskColor = risk == 'Low' ? Colors.green : (risk == 'Medium' ? Colors.orange : Colors.red);
    Color probColor = probability >= 80 ? Colors.green : (probability >= 50 ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Eligibility Result", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 120, width: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[300],
                  color: theme.colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$score", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.primary, height: 1)),
                  Text("/ 100", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text("Probability", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                  Text("$probability%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: probColor)),
                ],
              ),
              Column(
                children: [
                  Text("Risk", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: riskColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                    child: Text(risk, style: TextStyle(fontWeight: FontWeight.bold, color: riskColor)),
                  )
                ],
              ),
            ],
          ),
          if (explanations.isNotEmpty) ...[
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("AI Insights", style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 10),
            ...explanations.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("• ", style: TextStyle(color: theme.colorScheme.primary)),
                  Expanded(child: Text(e, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8), fontSize: 13))),
                ],
              ),
            )).toList()
          ]
        ],
      )
    );
  }
}
