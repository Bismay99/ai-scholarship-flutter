import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'voice_call_screen.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // ... existing faqs ...

    final List<Map<String, String>> faqs = [
      {
        "q": "How does AI verify my documents?",
        "a": "Our system uses OCR (Optical Character Recognition) to scan your uploaded documents, extract key information like Aadhaar numbers and names, and validate them against expected patterns to ensure they are authentic."
      },
      {
        "q": "What documents are required for scholarships?",
        "a": "Most scholarships require: Aadhaar Card (ID proof), Income Certificate (family income proof), Marksheet (academic record). Some may also ask for a Bank Passbook."
      },
      {
        "q": "How is my eligibility score calculated?",
        "a": "Your eligibility score is computed by AI using your academic marks, family income, document verification status, and profile completeness. A higher score means better chances of approval."
      },
      {
        "q": "Is my data safe and private?",
        "a": "Absolutely. All data is stored securely in Firebase with end-to-end encryption. Your documents are only used for verification and are never shared with third parties."
      },
      {
        "q": "What happens after I apply for a loan?",
        "a": "Once you submit a loan application, it goes through AI Verification → Eligibility Check → Credit Score Assessment → Final Approval. You can track each step in real-time via the Applications Tracker."
      },
      {
        "q": "Can I edit my application after submitting?",
        "a": "Once submitted, applications are locked for processing. However, you can update your personal details and upload new documents for future applications."
      },
      {
        "q": "How do I contact support?",
        "a": "You can reach us via the AI Chatbot for instant help, or email us at support@edufinanceai.com for detailed inquiries."
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Frequently Asked Questions", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5))
                .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            const Text("Find answers to common questions about loans, scholarships, and the app.", style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4))
                .animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),

            // Search hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.4)),
                  const SizedBox(width: 12),
                  Text("Search questions...", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 15)),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // FAQ Items
            ...faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return _buildFaqItem(context, faq["q"]!, faq["a"]!, index);
            }),

            const SizedBox(height: 30),

            // Contact Support Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary.withOpacity(0.12), colorScheme.secondary.withOpacity(0.08)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.headset_mic_outlined, color: colorScheme.primary, size: 40),
                  const SizedBox(height: 12),
                  const Text("Still need help?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text("Our AI assistant is available 24/7", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Chat Option
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.forum_outlined, size: 16),
                          label: const Text("Chat AI"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Voice Call Option
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VoiceCallScreen()),
                            );
                          },
                          icon: const Icon(Icons.call, size: 16),
                          label: const Text("Call AI"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              "Q${index + 1}",
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        children: [
          Text(answer, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 13, height: 1.5)),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 250 + (index * 50))).slideX(begin: 0.03, end: 0);
  }
}
