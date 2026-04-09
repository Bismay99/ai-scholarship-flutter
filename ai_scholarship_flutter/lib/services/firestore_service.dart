import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore service that connects to the SAME database collections
/// used by the Web App (EduFinance AI).
/// 
/// Web App Collections:
///   - loanApplications/{userId}
///   - scholarshipApplications/{userId}
///
/// Any update from Web will appear here in real-time and vice versa.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Loan Applications ───

  /// Real-time stream of the user's loan application document.
  /// This syncs with the web app's Dashboard.jsx onSnapshot listener.
  Stream<Map<String, dynamic>?> streamLoanApplication(String userId) {
    return _db
        .collection('loanApplications')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  /// Get loan application once (non-realtime).
  Future<Map<String, dynamic>?> getLoanApplication(String userId) async {
    final snap = await _db.collection('loanApplications').doc(userId).get();
    return snap.exists ? snap.data() : null;
  }

  /// Save/update loan application (merges with existing data).
  /// This is the same as web's setDoc with { merge: true }.
  Future<void> saveLoanApplication(String userId, Map<String, dynamic> data) async {
    await _db.collection('loanApplications').doc(userId).set(data, SetOptions(merge: true));
  }

  // ─── Scholarship Applications ───

  /// Real-time stream of the user's scholarship application document.
  Stream<Map<String, dynamic>?> streamScholarshipApplication(String userId) {
    return _db
        .collection('scholarshipApplications')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  /// Get scholarship application once (non-realtime).
  Future<Map<String, dynamic>?> getScholarshipApplication(String userId) async {
    final snap = await _db.collection('scholarshipApplications').doc(userId).get();
    return snap.exists ? snap.data() : null;
  }

  /// Save/update scholarship application (merges with existing data).
  Future<void> saveScholarshipApplication(String userId, Map<String, dynamic> data) async {
    await _db.collection('scholarshipApplications').doc(userId).set(data, SetOptions(merge: true));
  }

  // ─── Generic helpers ───

  /// Delete a loan application document.
  Future<void> deleteLoanApplication(String userId) async {
    await _db.collection('loanApplications').doc(userId).delete();
  }

  /// Delete a scholarship application document.
  Future<void> deleteScholarshipApplication(String userId) async {
    await _db.collection('scholarshipApplications').doc(userId).delete();
  }

  // ─── User Profile ───

  /// Real-time stream of the user profile document.
  Stream<Map<String, dynamic>?> streamUserProfile(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  /// Get user profile once.
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    return snap.exists ? snap.data() : null;
  }

  /// Save/update user profile.
  Future<void> saveUserProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
