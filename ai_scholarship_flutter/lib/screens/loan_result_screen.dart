import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoanResultScreen extends StatelessWidget {
  final bool isApproved;
  final int confidenceScore;
  
  const LoanResultScreen({
    super.key, 
    this.isApproved = true, 
    this.confidenceScore = 88
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis Result', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status Icon & Title
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isApproved ? const Color(0xFF22D3EE).withOpacity(0.15) : const Color(0xFFF43F5E).withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isApproved ? const Color(0xFF22D3EE).withOpacity(0.4) : const Color(0xFFF43F5E).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: Icon(
                isApproved ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 80,
                color: isApproved ? const Color(0xFF22D3EE) : const Color(0xFFF43F5E),
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text(
              isApproved ? "Approved" : "Rejected",
              style: TextStyle(
                fontSize: 36,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w900,
                color: isApproved ? const Color(0xFF22D3EE) : const Color(0xFFF43F5E),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              "Based on AI-driven financial analysis",
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7)),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 40),

            // Confidence Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                children: [
                  const Text("AI Confidence Score", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Stack(
                     alignment: Alignment.center,
                     children: [
                       SizedBox(
                         width: 140,
                         height: 140,
                         child: CircularProgressIndicator(
                           value: confidenceScore / 100,
                           strokeWidth: 14,
                           backgroundColor: const Color(0xFF1E293B),
                           valueColor: AlwaysStoppedAnimation<Color>(
                             isApproved ? const Color(0xFF7C3AED) : const Color(0xFFF43F5E)
                           ),
                         ),
                       ),
                       Text(
                         "$confidenceScore%",
                         style: const TextStyle(
                           fontSize: 34,
                           fontWeight: FontWeight.w900,
                           color: Colors.white,
                         ),
                       ),
                     ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),

            // Explanation Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Why this decision?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                _buildExplanationItem(
                  icon: Icons.check, 
                  color: const Color(0xFF22D3EE), 
                  text: "High academic score (GPA 3.8)"
                ),
                _buildExplanationItem(
                  icon: Icons.check, 
                  color: const Color(0xFF22D3EE), 
                  text: "Stable family income verified"
                ),
                _buildExplanationItem(
                  icon: Icons.check, 
                  color: const Color(0xFF22D3EE), 
                  text: "Excellent repayment history"
                ),
                if (!isApproved)
                  _buildExplanationItem(
                    icon: Icons.close, 
                    color: const Color(0xFFF43F5E), 
                    text: "Requested amount exceeds safe threshold"
                  ),
              ],
            ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationItem({required IconData icon, required Color color, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
