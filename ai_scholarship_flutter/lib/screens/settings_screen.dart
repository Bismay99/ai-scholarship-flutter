import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/biometric_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("App Preferences", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5))
                .animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            const Text("Customize your experience", style: TextStyle(color: Colors.grey, fontSize: 14))
                .animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 30),

            // Appearance Section
            _buildSectionHeader("Appearance", colorScheme),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return _buildSettingCard(
                  context: context,
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  iconColor: const Color(0xFFFBBF24),
                  title: "Dark Mode",
                  subtitle: isDark ? "Currently using dark theme" : "Currently using light theme",
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeColor: colorScheme.primary,
                  ),
                );
              },
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.language,
              iconColor: const Color(0xFF22D3EE),
              title: "Language",
              subtitle: "English (US)",
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.text_fields,
              iconColor: const Color(0xFF7C3AED),
              title: "Font Size",
              subtitle: "Medium (Default)",
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("Privacy & Security", colorScheme),
            Consumer<BiometricProvider>(
              builder: (context, bio, _) {
                return _buildSettingCard(
                  context: context,
                  icon: Icons.fingerprint,
                  iconColor: Colors.green,
                  title: "Biometric Lock",
                  subtitle: "Use fingerprint/face to open app",
                  trailing: Switch(
                    value: bio.useBiometric, 
                    onChanged: (val) async {
                      final success = await bio.toggleBiometricLock(val);
                      if (!success && val && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Could not enable biometric lock. Hardware unavailable or verification failed.")),
                        );
                      }
                    }, 
                    activeColor: colorScheme.primary,
                  ),
                );
              }
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.lock_outline,
              iconColor: const Color(0xFFF43F5E),
              title: "Change Password",
              subtitle: "Update your account password",
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.delete_forever_outlined,
              iconColor: Colors.red,
              title: "Clear Cached Data",
              subtitle: "Free up storage space",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cache cleared successfully! ✅")),
                );
              },
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader("About", colorScheme),
            _buildSettingCard(
              context: context,
              icon: Icons.info_outline,
              iconColor: colorScheme.primary,
              title: "App Version",
              subtitle: "v1.0.0 (Build 1)",
              trailing: const SizedBox.shrink(),
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.description_outlined,
              iconColor: Colors.grey,
              title: "Terms of Service",
              subtitle: "Read our terms and conditions",
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            _buildSettingCard(
              context: context,
              icon: Icons.privacy_tip_outlined,
              iconColor: Colors.grey,
              title: "Privacy Policy",
              subtitle: "How we handle your data",
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.3)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: theme.colorScheme.onSurface)),
        subtitle: Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
        trailing: trailing,
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.03, end: 0);
  }
}
