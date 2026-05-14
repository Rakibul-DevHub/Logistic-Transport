
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/constants/app_routes.dart';

// Data Model for Notification
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final List<NotificationAction>? actions;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actions,
  });
}

enum NotificationType {
  warning,
  expense,
  report,
  load,
}

class NotificationAction {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  NotificationAction({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });
}

// Sample Data
class NotificationData {
  static List<NotificationModel> getNotifications() {
    return [
      NotificationModel(
        id: '1',
        title: 'POD Missing for Load #LD-1023',
        description: 'Upload proof of delivery to complete this load',
        iconPath: 'assets/icons/notification_allert.svg',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.warning,
        isRead: false,
        actions: [
          NotificationAction(
            label: 'UPLOAD NOW',
            onTap: () {},
            isPrimary: true,
          ),
        ],
      ),
      NotificationModel(
        id: '2',
        title: 'Expense added',
        description: '\$120.50 Fuel expense recorded for #LD-8821',
        iconPath: 'assets/icons/notification_expense.svg',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: NotificationType.expense,
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Monthly Report Ready',
        description: 'Your October financial summary is ready to view',
        iconPath: 'assets/icons/notification_report.svg',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.report,
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'New Load Assigned',
        description: 'Load #LD-1025 from Chicago to Dallas',
        iconPath: 'assets/icons/notification_new_load.svg',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.load,
        isRead: false,
        actions: [
          NotificationAction(
            label: 'ACCEPT LOAD',
            onTap: () {},
            isPrimary: true,
          ),
          NotificationAction(
            label: 'DETAILS',
            onTap: () {},
            isPrimary: false,
          ),
        ],
      ),
    ];
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = NotificationData.getNotifications();
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => NotificationModel(
        id: n.id,
        title: n.title,
        description: n.description,
        iconPath: n.iconPath,
        timestamp: n.timestamp,
        type: n.type,
        isRead: true,
        actions: n.actions,
      ))
          .toList();
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  Color _getAccentColor(NotificationType type) {
    switch (type) {
      case NotificationType.warning:
      case NotificationType.expense:
        return const Color(0xFF3B82F6);
      case NotificationType.report:
        return const Color(0xFF8B5CF6);
      case NotificationType.load:
        return const Color(0xFF3B82F6);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.popAndPushNamed(context, AppRoutes.bottomNav),
          child: Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: SvgPicture.asset(
              'assets/icons/back_button_with_circle.svg',
              width: 16,
              height: 16,
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with Mark all as read
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: _markAllAsRead,
                  child: const Text(
                    'Mark all as read',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return NotificationCard(
                  notification: _notifications[index],
                  timeAgo: _getTimeAgo(_notifications[index].timestamp),
                  accentColor: _getAccentColor(_notifications[index].type),
                  onMarkAsRead: () {
                    setState(() {
                      _notifications[index] = NotificationModel(
                        id: _notifications[index].id,
                        title: _notifications[index].title,
                        description: _notifications[index].description,
                        iconPath: _notifications[index].iconPath,
                        timestamp: _notifications[index].timestamp,
                        type: _notifications[index].type,
                        isRead: true,
                        actions: _notifications[index].actions,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final String timeAgo;
  final Color accentColor;
  final VoidCallback onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.timeAgo,
    required this.accentColor,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: notification.isRead ? Colors.transparent : accentColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: SvgPicture.asset(
                    notification.iconPath,
                    width: 45,
                    height: 45,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      notification.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Action Buttons
                    if (notification.actions != null &&
                        notification.actions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: notification.actions!.map((action) {
                          return GestureDetector(
                            onTap: action.onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: action.isPrimary
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                action.label,
                                style: TextStyle(
                                  color: action.isPrimary
                                      ? Colors.white
                                      : const Color(0xFF1E3A5F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Unread Indicator - Positioned at bottom-right
          if (!notification.isRead)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}