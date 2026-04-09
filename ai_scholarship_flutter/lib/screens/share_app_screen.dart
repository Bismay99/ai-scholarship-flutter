import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Share App', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Share illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, color: Colors.white, size: 56),
            ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 30),
            const Text(
              "Spread the Word!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 10),
            Text(
              "Help fellow students discover AI-powered scholarships and loans. Share the app with your friends!",
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 15, height: 1.5),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 40),

            // Share options
            _buildShareOption(context, Icons.message, "WhatsApp", const Color(0xFF25D366)),
            _buildShareOption(context, Icons.telegram, "Telegram", const Color(0xFF0088CC)),
            _buildShareOption(context, Icons.email_outlined, "Email", const Color(0xFFEA4335)),
            _buildShareOption(context, Icons.copy, "Copy Link", colorScheme.primary),
            _buildShareOption(context, Icons.more_horiz, "More Options", Colors.grey),

            const SizedBox(height: 40),

            // Referral code card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text("Your Referral Code", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "EDUAI-2026",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3, color: colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Share this code and earn rewards when friends sign up!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
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

  Widget _buildShareOption(BuildContext context, IconData icon, String label, Color color) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: () {
          if (label == "Copy Link") {
            Clipboard.setData(const ClipboardData(text: "https://edufinance.ai/app?ref=EDUAI-2026"));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Link copied to clipboard! 📋")),
            );
          } else {
            Share.share(
              "Check out EduFinance AI! The smartest way to find student loans & scholarships. Use my referral code: EDUAI-2026\n\nhttps://edufinance.ai/app",
              subject: "EduFinance AI App",
            );
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3)),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.03, end: 0);
  }
}
