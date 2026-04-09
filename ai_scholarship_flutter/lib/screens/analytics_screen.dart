import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analytics & Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Eligibility Trajectory",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 10),
            const Text(
              "Track your loan approvals and scholarship match progression over time.",
              style: TextStyle(fontSize: 15, color: Colors.white54, height: 1.5),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 30),

            // Mock Graph Area
            Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_rounded, size: 80, color: const Color(0xFF22D3EE).withOpacity(0.4)),
                  const SizedBox(height: 15),
                  const Text("+15% Growth in Scholarship Matches", style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  const Text("Based on your recent GPA upload", style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 40),

            // AI Suggestions
            const Text(
              "AI Recommendations",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 15),
            
            Column(
              children: [
                _buildSuggestionCard(
                  icon: Icons.upload_file,
                  color: const Color(0xFF7C3AED),
                  title: "Missing Tax Documentation",
                  subtitle: "Uploading your 2023 tax return will boost your federal loan confidence score by 12%.",
                ),
                _buildSuggestionCard(
                  icon: Icons.school,
                  color: const Color(0xFF22D3EE),
                  title: "Extracurriculars Detected",
                  subtitle: "Our NLP scanned your resume. Apply for the 'Leadership Bursary' to maximize your 89% match rate.",
                ),
                _buildSuggestionCard(
                  icon: Icons.credit_score,
                  color: const Color(0xFFF43F5E),
                  title: "High Credit Utilization",
                  subtitle: "Paying down \$150 on your linked credit card will shift your risk tier to 'Low Risk'.",
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
