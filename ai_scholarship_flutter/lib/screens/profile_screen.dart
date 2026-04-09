import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'edit_personal_details_screen.dart';
import 'linked_accounts_screen.dart';
import 'applications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final displayName = auth.userName.isNotEmpty ? auth.userName : "User";
        final displayEmail = auth.userEmail.isNotEmpty ? auth.userEmail : "user@example.com";
        final initials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                       Container(
                         width: 100,
                         height: 100,
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           gradient: LinearGradient(colors: [colorScheme.secondary, colorScheme.primary]),
                           border: Border.all(color: theme.dividerColor, width: 3),
                         ),
                         child: Center(
                           child: Text(initials, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                         ),
                       ),
                       const SizedBox(height: 15),
                       Text(displayName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                       const SizedBox(height: 5),
                       Text(displayEmail, style: TextStyle(fontSize: 14, color: colorScheme.onSurface.withOpacity(0.6))),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),
            const SizedBox(height: 40),

            _buildSectionHeader("Personal Information", colorScheme),
            _buildSettingsTile(
              context: context, 
              icon: Icons.person_outline, 
              title: "Edit Personal Details", 
              subtitle: "Name, Contact, DOB",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EditPersonalDetailsScreen()));
              }
            ),
            _buildSettingsTile(
              context: context, 
              icon: Icons.account_balance_outlined, 
              title: "Financial Linked Accounts", 
              subtitle: "SBI ending in 4432",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LinkedAccountsScreen()));
              }
            ),

            const SizedBox(height: 25),
            _buildSectionHeader("Activity", colorScheme),
            _buildSettingsTile(
              context: context,
              icon: Icons.assignment_outlined,
              title: "My Applications",
              subtitle: "Submitted loan & scholarship applications",
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ApplicationsScreen()));
              }
            ),
            
            const SizedBox(height: 40),
            Center(
              child: TextButton.icon(
                onPressed: () => auth.signOut(),
                icon: Icon(Icons.logout, color: colorScheme.error),
                label: Text("Secure Logout", style: TextStyle(color: colorScheme.error, fontSize: 16)),
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 50),
          ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        ),
      ),
    );
      },
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsTile({required BuildContext context, required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
        boxShadow: theme.brightness == Brightness.light 
          ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))] 
          : [],
      ),
      child: ListTile(
        onTap: onTap ?? () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF1E293B) : theme.colorScheme.primary.withOpacity(0.1), 
            borderRadius: BorderRadius.circular(10)
          ),
          child: Icon(icon, color: theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.primary, size: 22),
        ),
        title: Text(title, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13)) : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onSurface.withOpacity(0.3), size: 16),
      ),
    );
  }
}
