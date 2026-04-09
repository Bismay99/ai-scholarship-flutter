import 'package:flutter/material.dart';

class AIMeshBackground extends StatefulWidget {
  const AIMeshBackground({super.key});

  @override
  State<AIMeshBackground> createState() => _AIMeshBackgroundState();
}

class _AIMeshBackgroundState extends State<AIMeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base background
            Container(color: theme.scaffoldBackgroundColor),
            
            // Orb 1
            Positioned(
              top: -100 + (_controller.value * 50),
              right: -50 + (_controller.value * 30),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Orb 2
            Positioned(
              bottom: -80 + (_controller.value * 40),
              left: -60 + (_controller.value * 20),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.secondary.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Orb 3 (Center)
            Positioned(
              top: 200 + (_controller.value * 100),
              left: 50 + (_controller.value * 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.tertiary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
