import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF22D3EE),
          labelColor: const Color(0xFF22D3EE),
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: "Active Tracker"),
            Tab(text: "History / Archive"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveTracker(),
          _buildArchive(),
        ],
      ),
    );
  }

  Widget _buildActiveTracker() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    if (userId.isEmpty) {
      return const Center(child: Text("Please login to view applications", style: TextStyle(color: Colors.white54)));
    }

    return StreamBuilder<List<Map<String, dynamic>?>>(
      stream: _getCombinedStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)));
        }

        final loanData = snapshot.data?[0];
        final scholarshipData = snapshot.data?[1];

        if (loanData == null && scholarshipData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 60, color: Colors.white24),
                const SizedBox(height: 15),
                const Text("No active applications", style: TextStyle(color: Colors.white54, fontSize: 16)),
                const SizedBox(height: 8),
                Text("Apply from the web or mobile app", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (loanData != null)
              _buildAppCard(
                type: "Loan Application",
                name: loanData['academicInfo']?['courseName'] ?? "Education Loan",
                amount: "₹${loanData['bankLoanInfo']?['loanAmount'] ?? 'N/A'}",
                status: loanData['status'] ?? 'Unknown',
                statusColor: (loanData['status'] == 'Submitted') ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                aiConfidence: 88,
                isLoan: true,
              ),
            if (scholarshipData != null)
              _buildAppCard(
                type: "Scholarship",
                name: scholarshipData['personalInfo']?['name'] ?? "Scholarship Application",
                amount: scholarshipData['applicationId'] ?? 'N/A',
                status: scholarshipData['status'] ?? 'Unknown',
                statusColor: (scholarshipData['status'] == 'Submitted') ? const Color(0xFF22D3EE) : const Color(0xFFFBBF24),
                aiConfidence: 95,
                isLoan: false,
              ),
          ].animate(interval: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  /// Combines two Firestore streams into one for the UI
  Stream<List<Map<String, dynamic>?>> _getCombinedStream(String userId) {
    final loanStream = _firestoreService.streamLoanApplication(userId);
    final scholarshipStream = _firestoreService.streamScholarshipApplication(userId);
    
    return loanStream.asyncExpand((loanData) {
      return scholarshipStream.map((scholarshipData) {
        return [loanData, scholarshipData];
      });
    });
  }

  Widget _buildArchive() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 60, color: Colors.white24),
          const SizedBox(height: 15),
          const Text("No archived applications", style: TextStyle(color: Colors.white54, fontSize: 16)),
          const SizedBox(height: 8),
          Text("Completed applications will appear here", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
        ],
      ),
    );
  }


  Widget _buildAppCard({
    required String type,
    required String name,
    required String amount,
    required String status,
    required Color statusColor,
    required int aiConfidence,
    required bool isLoan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E3A8A).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(amount, style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(isLoan ? Icons.account_balance : Icons.school, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              const Text("AI Confidence Score:", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Text("$aiConfidence%", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: aiConfidence / 100,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(aiConfidence > 90 ? const Color(0xFF22D3EE) : const Color(0xFF7C3AED)),
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedItem({required String year, required String name, required String status, required Color statusColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(year, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF22D3EE)),
            onPressed: () {},
            tooltip: "Download PDF Record",
          )
        ],
      ),
    );
  }
}
