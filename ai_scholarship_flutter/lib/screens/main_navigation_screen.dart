import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dashboard_screen.dart';
import 'scholarships_screen.dart';
import 'loans_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ScholarshipsScreen(),
    const LoansScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Ensure the background takes the theme color
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: theme.colorScheme.primary.withOpacity(0.15),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold);
              }
              return TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12);
            }),
          ),
          child: NavigationBar(
            height: 70,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                selectedIcon: Icon(Icons.dashboard_rounded, color: theme.colorScheme.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.school_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                selectedIcon: Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                label: 'Scholarships',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_outlined, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                selectedIcon: Icon(Icons.account_balance_rounded, color: theme.colorScheme.primary),
                label: 'Loans',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                selectedIcon: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutExpo),
    );
  }
}
