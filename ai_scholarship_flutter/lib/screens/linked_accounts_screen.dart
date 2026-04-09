import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> linkedBanks = [
      {
        "name": "State Bank of India",
        "short": "SBI",
        "accountNo": "XXXX XXXX 4432",
        "ifsc": "SBIN0001234",
        "type": "Savings Account",
        "branch": "Mumbai Main Branch",
        "color": const Color(0xFF1A73E8),
        "status": "Active",
        "isPrimary": true,
      },
    ];

    final List<Map<String, dynamic>> availableBanks = [
      {"name": "HDFC Bank", "color": const Color(0xFF004C8F)},
      {"name": "ICICI Bank", "color": const Color(0xFFFF6B00)},
      {"name": "Punjab National Bank", "color": const Color(0xFF8B0000)},
      {"name": "Bank of Baroda", "color": const Color(0xFFE35205)},
      {"name": "Axis Bank", "color": const Color(0xFF97144D)},
      {"name": "Canara Bank", "color": const Color(0xFF006B3F)},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Financial Accounts', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Linked Bank Accounts",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 8),
            const Text(
              "Manage your bank accounts for loan disbursement and scholarship payments.",
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 24),

            // Linked Banks
            ...linkedBanks.asMap().entries.map((entry) {
              final bank = entry.value;
              return _buildLinkedBankCard(context, bank, colorScheme);
            }),

            const SizedBox(height: 30),

            // Add New Bank Section
            Text(
              "ADD NEW ACCOUNT",
              style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 14),

            ...availableBanks.asMap().entries.map((entry) {
              final index = entry.key;
              final bank = entry.value;
              return _buildAvailableBankTile(context, bank, colorScheme, index);
            }),

            const SizedBox(height: 30),

            // Security note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Bank-Grade Security", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          "Your account data is encrypted and never shared with third parties.",
                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkedBankCard(BuildContext context, Map<String, dynamic> bank, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final Color bankColor = bank["color"];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bankColor.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: bankColor.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Bank header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bankColor.withOpacity(0.15), bankColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19),
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bankColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      bank["short"],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bank["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(bank["type"], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text("Active", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bank details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildDetailRow("Account Number", bank["accountNo"], colorScheme),
                const SizedBox(height: 12),
                _buildDetailRow("IFSC Code", bank["ifsc"], colorScheme),
                const SizedBox(height: 12),
                _buildDetailRow("Branch", bank["branch"], colorScheme),
                const SizedBox(height: 16),
                if (bank["isPrimary"])
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, color: colorScheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text("Primary Account", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildDetailRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 13)),
        Text(value, style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }

  Widget _buildAvailableBankTile(BuildContext context, Map<String, dynamic> bank, ColorScheme colorScheme, int index) {
    final theme = Theme.of(context);
    final Color bankColor = bank["color"];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Connecting to ${bank['name']}... 🏦")),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: bankColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(Icons.account_balance, color: bankColor, size: 20),
          ),
        ),
        title: Text(bank["name"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Linking ${bank['name']}...")),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text("Link", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 450 + (index * 50))).slideX(begin: 0.03, end: 0);
  }
}
