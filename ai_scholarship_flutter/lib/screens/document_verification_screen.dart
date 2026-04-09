import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/document_provider.dart';
import '../providers/auth_provider.dart';
import 'document_vault_screen.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    if (userId.isNotEmpty) {
      await Provider.of<DocumentProvider>(context, listen: false).loadForUser(userId);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final success = await Provider.of<DocumentProvider>(context, listen: false).saveToFirestore();
    setState(() => _isSaving = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Documents and details saved successfully! ✅"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save. Please try again."), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final docProvider = Provider.of<DocumentProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Verify Identity & Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusHeader(docProvider, colorScheme),
                  const SizedBox(height: 30),

                  // Sections
                  ...docProvider.sections.entries.map((entry) {
                    final sectionName = entry.key;
                    final fields = entry.value;
                    return _buildSectionCard(
                      context: context,
                      colorScheme: colorScheme,
                      title: sectionName,
                      fields: fields,
                      docProvider: docProvider,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 20),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("SAVE DETAILS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ─── Status Header ───
  Widget _buildStatusHeader(DocumentProvider provider, ColorScheme colorScheme) {
    final status = provider.verificationStatusText;
    final isComplete = provider.isFullyVerified;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  value: provider.verificationProgress,
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  color: isComplete ? Colors.green : colorScheme.primary,
                  strokeWidth: 5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              if (isComplete)
                const Icon(Icons.check, color: Colors.green, size: 20)
              else
                Text(
                  "${(provider.verificationProgress * 100).toInt()}%",
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
            ],
          ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isComplete ? "All data provided" : "Partially Complete",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DocumentVaultScreen()),
                      );
                    },
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text("Vault", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
}

  // ─── Section Card Wrapper ───
  Widget _buildSectionCard({
    required BuildContext context,
    required ColorScheme colorScheme,
    required String title,
    required List<VerificationField> fields,
    required DocumentProvider docProvider,
  }) {
    final theme = Theme.of(context);
    
    // Determine icon based on section
    IconData sectionIcon;
    switch (title) {
      case 'Personal': sectionIcon = Icons.person_outline; break;
      case 'Academic': sectionIcon = Icons.school_outlined; break;
      case 'Family': sectionIcon = Icons.family_restroom_outlined; break;
      case 'Bank': sectionIcon = Icons.account_balance_outlined; break;
      default: sectionIcon = Icons.folder_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(sectionIcon, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor, height: 1),

          // Content Fields
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: fields.map((field) => _buildFieldRow(context, field, docProvider, colorScheme)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(BuildContext context, VerificationField field, DocumentProvider provider, ColorScheme colorScheme) {
    if (field.type == FieldType.text || field.type == FieldType.number) {
      bool isDob = field.id == 'dob';
      final controller = _controllers.putIfAbsent(field.id, () => TextEditingController(text: field.value));
      
      // Keep controller in sync with provider (for auto-fills/OCR)
      if (field.value != null && controller.text != field.value) {
        // We only update if the controller is not the primary focus or text is different
        // to avoid jumping cursor during manual typing
        Future.microtask(() {
          if (controller.text != field.value) {
            controller.text = field.value!;
          }
        });
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          key: Key(field.id),
          controller: controller,
          readOnly: isDob,
          onTap: isDob ? () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              final dateStr = "${picked.day}/${picked.month}/${picked.year}";
              controller.text = dateStr;
              provider.updateTextField(field.id, dateStr);
            }
          } : null,
          keyboardType: field.type == FieldType.number ? TextInputType.number : TextInputType.text,
          onChanged: (val) => provider.updateTextField(field.id, val),
          decoration: InputDecoration(
            labelText: field.title + (field.isMandatory ? ' *' : ' (Optional)'),
            hintText: isDob ? "Tap to select date" : "Enter ${field.title.toLowerCase()}",
            prefixIcon: isDob ? const Icon(Icons.calendar_today, size: 18) : null,
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            suffixIcon: field.status == FieldStatus.completed ? const Icon(Icons.check_circle, color: Colors.green) : null,
          ),
        ),
      );
    } else {
      // File upload field
      final isCompleted = field.status == FieldStatus.completed;
      final isProcessing = field.status == FieldStatus.processing;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.3) : Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(isCompleted ? Icons.verified : Icons.upload_file, color: isCompleted ? Colors.green : Colors.grey, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(field.title + (field.isMandatory ? ' *' : ''), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  if (field.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              field.errorMessage!, 
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500, height: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (field.status == FieldStatus.completed)
                    const Text("Verified & Extracted", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (isProcessing)
              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            else
              TextButton(
                onPressed: () => provider.pickAndUploadFile(field.id),
                style: TextButton.styleFrom(
                  foregroundColor: isCompleted ? Colors.grey : colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(isCompleted ? "Re-upload" : "Upload"),
              ),
          ],
        ),
      );
    }
  }
}
