import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class BiometricProvider extends ChangeNotifier {
  static const String _prefKey = "useBiometricLock";
  final LocalAuthentication _auth = LocalAuthentication();
  
  bool _useBiometric = false;
  bool get useBiometric => _useBiometric;

  bool _isUnlocked = false;
  bool get isUnlocked => _isUnlocked;

  BiometricProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _useBiometric = prefs.getBool(_prefKey) ?? false;
    notifyListeners();
  }

  // Toggle setting from settings screen
  Future<bool> toggleBiometricLock(bool value) async {
    if (value) {
      // Trying to enable it - verify if device supports it
      final isAvailable = await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
      if (!isAvailable) {
        return false; // Can't enable if no hardware
      }
      
      // Prompt user to verify before enabling
      final authenticated = await authenticate("Verify fingerprint to enable App Lock");
      if (authenticated) {
        _useBiometric = true;
        _isUnlocked = true; // Naturally unlocked if they just enabled it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKey, true);
        notifyListeners();
        return true;
      }
      return false; // Failed to verify
    } else {
      // Disabling
      _useBiometric = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, false);
      notifyListeners();
      return true;
    }
  }

  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true, // Only fingerprint/face, not PIN
        ),
      );
    } catch (e) {
      return false;
    }
  }

  void setUnlocked(bool val) {
    _isUnlocked = val;
    notifyListeners();
  }
}
