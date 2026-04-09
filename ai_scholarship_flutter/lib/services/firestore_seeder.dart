import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Seeds scholarships and loans data to Firestore (run once)
  static Future<void> seedData() async {
    // Check if already seeded
    final scholarshipsSnap = await _db.collection('scholarships').limit(1).get();
    if (scholarshipsSnap.docs.isNotEmpty) return; // Already seeded

    // Seed Scholarships
    final scholarships = [
      {
        'title': 'National Merit Tech Grant',
        'amount': '₹50,000',
        'amountValue': 50000,
        'matchPercentage': 92,
        'deadline': '15 Oct 2026',
        'eligibility': 'B.Tech students',
        'aiTag': 'Highly Eligible',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Global AI Innovators Fund',
        'amount': '₹1,00,000',
        'amountValue': 100000,
        'matchPercentage': 65,
        'deadline': '01 Nov 2026',
        'eligibility': 'CS Majors with AI focus',
        'aiTag': 'Moderate Chance',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'State Engineering Bursary',
        'amount': '₹25,000',
        'amountValue': 25000,
        'matchPercentage': 45,
        'deadline': '10 Dec 2026',
        'eligibility': 'State Residents in Engineering',
        'aiTag': 'Low Match',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var sch in scholarships) {
      await _db.collection('scholarships').add(sch);
    }

    // Seed Loans
    final loans = [
      {
        'title': 'Education Loan - SBI',
        'maxAmount': '₹10 Lakhs',
        'maxAmountValue': 1000000,
        'interestRate': '8.5%',
        'interestRateValue': 8.5,
        'tenure': '5-10 years',
        'approvalConfidence': 94,
        'aiTag': 'Highly Eligible',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'HDFC Student Advantage',
        'maxAmount': '₹15 Lakhs',
        'maxAmountValue': 1500000,
        'interestRate': '9.2%',
        'interestRateValue': 9.2,
        'tenure': '7 years',
        'approvalConfidence': 68,
        'aiTag': 'Moderate Chance',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Axis Premium Tech Scholar',
        'maxAmount': '₹20 Lakhs',
        'maxAmountValue': 2000000,
        'interestRate': '8.8%',
        'interestRateValue': 8.8,
        'tenure': '10 years',
        'approvalConfidence': 45,
        'aiTag': 'Low Eligibility',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var loan in loans) {
      await _db.collection('loans').add(loan);
    }
  }
}
