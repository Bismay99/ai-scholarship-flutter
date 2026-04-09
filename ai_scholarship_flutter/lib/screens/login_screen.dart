import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? "Login failed"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleForgotPassword() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resetEmailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(25, 30, 25, MediaQuery.of(ctx).viewInsets.bottom + 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text("Reset Password", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text("Enter your email and we'll send you a reset link.", style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
            const SizedBox(height: 25),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Email Address",
                labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(ctx, listen: false);
                  final ok = await authProvider.resetPassword(resetEmailController.text.trim());
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(ok ? "Password reset link sent! Check your email." : (authProvider.errorMessage ?? "Failed")),
                        backgroundColor: ok ? const Color(0xFF10B981) : colorScheme.error,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text("Send Reset Link", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated gradient orbs background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -80 + (_bgController.value * 30),
                    right: -60 + (_bgController.value * 20),
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [colorScheme.secondary.withOpacity(0.25), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100 + (_bgController.value * 40),
                    left: -80 + (_bgController.value * 15),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [colorScheme.primary.withOpacity(0.15), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.secondary, colorScheme.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: colorScheme.secondary.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
                          BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 15)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 40)),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.6, 0.6), curve: Curves.elasticOut),

                  const SizedBox(height: 28),

                  Center(
                    child: Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -1)),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 6),

                  Center(
                    child: Text("Sign in to your EduFinance AI account", style: TextStyle(fontSize: 15, color: colorScheme.onSurface.withOpacity(0.5))),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 40),

                  // Glassmorphism Form Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: "Email Address",
                                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                                  prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Email is required";
                                  if (!v.contains('@')) return "Enter a valid email";
                                  return null;
                                },
                              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05, end: 0),

                              const SizedBox(height: 18),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                                  prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colorScheme.onSurface.withOpacity(0.4)),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Password is required";
                                  if (v.length < 6) return "Minimum 6 characters";
                                  return null;
                                },
                              ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05, end: 0),

                              const SizedBox(height: 10),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _handleForgotPassword,
                                  child: Text("Forgot Password?", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                              ).animate().fadeIn(delay: 550.ms),

                              const SizedBox(height: 16),

                              // Login Button
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: auth.isLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.primary,
                                        foregroundColor: colorScheme.onPrimary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      child: auth.isLoading
                                          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2.5))
                                          : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                    ),
                                  );
                                },
                              ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.97, 0.97)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05, end: 0),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: Text("Register", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 750.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
