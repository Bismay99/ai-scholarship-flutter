import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userId;

    if (userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots()
          .listen((snap) {
        if (mounted) {
          setState(() {
            _notifications = snap.docs.map((d) {
              final data = d.data();
              data['docId'] = d.id;
              return data;
            }).toList();
            _isLoading = false;
          });
        }
      }, onError: (_) {
        if (mounted) {
          setState(() {
            _notifications = _generateDefaultNotifications();
            _isLoading = false;
          });
        }
      });
    }

    // Fallback: generate default notifications after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isLoading) {
        setState(() {
          _notifications = _generateDefaultNotifications();
          _isLoading = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> _generateDefaultNotifications() {
    return [
      {
        'icon': 'verified',
        'title': 'Welcome to EduFinance AI!',
        'message': 'Your account has been created successfully. Complete your profile to get started.',
        'time': 'Just now',
        'isUnread': true,
        'color': 'blue',
      },
      {
        'icon': 'school',
        'title': 'New Scholarships Available',
        'message': 'Check out the latest scholarship opportunities matched to your profile.',
        'time': '1 hour ago',
        'isUnread': true,
        'color': 'green',
      },
      {
        'icon': 'upload',
        'title': 'Documents Pending',
        'message': 'Upload your Aadhaar Card and Income Certificate to apply for loans.',
        'time': '2 hours ago',
        'isUnread': true,
        'color': 'yellow',
      },
      {
        'icon': 'tips',
        'title': 'AI Tip: Boost Your Score',
        'message': 'Adding a secondary guarantor proof can increase your maximum loan limit by 20%.',
        'time': '5 hours ago',
        'isUnread': false,
        'color': 'purple',
      },
      {
        'icon': 'security',
        'title': 'Security Update',
        'message': 'We\'ve enhanced our data encryption protocols. Your data is more secure than ever.',
        'time': 'Yesterday',
        'isUnread': false,
        'color': 'grey',
      },
    ];
  }

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read ✅")),
    );
  }

  void _clearAll() {
    setState(() => _notifications.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications cleared 🗑️")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final unreadCount = _notifications.where((n) => n['isUnread'] == true).length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.done_all, size: 22),
              tooltip: "Mark all read",
              onPressed: _markAllRead,
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 22),
              tooltip: "Clear all",
              onPressed: _clearAll,
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : _notifications.isEmpty
              ? _buildEmptyState(colorScheme)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unread badge
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "$unreadCount new notification${unreadCount != 1 ? 's' : ''}",
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 16),

                      // Notifications list
                      ..._notifications.map((notif) {
                        final notifId = notif['id'] ?? notif['title'];
                        return Dismissible(
                          key: Key('notif_$notifId'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete, color: Colors.red),
                          ),
                          onDismissed: (_) {
                            setState(() => _notifications.removeWhere((n) => n == notif));
                          },
                          child: _buildNotificationItem(
                            context: context,
                            icon: _getIcon(notif['icon']),
                            iconColor: _getColor(notif['color']),
                            title: notif['title'] ?? 'Notification',
                            message: notif['message'] ?? '',
                            time: notif['time'] ?? '',
                            isUnread: notif['isUnread'] ?? false,
                            index: _notifications.indexOf(notif),
                          ),
                        );
                      }),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined, size: 48, color: colorScheme.onSurface.withOpacity(0.2)),
          ),
          const SizedBox(height: 20),
          Text("No notifications", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("You're all caught up! 🎉", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.3), fontSize: 14)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? colorScheme.primary.withOpacity(0.06) : theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? colorScheme.primary.withOpacity(0.2) : theme.dividerColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: colorScheme.onSurface.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(isUnread ? 0.7 : 0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF43F5E)),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 150 + (index * 60))).slideX(begin: 0.03, end: 0);
  }

  IconData _getIcon(String? icon) {
    switch (icon) {
      case 'verified': return Icons.verified;
      case 'school': return Icons.school;
      case 'upload': return Icons.upload_file;
      case 'tips': return Icons.tips_and_updates;
      case 'security': return Icons.security;
      case 'loan': return Icons.account_balance;
      case 'warning': return Icons.warning_amber;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String? color) {
    switch (color) {
      case 'blue': return const Color(0xFF3B82F6);
      case 'green': return const Color(0xFF34D399);
      case 'yellow': return const Color(0xFFFBBF24);
      case 'red': return const Color(0xFFF43F5E);
      case 'purple': return const Color(0xFF7C3AED);
      default: return Colors.grey;
    }
  }
}
