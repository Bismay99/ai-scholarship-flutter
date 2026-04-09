import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_config.dart';
import '../services/firestore_service.dart';
import '../providers/chatbot_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/document_provider.dart';
import '../widgets/score_card.dart';
import '../widgets/status_timeline.dart';
import '../widgets/scholarship_card.dart';
import '../widgets/loan_card.dart';
import 'loan_result_screen.dart';
import 'credit_score_screen.dart';
import 'scholarships_screen.dart';
import 'notifications_screen.dart';
import 'analytics_screen.dart';
import 'applications_screen.dart';
import 'eligibility_screen.dart';
import 'document_verification_screen.dart';
import 'document_vault_screen.dart';
import 'settings_screen.dart';
import 'help_faq_screen.dart';
import 'share_app_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _dynamicScore = 0;
  String _dynamicTip = "";
  bool _isLoadingTip = true;
  
  // Real-time Firestore data (synced with web app)
  Map<String, dynamic>? _loanData;
  Map<String, dynamic>? _scholarshipData;
  bool _isLoadingFirestore = true;
  
  // Firestore collections data (synced with web app)
  List<Map<String, dynamic>> _firestoreScholarships = [];
  List<Map<String, dynamic>> _firestoreLoans = [];
  List<Map<String, dynamic>> _smartAlerts = [];
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _calculateDynamicScore();
    _fetchDynamicTip();
    _listenToFirestore();
    _loadSmartAlerts();
    _loadRecentActivity();
  }
  
  /// Listen to Firestore in real-time — same collections as the web app.
  /// When web app updates loanApplications or scholarshipApplications,
  /// this dashboard updates instantly (and vice versa).
  void _listenToFirestore() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;
    if (userId.isEmpty) {
      setState(() => _isLoadingFirestore = false);
      return;
    }
    
    // Listen to loan applications (same as web's onSnapshot)
    _firestoreService.streamLoanApplication(userId).listen((data) {
      if (mounted) {
        setState(() {
          _loanData = data;
          _isLoadingFirestore = false;
        });
      }
    });
    
    // Listen to scholarship applications (same as web's onSnapshot)
    _firestoreService.streamScholarshipApplication(userId).listen((data) {
      if (mounted) {
        setState(() {
          _scholarshipData = data;
          _isLoadingFirestore = false;
        });
      }
    });
    
    // Listen to scholarships collection (same data web app reads)
    FirebaseFirestore.instance.collection('scholarships').snapshots().listen((snap) {
      if (mounted) {
        setState(() {
          _firestoreScholarships = snap.docs.map((d) => d.data()).toList();
        });
      }
    });
    
    // Listen to loans collection (same data web app reads)
    FirebaseFirestore.instance.collection('loans').snapshots().listen((snap) {
      if (mounted) {
        setState(() {
          _firestoreLoans = snap.docs.map((d) => d.data()).toList();
        });
      }
    });
  }

  void _calculateDynamicScore() {
    int marks = 88;
    int income = 450000;
    bool docsUploaded = true;

    int base = 50;
    if (marks > 80) base += 15;
    if (income < 600000) base += 20;
    if (docsUploaded) base += 15;

    setState(() {
      _dynamicScore = base;
    });
  }

  Future<void> _fetchDynamicTip() async {
    try {
      final apiKey = ApiConfig.groqApiKey;
      const url = 'https://api.groq.com/openai/v1/chat/completions';
      final dio = Dio();

      final response = await dio.post(
        url,
        data: {
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "user",
              "content": "Based on a student with 88% marks, Rs. 4,50,000 annual income, and fully verified documents, provide ONE short practical tip (max 1 sentence) to boost their loan or scholarship chances. No quotes or formatting."
            }
          ]
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          receiveTimeout: const Duration(seconds: 15)
        )
      );

      if (response.statusCode == 200) {
        final text = response.data['choices'][0]['message']['content'] as String;
        setState(() {
          _dynamicTip = text.replaceAll('\n', '').trim();
          _isLoadingTip = false;
        });
      } else {
        _setFallbackTip();
      }
    } catch (e) {
      _setFallbackTip();
    }
  }

  void _setFallbackTip() {
    setState(() {
      _dynamicTip = "Upload a secondary guarantor proof to instantly increase your maximum loan limit.";
      _isLoadingTip = false;
    });
  }

  void _showAIDecision() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🧠 AI Decision Breakdown", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 10),
            Text("Calculated from your unique profile traits:", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
            const SizedBox(height: 25),
            _decisionRow("Excellent Academic Score (88%)", true, theme),
            _decisionRow("Verified Identity Documents (Aadhar, PAN)", true, theme),
            _decisionRow("Matched Income Criteria (Below 8L Bracket)", true, theme),
            _decisionRow("Co-Applicant Financial Proof Pending", false, theme),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary, 
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: const Text("Got it", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              )
            )
          ]
        )
      )
    );
  }

  Widget _decisionRow(String text, bool isPositive, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(isPositive ? Icons.check_circle : Icons.warning_amber_rounded, color: isPositive ? const Color(0xFF34D399) : const Color(0xFFFBBF24), size: 26),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16))),
        ],
      )
    );
  }

  void _loadSmartAlerts() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;
    if (userId.isEmpty) return;
    
    FirebaseFirestore.instance.collection('alerts').where('userId', isEqualTo: userId).snapshots().listen((snap) {
      if (mounted) {
        setState(() {
          _smartAlerts = snap.docs.map((d) => d.data()).toList();
        });
      }
    });
    
    // If no alerts from Firestore, use generated ones
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _smartAlerts.isEmpty) {
        setState(() {
          _smartAlerts = _generateContextualAlerts();
        });
      }
    });
  }

  List<Map<String, dynamic>> _generateContextualAlerts() {
    final alerts = <Map<String, dynamic>>[];
    
    if (_loanData != null && _loanData!['status'] == 'Submitted') {
      alerts.add({'icon': 'timer', 'title': 'Loan Under Review', 'desc': 'Your loan application is being processed. Expected update within 48 hours.', 'color': 'blue'});
    }
    if (_scholarshipData == null) {
      alerts.add({'icon': 'school', 'title': 'Scholarship Opportunity', 'desc': 'You have not applied for any scholarships yet. Check the Scholarships tab!', 'color': 'yellow'});
    }
    if (_loanData == null) {
      alerts.add({'icon': 'upload', 'title': 'Action Required', 'desc': 'Complete your profile and upload documents to apply for student loans.', 'color': 'red'});
    }
    if (_firestoreScholarships.isNotEmpty) {
      alerts.add({'icon': 'timer', 'title': 'Deadlines Active', 'desc': '${_firestoreScholarships.length} scholarship(s) are open. Apply before they close!', 'color': 'red'});
    }
    
    return alerts;
  }

  void _loadRecentActivity() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;
    if (userId.isEmpty) return;
    
    FirebaseFirestore.instance
        .collection('activity')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(3)
        .snapshots()
        .listen((snap) {
      if (mounted) {
        setState(() {
          _recentActivity = snap.docs.map((d) => d.data()).toList();
        });
      }
    }, onError: (_) {
      // If collection doesn't exist, use generated activity
      if (mounted && _recentActivity.isEmpty) {
        setState(() {
          _recentActivity = _generateRecentActivity();
        });
      }
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _recentActivity.isEmpty) {
        setState(() {
          _recentActivity = _generateRecentActivity();
        });
      }
    });
  }

  List<Map<String, dynamic>> _generateRecentActivity() {
    final activity = <Map<String, dynamic>>[];
    
    if (_loanData != null) {
      activity.add({'icon': 'account_balance', 'title': 'Loan Application Submitted', 'time': 'Today', 'color': 'blue'});
    }
    if (_scholarshipData != null) {
      activity.add({'icon': 'school', 'title': 'Scholarship Application Sent', 'time': 'Today', 'color': 'green'});
    }
    activity.add({'icon': 'login', 'title': 'Logged into EduFinance AI', 'time': 'Just now', 'color': 'grey'});
    
    return activity;
  }

  Widget _buildSmartAlerts(ThemeData theme) {
    IconData _getAlertIcon(String? icon) {
      switch (icon) {
        case 'timer': return Icons.timer;
        case 'upload': return Icons.upload_file;
        case 'school': return Icons.school;
        default: return Icons.notifications_active;
      }
    }
    Color _getAlertColor(String? color) {
      switch (color) {
        case 'red': return const Color(0xFFF43F5E);
        case 'yellow': return const Color(0xFFFBBF24);
        case 'blue': return const Color(0xFF3B82F6);
        case 'green': return const Color(0xFF34D399);
        default: return const Color(0xFFFBBF24);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("Smart Alerts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
         const SizedBox(height: 15),
         if (_smartAlerts.isEmpty)
           _alertItem(Icons.check_circle, "All Clear", "No alerts at this time. You're on track!", const Color(0xFF34D399), theme)
         else
           ..._smartAlerts.map((alert) => Padding(
             padding: const EdgeInsets.only(bottom: 10),
             child: _alertItem(
               _getAlertIcon(alert['icon']),
               alert['title'] ?? 'Alert',
               alert['desc'] ?? '',
               _getAlertColor(alert['color']),
               theme,
             ),
           )),
      ]
    );
  }

  Widget _alertItem(IconData icon, String title, String desc, Color color, ThemeData theme) {
    return Container(
       padding: const EdgeInsets.all(15),
       decoration: BoxDecoration(
         color: theme.cardColor,
         borderRadius: BorderRadius.circular(15),
         border: Border.all(color: theme.dividerColor),
         boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))] : [],
       ),
       child: Row(
         children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
                   const SizedBox(height: 4),
                   Text(desc, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 13, height: 1.3)),
                ]
              )
            )
         ]
       )
    );
  }

  Widget _buildAIPulseCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withOpacity(0.4) : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
                        ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1.seconds, curve: Curves.easeInOut).fadeOut(),
                        const SizedBox(width: 6),
                        Text("LIVE AI ANALYSIS", style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                _isLoadingTip ? "AI is reviewing your data..." : "Personalized Strategy:",
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _dynamicTip,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _showAIDecision,
                child: Row(
                  children: [
                    Text("View Full Breakdown", style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: colorScheme.primary, size: 12),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 20,
            child: Icon(Icons.psychology_outlined, color: colorScheme.primary.withOpacity(0.15), size: 60)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds)
                .rotate(begin: -0.05, end: 0.05),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildQuickNavBar(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _quickActionIcon(Icons.verified_outlined, "Eligibility", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EligibilityScreen())), theme),
          _quickActionIcon(Icons.upload_file_outlined, "Documents", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentVerificationScreen())), theme),
          _quickActionIcon(Icons.pie_chart_outline, "Analytics", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen())), theme),
          _quickActionIcon(Icons.shield_outlined, "Vault", () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentVaultScreen())), theme),
          _quickActionIcon(Icons.smart_toy_outlined, "Chat AI", () => Provider.of<ChatbotProvider>(context, listen: false).toggleExpanded(), theme),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _quickActionIcon(IconData icon, String label, VoidCallback onTap, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMini(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusCard({
    required ThemeData theme,
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtext,
    bool showProgress = false,
    double progressValue = 0.0,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
        boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          // Title
          Text(title, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          // Value
          Text(value, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          // Subtext
          Text(subtext, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 11)),
          
          if (showProgress) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      color: iconColor,
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("${(progressValue * 100).toInt()}%", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            )
          ]
        ],
      ),
    ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('AI Finance Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 28),
                color: theme.appBarTheme.iconTheme?.color,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                },
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.secondary.withOpacity(0.9), colorScheme.primary.withOpacity(0.9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white24,
                          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('EduFinance AI', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 2),
                  Text(
                    Provider.of<AuthProvider>(context, listen: false).userEmail,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.verified, color: colorScheme.primary),
              title: Text('Check Eligibility', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const EligibilityScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.insights, color: colorScheme.primary),
              title: Text('Analytics & Progress', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.verified_user, color: colorScheme.secondary),
              title: Text('Verified Documents', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentVerificationScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.shield_outlined, color: colorScheme.primary),
              title: Text('Document Vault', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentVaultScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.smart_toy_outlined, color: colorScheme.primary),
              title: Text('AI Chatbot', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Provider.of<ChatbotProvider>(context, listen: false).toggleExpanded(); },
            ),
            Divider(color: theme.dividerColor, height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: Colors.grey),
              title: Text('Settings', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.grey),
              title: Text('Help & FAQ', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpFaqScreen())); },
            ),
            ListTile(
              leading: Icon(Icons.share_outlined, color: Colors.grey),
              title: Text('Share App', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ShareAppScreen())); },
            ),
            Divider(color: theme.dividerColor, height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text('Logout', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
              onTap: () { Navigator.pop(context); Provider.of<AuthProvider>(context, listen: false).signOut(); },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Stack(
                children: [
                   Positioned(
                    top: -100,
                    left: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withOpacity(theme.brightness == Brightness.dark ? 0.08 : 0.05),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.6, 1.6), duration: 10.seconds, curve: Curves.easeInOut),
                  ),
                  Positioned(
                    bottom: 200,
                    right: -100,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withOpacity(theme.brightness == Brightness.dark ? 0.06 : 0.04),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 8.seconds, curve: Curves.easeInOut),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Welcome Header with AIPulseCard
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello,", style: TextStyle(fontSize: 16, color: colorScheme.onSurface.withOpacity(0.6))),
                      Text("${Provider.of<AuthProvider>(context, listen: false).userName.isNotEmpty ? Provider.of<AuthProvider>(context, listen: false).userName.split(' ').first : 'User'}!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -0.5)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorScheme.primary.withOpacity(0.5))),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.person_rounded, color: colorScheme.primary),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 25),
              
              // AI Pulse Insights Card
              _buildAIPulseCard(theme),
              
              const SizedBox(height: 25),
              
              // Quick Actions Nav Bar
              _buildQuickNavBar(theme),
              
              const SizedBox(height: 30),
              
              // ─── Real-time Firestore Data from Web App ───
              if (_isLoadingFirestore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(color: colorScheme.primary)),
                )
              else if (_loanData != null || _scholarshipData != null) ...[
                const SizedBox(height: 20),
                Text("📡 Live Synced Applications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 10),
                if (_loanData != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: colorScheme.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.account_balance, color: colorScheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text("Student Loan App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle))
                                      .animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds).fadeOut(),
                                  const SizedBox(width: 6),
                                  Text("SYNCED", style: TextStyle(color: const Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 9)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoMini("STATUS", _loanData!['status'] ?? 'Active', theme),
                            _buildInfoMini("AMOUNT", "₹${_loanData!['bankLoanInfo']?['loanAmount'] ?? 'N/A'}", theme),
                            _buildInfoMini("ID", (_loanData!['applicationId'] ?? '...').toString().substring(0, 8), theme),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
                if (_scholarshipData != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(color: colorScheme.secondary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: colorScheme.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(Icons.school, color: colorScheme.secondary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text("Scholarship App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle))
                                      .animate(onPlay: (c) => c.repeat()).scale(duration: 1.seconds).fadeOut(),
                                  const SizedBox(width: 6),
                                  Text("SYNCED", style: TextStyle(color: const Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 9)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoMini("STATUS", _scholarshipData!['status'] ?? 'Active', theme),
                            _buildInfoMini("NAME", (_scholarshipData!['personalInfo']?['name'] ?? 'N/A').toString().split(' ').first, theme),
                            _buildInfoMini("ID", (_scholarshipData!['applicationId'] ?? '...').toString().substring(0, 8), theme),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1, end: 0),
              ],
              
              const SizedBox(height: 30),

              // Status Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 16.0;
                  final cardWidth = (constraints.maxWidth - spacing) / 2;
                  
                  return Column(
                    children: [
                      Row(
                        children: [
                          _buildStatusCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.account_balance,
                            iconColor: const Color(0xFF3B82F6), // Blue
                            title: "ACTIVE LOAN APP",
                            value: _loanData != null ? (_loanData!['status'] ?? 'Active') : "N/A",
                            subtext: _loanData != null ? "₹${_loanData!['bankLoanInfo']?['loanAmount'] ?? 'Unknown'}" : "No application yet",
                          ),
                          SizedBox(width: spacing),
                          _buildStatusCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.school,
                            iconColor: const Color(0xFF8B5CF6), // Purple
                            title: "SCHOLARSHIP APP",
                            value: _scholarshipData != null ? (_scholarshipData!['status'] ?? 'Active') : "None",
                            subtext: _scholarshipData != null ? "ID: ${_scholarshipData!['applicationId'] ?? '...'}" : "Apply for scholarships",
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          _buildStatusCard(
                            theme: theme,
                            width: cardWidth,
                            icon: Icons.track_changes,
                            iconColor: const Color(0xFF10B981), // Green
                            title: "TOTAL APPLICATIONS",
                            value: "${(_loanData != null ? 1 : 0) + (_scholarshipData != null ? 1 : 0)}",
                            subtext: "${(_loanData != null ? 1 : 0) + (_scholarshipData != null ? 1 : 0)} submitted, 0 draft",
                            showProgress: true,
                            progressValue: ((_loanData != null ? 1 : 0) + (_scholarshipData != null ? 1 : 0)) > 0 ? 1.0 : 0.0,
                          ),
                          SizedBox(width: spacing),
                          Consumer<DocumentProvider>(
                            builder: (context, docs, _) {
                              return _buildStatusCard(
                                theme: theme,
                                width: cardWidth,
                                icon: Icons.verified_user_outlined,
                                iconColor: const Color(0xFF60A5FA), // Light Blue
                                title: "DOCUMENTS STATUS",
                                value: docs.isFullyVerified ? "Verified" : "Pending",
                                subtext: docs.isFullyVerified ? "All docs approved" : "No documents yet",
                              );
                            }
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
              
              if (_loanData != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => CreditScoreScreen(score: _loanData?['creditScore'] ?? 0))); },
                        child: ScoreCard(
                          title: "AI Credit Score",
                          score: _loanData?['creditScore'] ?? 0,
                          maxScore: 900,
                          description: (_loanData?['creditScore'] ?? 0) > 700 ? "Low Risk Level" : "Review Required",
                          gradientColors: [colorScheme.primary, const Color(0xFF1E3A8A)],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
              ],
              const SizedBox(height: 30),

              // Application Status (Only show if there's an active application)
              if (_loanData != null || _scholarshipData != null) ...[
                const SizedBox(height: 30),
                Text("Active Application", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                    boxShadow: theme.brightness == Brightness.light ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))] : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Text("Overall Progress", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${_loanData?['progress'] ?? '50'}%", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                         ]
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: (_loanData?['progress'] ?? 50) / 100,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        color: colorScheme.primary,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ).animate().scaleX(begin: 0, end: 1, duration: 800.ms, alignment: Alignment.centerLeft),
                      const SizedBox(height: 20),
                      StatusTimeline(
                        steps: const ["Document Uploaded", "AI Verification", "Eligibility Check", "Final Approval"],
                        currentStep: _loanData?['statusStep'] ?? 1,
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showAIDecision,
                              icon: Icon(Icons.analytics_outlined, color: colorScheme.primary),
                              label: Text("View AI Decision", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colorScheme.primary),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, end: 0),
              ],
              
              const SizedBox(height: 30),
              
              // AI Quick Tips
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.secondary.withOpacity(0.1), colorScheme.primary.withOpacity(0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded, color: colorScheme.primary, size: 36),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI Tip: Boost Eligibility", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 5),
                          if (_isLoadingTip)
                             Padding(padding: const EdgeInsets.only(top: 8), child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(color: colorScheme.secondary, strokeWidth: 2)))
                          else
                             Text(_dynamicTip, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8), fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 550.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 30),
              _buildSmartAlerts(theme).animate().fadeIn(duration: 400.ms, delay: 580.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 30),
              
              // Quick Apply CTA
              if (_firestoreScholarships.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFF7C3AED), colorScheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rocket_launch, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text("Quick Apply", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("${_firestoreScholarships.length} open", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${_firestoreScholarships.first['title'] ?? 'Scholarship'} is accepting applications now!",
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ScholarshipsScreen())); },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF7C3AED),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("View & Apply Now", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 590.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 30),
              
              // Recent Activity
              Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 15),
              ..._recentActivity.asMap().entries.map((entry) {
                final act = entry.value;
                final index = entry.key;
                IconData icon;
                Color color;
                switch (act['icon']) {
                  case 'account_balance': icon = Icons.account_balance; color = const Color(0xFF3B82F6); break;
                  case 'school': icon = Icons.school; color = const Color(0xFF34D399); break;
                  case 'upload': icon = Icons.upload_file; color = const Color(0xFFFBBF24); break;
                  case 'verified': icon = Icons.verified; color = Colors.green; break;
                  default: icon = Icons.history; color = Colors.grey;
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(act['title'] ?? 'Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)),
                            const SizedBox(height: 2),
                            Text(act['time'] ?? '', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colorScheme.onSurface.withOpacity(0.3), size: 20),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 600 + (index * 80))).slideX(begin: 0.03, end: 0);
              }),

              const SizedBox(height: 30),

              // Recommended Scholarships
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recommended for You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                  GestureDetector(
                    onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ScholarshipsScreen())); },
                    child: Text("See All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              SizedBox(
                height: 440,
                child: _firestoreScholarships.isEmpty
                  ? const Center(child: Text("No scholarships available yet", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _firestoreScholarships.length,
                      itemBuilder: (context, index) {
                        final sch = _firestoreScholarships[index];
                        return SizedBox(
                          width: 290,
                          child: ScholarshipCard(
                            title: sch['title'] ?? '',
                            amount: sch['amount'] ?? '',
                            matchPercentage: (sch['matchPercentage'] ?? 0).toInt(),
                            deadline: sch['deadline'] ?? '',
                            eligibility: sch['eligibility'] ?? '',
                            aiTag: sch['aiTag'] ?? '',
                          ),
                        );
                      },
                    ),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(begin: 0.1, end: 0),
              
              const SizedBox(height: 30),
              
              // Loan Marketplace Section (Horizontal Carousel)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, color: colorScheme.primary, size: 18),
                            const SizedBox(width: 8),
                            Text("AI Matched Loans", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.onSurface, letterSpacing: -0.5)),
                          ],
                        ),
                        Text("Personalized for your profile", style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.5))),
                      ],
                    ),
                    TextButton(
                      onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const ScholarshipsScreen())); },
                      child: Text("Explore All", style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                height: 440,
                child: _firestoreLoans.isEmpty
                  ? const Center(child: Text("No loans available yet", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _firestoreLoans.length,
                      itemBuilder: (context, index) {
                        final loan = _firestoreLoans[index];
                        return SizedBox(
                          width: 290,
                          child: LoanCard(
                            title: loan['title'] ?? '',
                            maxAmount: loan['maxAmount'] ?? '',
                            interestRate: loan['interestRate'] ?? '',
                            tenure: loan['tenure'] ?? '',
                            approvalConfidence: (loan['approvalConfidence'] ?? 0).toInt(),
                            aiTag: loan['aiTag'] ?? '',
                          ),
                        );
                      },
                    ),
              ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: 0.1, end: 0),

              const SizedBox(height: 60),
              
              // New Footer Section
              _buildAppFooter(theme),
            ],
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildAppFooter(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.05),
        border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.secondary]),
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                "EduFinance AI",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Revolutionizing student finance with AI-driven insights and automated verification for a better tomorrow.",
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 30),
          
          // Contact Section
          Text("GET IN TOUCH", style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 15),
          _contactPill(Icons.mail_outline, "support@edufinance.ai", theme),
          const SizedBox(height: 10),
          _contactPill(Icons.business_center_outlined, "business@edufinance.ai", theme),
          
          const SizedBox(height: 40),
          Divider(color: theme.dividerColor.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(
            "© 2026 EduFinance AI • v1.0.0-Hackathon",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Built with ❤️ for Global AI Hackathon",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.2), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _contactPill(IconData icon, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.8), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
