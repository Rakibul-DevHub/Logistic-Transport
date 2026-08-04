import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/feature/load/view/load_details_screen.dart';
import 'package:tag/feature/notification/cubit/notification_cubit.dart';
import 'package:tag/feature/notification/model/notification_data.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..fetch(),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  final ScrollController _scrollController = ScrollController();
  bool _openingDetails = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  /// Future<void> _openNotification(AppNotification item) async {
  ///   final cubit = context.read<NotificationCubit>();
  ///   cubit.markAsReadLocal(item.id);
  ///
  ///   final loadId = (item.loadId ?? item.id).trim();
  ///   if (loadId.isEmpty) {
  ///     if (!mounted) return;
  ///     ScaffoldMessenger.of(context).showSnackBar(
  ///       const SnackBar(content: Text('No load id on this notification')),
  ///     );
  ///     return;
  ///   }
  ///
  ///   if (_openingDetails) return;
  ///   setState(() => _openingDetails = true);
  ///
  ///   try {
  ///     final load = await cubit.fetchLoadById(loadId);
  ///     if (!mounted) return;
  ///
  ///     if (load == null) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         const SnackBar(content: Text('Failed to load details')),
  ///       );
  ///       return;
  ///     }
  ///
  ///     await Navigator.push(
  ///       context,
  ///       MaterialPageRoute(
  ///         builder: (_) => LoadDetailsScreen(load: load),
  ///       ),
  ///     );
  ///   } finally {
  ///     if (mounted) setState(() => _openingDetails = false);
  ///   }
  /// }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  String _iconForType(String type) {
    switch (type.toLowerCase().trim()) {
      case 'expense':
        return 'assets/icons/notification_expense.svg';
      case 'report':
        return 'assets/icons/notification_report.svg';
      case 'warning':
      case 'alert':
        return 'assets/icons/notification_allert.svg';
      case 'load':
      case 'default':
      default:
        return 'assets/icons/notification_new_load.svg';
    }
  }

  Color _accentForType(String type) {
    switch (type.toLowerCase().trim()) {
      case 'report':
        return const Color(0xFF8B5CF6);
      case 'expense':
      case 'warning':
      case 'alert':
      case 'load':
      case 'default':
      default:
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
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      onTap: () => context
                          .read<NotificationCubit>()
                          .markAllAsReadLocal(),
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
              Expanded(
                child: BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    if (state is NotificationLoading ||
                        state is NotificationInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E3A5F),
                        ),
                      );
                    }

                    if (state is NotificationFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () =>
                                    context.read<NotificationCubit>().fetch(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final success = state as NotificationSuccess;
                    if (success.items.isEmpty) {
                      return Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: const Color(0xFF1E3A5F),
                      onRefresh: () =>
                          context.read<NotificationCubit>().fetch(),
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16)
                            .copyWith(bottom: 20),
                        itemCount: success.items.length +
                            (success.isLoadingMore ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index >= success.items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final item = success.items[index];
                          return NotificationCard(
                            notification: item,
                            iconPath: _iconForType(item.type),
                            timeAgo: _getTimeAgo(item.createdAt),
                            accentColor: _accentForType(item.type),
                            onTap: () => {},
                            /// onTap: () => _openNotification(item),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_openingDetails)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final String iconPath;
  final String timeAgo;
  final Color accentColor;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.iconPath,
    required this.timeAgo,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      width: 45,
                      height: 45,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      ),
    );
  }
}
