import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StatusTimeline extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const StatusTimeline({super.key, required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? null : theme.cardColor,
        gradient: isDark ? const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Application Tracker",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(steps.length, (index) {
              bool isCompleted = index <= currentStep;
              bool isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted ? theme.colorScheme.primary : (isDark ? const Color(0xFF1E293B) : theme.scaffoldBackgroundColor),
                          shape: BoxShape.circle,
                          border: isCompleted ? null : Border.all(color: theme.dividerColor),
                          boxShadow: isCompleted ? [
                            BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 10)
                          ] : null,
                        ),
                        child: isCompleted
                            ? Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary)
                            : const SizedBox(),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: isCompleted ? theme.colorScheme.primary : theme.dividerColor,
                        ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 15,
                          color: isCompleted ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          )
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
