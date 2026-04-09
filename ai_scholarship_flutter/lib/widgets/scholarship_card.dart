import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/document_provider.dart';
import '../screens/application_form_screen.dart';

class ScholarshipCard extends StatelessWidget {
  final String title;
  final String amount;
  final int matchPercentage;
  final String deadline;
  final String eligibility;
  final String? aiTag;

  const ScholarshipCard({
    super.key,
    required this.title,
    required this.amount,
    required this.matchPercentage,
    required this.deadline,
    required this.eligibility,
    this.aiTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final docProvider = Provider.of<DocumentProvider>(context);
    final isVerified = docProvider.isFullyVerified;

    return Container(
      margin: const EdgeInsets.only(right: 15, bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        gradient: isDark ? const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: isDark ? [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "🧠 ${aiTag ?? '$matchPercentage% Match'}",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.bookmark_border, color: colorScheme.onSurface.withOpacity(0.4), size: 20),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "🎓 $title",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            "💵 $amount",
            style: TextStyle(
              color: colorScheme.secondary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 Deadline", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(deadline, style: TextStyle(color: colorScheme.error, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text("📊 Eligibility", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                     const SizedBox(height: 2),
                     Text(eligibility, style: const TextStyle(color: Color(0xFF34D399), fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [colorScheme.secondary, colorScheme.primary],
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.secondary.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ApplicationFormScreen(applicationTitle: title),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "🔘 Apply Now",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          )
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
