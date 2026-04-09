import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  int _selectedStars = 0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rate Us', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildThankYou(colorScheme) : _buildRatingForm(theme, colorScheme),
      ),
    );
  }

  Widget _buildRatingForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 30),

        // Star icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFFBBF24), colorScheme.primary]),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 50),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),

        const SizedBox(height: 24),
        const Text(
          "How's your experience?",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          "Your feedback helps us improve EduFinance AI",
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
        ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 40),

        // Star rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return GestureDetector(
              onTap: () => setState(() => _selectedStars = starIndex),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  starIndex <= _selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: starIndex <= _selectedStars ? const Color(0xFFFBBF24) : colorScheme.onSurface.withOpacity(0.3),
                  size: 48,
                ),
              ),
            );
          }),
        ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),

        const SizedBox(height: 12),
        Text(
          _getStarLabel(),
          style: TextStyle(
            color: _selectedStars > 0 ? const Color(0xFFFBBF24) : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 36),

        // Feedback text field
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: TextField(
            controller: _feedbackController,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Tell us what you think... (optional)",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 36),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedStars > 0
                ? () {
                    setState(() => _submitted = true);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("SUBMIT REVIEW", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildThankYou(ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.5, 0.5)),

        const SizedBox(height: 30),
        const Text("Thank You! 🎉", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900))
            .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          "Your $_selectedStars-star review has been submitted.\nWe appreciate your feedback!",
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 15, height: 1.5),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 40),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text("Back to Dashboard", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  String _getStarLabel() {
    switch (_selectedStars) {
      case 1: return "Poor 😞";
      case 2: return "Fair 😐";
      case 3: return "Good 🙂";
      case 4: return "Great 😄";
      case 5: return "Excellent! 🤩";
      default: return "Tap to rate";
    }
  }
}
