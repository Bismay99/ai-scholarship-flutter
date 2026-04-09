import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        // Pop back — the auth wrapper in main.dart will automatically redirect to dashboard
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Account created successfully! 🎉"),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Signup failed"),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Header
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 34),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 25),

              Center(
                child: Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -0.5)),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 6),

              Center(
                child: Text("Join AI Finance to unlock smart insights", style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 35),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Full Name
                    _buildField(
                      controller: _nameController,
                      label: "Full Name",
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                      delay: 300,
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _buildField(
                      controller: _emailController,
                      label: "Email Address",
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Email is required";
                        if (!v.contains('@')) return "Enter a valid email";
                        return null;
                      },
                      delay: 400,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                      decoration: _inputDecoration(
                        label: "Password",
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Password is required";
                        if (v.length < 6) return "Minimum 6 characters";
                        return null;
                      },
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 16),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
                      decoration: _inputDecoration(
                        label: "Confirm Password",
                        icon: Icons.lock_person_outlined,
                        suffix: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: colorScheme.onSurface.withOpacity(0.5)),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Please confirm your password";
                        if (v != _passwordController.text) return "Passwords do not match";
                        return null;
                      },
                    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1, end: 0),

                    const SizedBox(height: 30),

                    // Create Account Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              foregroundColor: colorScheme.onSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: colorScheme.secondary.withOpacity(0.4),
                            ),
                            child: auth.isLoading
                                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: colorScheme.onSecondary, strokeWidth: 2.5))
                                : const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 700.ms).scale(begin: const Offset(0.95, 0.95)),

                    const SizedBox(height: 28),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? ", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 15)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("Sign In", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int delay = 0,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
      decoration: _inputDecoration(label: label, icon: icon),
      validator: validator,
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.1, end: 0);
  }

  InputDecoration _inputDecoration({required String label, required IconData icon, Widget? suffix}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: colorScheme.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: theme.cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: theme.dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: colorScheme.error)),
    );
  }
}
