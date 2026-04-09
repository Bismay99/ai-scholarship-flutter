import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/loan_card.dart';

class LoanModel {
  final String title;
  final String maxAmountStr;
  final double maxAmountValue;
  final String interestRateStr;
  final double interestRateValue;
  final String tenure;
  final int approvalConfidence;
  final String aiTag;

  LoanModel({
    required this.title,
    required this.maxAmountStr,
    required this.maxAmountValue,
    required this.interestRateStr,
    required this.interestRateValue,
    required this.tenure,
    required this.approvalConfidence,
    required this.aiTag,
  });

  factory LoanModel.fromFirestore(Map<String, dynamic> data) {
    return LoanModel(
      title: data['title'] ?? '',
      maxAmountStr: data['maxAmount'] ?? '',
      maxAmountValue: (data['maxAmountValue'] ?? 0).toDouble(),
      interestRateStr: data['interestRate'] ?? '',
      interestRateValue: (data['interestRateValue'] ?? 0).toDouble(),
      tenure: data['tenure'] ?? '',
      approvalConfidence: (data['approvalConfidence'] ?? 0).toInt(),
      aiTag: data['aiTag'] ?? '',
    );
  }
}

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<LoanModel> allLoans = [];
  List<LoanModel> filteredLoans = [];
  String _selectedSort = 'Eligibility';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoansFromFirestore();
  }

  void _loadLoansFromFirestore() {
    FirebaseFirestore.instance
        .collection('loans')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        allLoans = snapshot.docs
            .map((doc) => LoanModel.fromFirestore(doc.data()))
            .toList();
        filteredLoans = List.from(allLoans);
        _isLoading = false;
        _applySort();
      });
    });
  }

  void _filterLoans(String query) {
    if (query.isEmpty) {
      filteredLoans = List.from(allLoans);
    } else {
      filteredLoans = allLoans.where((loan) {
        final lowerQuery = query.toLowerCase();
        return loan.title.toLowerCase().contains(lowerQuery) ||
               loan.interestRateStr.toLowerCase().contains(lowerQuery) ||
               loan.maxAmountStr.toLowerCase().contains(lowerQuery) ||
               loan.tenure.toLowerCase().contains(lowerQuery) ||
               loan.aiTag.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    _applySort();
  }

  void _applySort() {
    setState(() {
      if (_selectedSort == 'Interest Rate (Low to High)') {
        filteredLoans.sort((a, b) => a.interestRateValue.compareTo(b.interestRateValue));
      } else if (_selectedSort == 'Amount (High to Low)') {
        filteredLoans.sort((a, b) => b.maxAmountValue.compareTo(a.maxAmountValue));
      } else if (_selectedSort == 'Eligibility') {
        filteredLoans.sort((a, b) => b.approvalConfidence.compareTo(a.approvalConfidence));
      }
    });
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sort Options", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildSortOption('Eligibility'),
              _buildSortOption('Interest Rate (Low to High)'),
              _buildSortOption('Amount (High to Low)'),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  Widget _buildSortOption(String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      trailing: _selectedSort == label ? const Icon(Icons.check, color: Color(0xFF22D3EE)) : null,
      onTap: () {
        setState(() {
          _selectedSort = label;
        });
        _applySort();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Loans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterLoans,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search loans...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF22D3EE)),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF22D3EE)),
                    onPressed: _showSortBottomSheet,
                  ),
                )
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22D3EE)))
                : filteredLoans.isEmpty
                  ? const Center(child: Text("No loans matched your search.", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: filteredLoans.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final loan = filteredLoans[index];
                        final delayCalc = index * 100;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: LoanCard(
                            title: loan.title,
                            maxAmount: loan.maxAmountStr,
                            interestRate: loan.interestRateStr,
                            tenure: loan.tenure,
                            approvalConfidence: loan.approvalConfidence,
                            aiTag: loan.aiTag,
                          ).animate().fadeIn(delay: delayCalc.ms).slideX(begin: 0.05, end: 0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
