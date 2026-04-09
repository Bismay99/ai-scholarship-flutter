import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/scholarship_card.dart';

class ScholarshipModel {
  final String title;
  final String amountStr;
  final double amountValue;
  final int matchPercentage;
  final String deadlineStr;
  final String eligibility;
  final String aiTag;

  ScholarshipModel({
    required this.title,
    required this.amountStr,
    required this.amountValue,
    required this.matchPercentage,
    required this.deadlineStr,
    required this.eligibility,
    required this.aiTag,
  });

  factory ScholarshipModel.fromFirestore(Map<String, dynamic> data) {
    return ScholarshipModel(
      title: data['title'] ?? '',
      amountStr: data['amount'] ?? '',
      amountValue: (data['amountValue'] ?? 0).toDouble(),
      matchPercentage: (data['matchPercentage'] ?? 0).toInt(),
      deadlineStr: data['deadline'] ?? '',
      eligibility: data['eligibility'] ?? '',
      aiTag: data['aiTag'] ?? '',
    );
  }
}

class ScholarshipsScreen extends StatefulWidget {
  const ScholarshipsScreen({super.key});

  @override
  State<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ScholarshipModel> allScholarships = [];
  List<ScholarshipModel> filteredScholarships = [];
  String _selectedSort = 'Eligibility';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScholarshipsFromFirestore();
  }

  void _loadScholarshipsFromFirestore() {
    FirebaseFirestore.instance
        .collection('scholarships')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        allScholarships = snapshot.docs
            .map((doc) => ScholarshipModel.fromFirestore(doc.data()))
            .toList();
        filteredScholarships = List.from(allScholarships);
        _isLoading = false;
        _applySort();
      });
    });
  }

  void _filterScholarships(String query) {
    if (query.isEmpty) {
      filteredScholarships = List.from(allScholarships);
    } else {
      filteredScholarships = allScholarships.where((sch) {
        final lowerQuery = query.toLowerCase();
        return sch.title.toLowerCase().contains(lowerQuery) ||
               sch.amountStr.toLowerCase().contains(lowerQuery) ||
               sch.eligibility.toLowerCase().contains(lowerQuery) ||
               sch.aiTag.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    _applySort();
  }

  void _applySort() {
    setState(() {
      if (_selectedSort == 'Amount (High to Low)') {
        filteredScholarships.sort((a, b) => b.amountValue.compareTo(a.amountValue));
      } else if (_selectedSort == 'Deadline (Nearest first)') {
        filteredScholarships.sort((a, b) => a.deadlineStr.compareTo(b.deadlineStr));
      } else if (_selectedSort == 'Eligibility') {
        filteredScholarships.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
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
              _buildSortOption('Amount (High to Low)'),
              _buildSortOption('Deadline (Nearest first)'),
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
        title: const Text('AI Scholarship Matches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                    onChanged: _filterScholarships,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search scholarships...',
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
                : filteredScholarships.isEmpty
                  ? const Center(child: Text("No scholarships matched your search.", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: filteredScholarships.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        final sch = filteredScholarships[index];
                        final delayCalc = index * 100;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ScholarshipCard(
                            title: sch.title,
                            amount: sch.amountStr,
                            matchPercentage: sch.matchPercentage,
                            deadline: sch.deadlineStr,
                            eligibility: sch.eligibility,
                            aiTag: sch.aiTag,
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
