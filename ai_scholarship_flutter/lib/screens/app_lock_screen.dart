import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/biometric_provider.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // Auto prompt on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBiometric();
    });
  }

  Future<void> _promptBiometric() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);
    
    final bio = Provider.of<BiometricProvider>(context, listen: false);
    final success = await bio.authenticate("Unlock EduFinance AI");
    
    if (success && mounted) {
      bio.setUnlocked(true);
    }
    
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.secondary.withOpacity(0.8), colorScheme.primary.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                ],
              ),
              child: const Icon(Icons.fingerprint, size: 50, color: Colors.white),
            ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 30),
            
            Text(
              "App Locked",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 8),
            
            Text(
              "Verify your identity to continue",
              style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6)),
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 50),
            
            if (_isChecking)
              CircularProgressIndicator(color: colorScheme.primary)
            else
              ElevatedButton.icon(
                onPressed: _promptBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text("Unlock Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
