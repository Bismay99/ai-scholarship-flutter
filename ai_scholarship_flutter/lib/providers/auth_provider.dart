import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _errorMessage;
  
  final FirestoreService _firestoreService = FirestoreService();
  String _userContact = "";
  String _userDOB = "";

  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userContact => _userContact;
  String get userDOB => _userDOB;

  String get userName {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email?.split('@').first ?? "";
  }

  String get userEmail => _auth.currentUser?.email ?? "";
  String get userId => _auth.currentUser?.uid ?? "";

  User? get currentUser => _auth.currentUser;
  User? get user => _auth.currentUser; // Added for compatibility with any code expecting getter 'user'

  AuthProvider() {
    // Listen to auth state changes for real-time updates
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _fetchUserProfile();
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final profile = await _firestoreService.getUserProfile(user.uid);
      if (profile != null) {
        _userContact = profile['contact'] ?? "";
        _userDOB = profile['dob'] ?? "";
        notifyListeners();
      }
    }
  }

  Future<bool> updateUserProfile({required String name, required String contact, required String dob}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Update Auth Display Name
        await user.updateDisplayName(name.trim());
        await user.reload();

        // 2. Update Firestore
        await _firestoreService.saveUserProfile(user.uid, {
          'name': name.trim(),
          'contact': contact.trim(),
          'dob': dob.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _userContact = contact.trim();
        _userDOB = dob.trim();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Failed to update profile: $e";
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email and password (Firebase Auth)
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = "No account found with this email.";
          break;
        case 'wrong-password':
          _errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          _errorMessage = "Please enter a valid email address.";
          break;
        case 'user-disabled':
          _errorMessage = "This account has been disabled.";
          break;
        case 'invalid-credential':
          _errorMessage = "Invalid email or password. Please try again.";
          break;
        default:
          _errorMessage = e.message ?? "Login failed. Please try again.";
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Something went wrong. Please try again.";
      notifyListeners();
      return false;
    }
  }

  /// Sign up with name, email and password (Firebase Auth)
  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Set the display name
      await result.user?.updateDisplayName(name.trim());
      await result.user?.reload();

      // Save user profile
      await _firestoreService.saveUserProfile(result.user!.uid, {
        'name': name.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      switch (e.code) {
        case 'email-already-in-use':
          _errorMessage = "This email is already registered. Try logging in.";
          break;
        case 'weak-password':
          _errorMessage = "Password is too weak. Use at least 6 characters.";
          break;
        case 'invalid-email':
          _errorMessage = "Please enter a valid email address.";
          break;
        default:
          _errorMessage = e.message ?? "Signup failed. Please try again.";
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Something went wrong. Please try again.";
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message ?? "Failed to send reset email.";
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "Something went wrong. Please try again.";
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
