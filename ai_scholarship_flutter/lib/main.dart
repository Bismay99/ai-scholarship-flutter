import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/api_config.dart';
import 'providers/chatbot_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/document_provider.dart';
import 'providers/biometric_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/app_lock_screen.dart';
import 'widgets/global_chatbot_overlay.dart';
import 'services/vapi_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await ApiConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => BiometricProvider()),
        ChangeNotifierProvider(create: (_) => VoiceAssistantService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Finance Assistant',
          theme: themeProvider.currentTheme,
          home: SplashScreen(nextScreen: const AuthWrapper()),
        );
      },
    );
  }
}

/// Watches AuthProvider state and routes accordingly
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BiometricProvider>(
      builder: (context, auth, bio, _) {
        if (auth.isLoggedIn) {
          // Preload documents so the rest of the app immediately knows the verification status
          Future.microtask(() => Provider.of<DocumentProvider>(context, listen: false).loadForUser(auth.userId));

          if (bio.useBiometric && !bio.isUnlocked) {
            return const AppLockScreen();
          }
          return const GlobalChatbotOverlay(
            child: MainNavigationScreen(),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
