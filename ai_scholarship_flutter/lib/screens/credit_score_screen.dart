import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class CreditScoreScreen extends StatelessWidget {
  final int score; // 300 to 900

  const CreditScoreScreen({super.key, this.score = 780});

  String get riskLevel {
    if (score >= 750) return "Low Risk";
    if (score >= 600) return "Medium Risk";
    return "High Risk";
  }

  Color get riskColor {
    if (score >= 750) return const Color(0xFF22D3EE);
    if (score >= 600) return const Color(0xFF7C3AED);
    return const Color(0xFFF43F5E);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'AI Credit Score',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🔥 GAUGE SECTION
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(250, 150),
                    painter: _GaugePainter(
                      score: score,
                      color: riskColor,
                    ),
                  ),

                  Positioned(
                    bottom: 10,
                    child: Column(
                      children: [
                        Text(
                          score.toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            riskLevel,
                            style: TextStyle(
                              color: riskColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("300",
                    style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold)),
                SizedBox(width: 180),
                Text("900",
                    style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 50),

            // 🔥 DETAILS SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151E3D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Credit Factors",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildFactorRow(
                      "Payment History", "100%", Color(0xFF34D399)),
                  _buildFactorRow(
                      "Credit Utilization", "12%", Color(0xFF34D399)),
                  _buildFactorRow(
                      "Credit Age", "2 Yrs", Color(0xFFFBBF24)),
                  _buildFactorRow(
                      "Recent Inquiries", "4", Color(0xFFEF4444)),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(String title, String value, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// 🎯 GAUGE PAINTER
class _GaugePainter extends CustomPainter {
  final int score;
  final Color color;

  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double progress = ((score - 300) / 600).clamp(0.0, 1.0);
    double sweepAngle = progress * pi;

    Offset center = Offset(size.width / 2, size.height);
    double radius = size.width / 2;

    Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [const Color(0xFF1E3A8A), color],
        stops: [0.0, progress == 0 ? 0.01 : progress],
        startAngle: pi,
        endAngle: 2 * pi,
        transform: GradientRotation(pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}