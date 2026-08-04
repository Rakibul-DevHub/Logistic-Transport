import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/constants/app_routes.dart';
import 'package:tag/core/network/auth_session.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/home/cubit/home_report_cubit.dart';
import 'package:tag/feature/home/model/home_report_data.dart';
import 'package:tag/feature/load/cubit/load_list_cubit.dart';
import 'package:tag/feature/load/view/load_details_screen.dart';
import 'package:tag/feature/profile/view/account_settings/cubit/account_settings_cubit.dart';
import 'package:tag/feature/profile/view/account_settings/model/account_settings_data.dart';
import '../../../shared/widget/bottom_nav.dart';
import '../../../shared/widget/build_action_button.dart';
import '../../../shared/widget/build_load_card.dart';
import '../../../shared/widget/build_status_card.dart';
import '../../../shared/widget/immersive_safe_area.dart';
import '../../../shared/widget/subscription_modal_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Timer? _subscriptionTimer;
  bool _hasShownSubscription = false;
  bool _isSilentRefreshing = false;

  /// true  = owner → show Assigned Load
  /// false = not owner → hide Assigned Load
  bool _isParentDriver = false;
  bool _roleLoaded = false;

  late final HomeLoadsCubit _homeLoadsCubit;
  late final HomeReportCubit _homeReportCubit;
  late final AccountSettingsCubit _accountSettingsCubit;

  @override
  void initState() {
    super.initState();
    _homeLoadsCubit = HomeLoadsCubit();
    _homeReportCubit = HomeReportCubit()..fetch();
    // Loads SharedPreferences cache first, then refreshes from API.
    _accountSettingsCubit = AccountSettingsCubit();
    _resolveParentDriverFlag();
  }

  /// Silent refresh from bottom-nav Home tap — no loading indicators.
  Future<void> reloadSilently() async {
    if (!_roleLoaded || _isSilentRefreshing || !mounted) return;
    _isSilentRefreshing = true;
    try {
      await Future.wait([
        _homeLoadsCubit.fetchPreviews(
          includeAssigned: _isParentDriver,
          silent: true,
        ),
        _homeReportCubit.fetch(silent: true),
        _accountSettingsCubit.refreshSilently(),
      ]);
    } finally {
      _isSilentRefreshing = false;
    }
  }

  Future<void> _resolveParentDriverFlag() async {
    // 1) Prefer in-memory value set at login (most reliable).
    bool isParent;
    if (AuthSession.isParentDriver != null) {
      isParent = AuthSession.isParentDriver!;
    } else {
      // 2) Fallback to secure storage (app restart / splash path).
      isParent = await SecureStorageService.instance.getIsParentDriver();
      AuthSession.isParentDriver = isParent;
      AuthSession.isOwner = isParent;
    }

    if (!mounted) return;
    setState(() {
      _isParentDriver = isParent;
      _roleLoaded = true;
    });

    _homeLoadsCubit.fetchPreviews(includeAssigned: isParent);

    // Subscription modal: only parent/owner drivers without a plan.
    // Child drivers under a parent never see it.
    if (isParent) {
      _subscriptionTimer = Timer(const Duration(seconds: 2), () {
        if (mounted && !_hasShownSubscription) {
          _hasShownSubscription = true;
          showSubscriptionModal(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscriptionTimer?.cancel();
    _homeLoadsCubit.close();
    _homeReportCubit.close();
    _accountSettingsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // isParentDriver == true  → owner → SHOW Assigned Load
    // isParentDriver == false → not owner → HIDE Assigned Load
    final showAssignedLoad = _roleLoaded && _isParentDriver == true;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeLoadsCubit),
        BlocProvider.value(value: _homeReportCubit),
        BlocProvider.value(value: _accountSettingsCubit),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: ImmersiveSafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return _HomeContent(
                showAssignedLoad: showAssignedLoad,
                maxWidth: constraints.maxWidth,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Main Content - Header sticks like AppBar; content below scrolls
/// ---------------------------------------------------------------------------

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.showAssignedLoad,
    required this.maxWidth,
  });

  final bool showAssignedLoad;
  final double maxWidth;

  /// Design reference width (typical phone). Scale stays near 1 on phones.
  static const double _designWidth = 390;

  @override
  Widget build(BuildContext context) {
    final scale = (maxWidth / _designWidth).clamp(0.85, 1.2);
    final horizontal = (20.0 * scale).clamp(12.0, 32.0);
    final sectionGap = (24.0 * scale).clamp(16.0, 28.0);
    final topPad = (16.0 * scale).clamp(12.0, 20.0);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth > 600 ? 600 : maxWidth,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(horizontal, topPad, horizontal, 0),
              child: const _HeaderSection(),
            ),
            SizedBox(height: sectionGap),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _NetProfitCard(),
                    SizedBox(height: sectionGap),
                    const _ActionButtons(),
                    SizedBox(height: sectionGap),
                    const _StatusOverviewSection(),
                    if (showAssignedLoad) ...[
                      SizedBox(height: sectionGap),
                      const _AssignedLoadSection(),
                    ],
                    SizedBox(height: sectionGap),
                    const _MyLoadsSection(),
                    SizedBox(height: (20.0 * scale).clamp(12.0, 24.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Section - Optimized with const constructors
// ---------------------------------------------------------------------------

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(child: _UserGreetingWidget()),
        _NotificationButton(),
      ],
    );
  }
}

/// Profile avatar + greeting from Account Settings cache/API.
class _UserGreetingWidget extends StatelessWidget {
  const _UserGreetingWidget();

  bool _hasRemoteImage(UserData? user) {
    final img = user?.profileImage.trim() ?? '';
    return img.isNotEmpty && img != 'users/user.png';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
      builder: (context, state) {
        final user = state is AccountSettingsSuccess ? state.userData : null;
        final name = (user?.name.trim().isNotEmpty == true)
            ? user!.name.trim()
            : 'User';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _hasRemoteImage(user)
                    ? Image.network(
                        '${AppUrl.imageBaseUrl}/${user!.profileImage}',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          color: Color(0xFF1E3A5F),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: Color(0xFF1E3A5F),
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'hello,',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, AppRoutes.notification);
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SvgPicture.asset(
            'assets/icons/notification_button_with_circle.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Net Profit Card - Extracted and optimized
// ---------------------------------------------------------------------------

class _NetProfitCard extends StatelessWidget {
  const _NetProfitCard();

  static final NumberFormat _money = NumberFormat('#,##0.##');

  String _moneyText(double value) => '\$${_money.format(value)}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeReportCubit, HomeReportState>(
      builder: (context, state) {
        final summary = state is HomeReportSuccess
            ? state.data.summary
            : HomeReportSummary.empty();
        final loading =
            state is HomeReportLoading || state is HomeReportInitial;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A5F), Color(0xFF2E5A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A5F).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Net Profit',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loading ? '—' : _moneyText(summary.totalProfit),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _ProfitBreakdown(
                income: loading ? '—' : _moneyText(summary.totalIncome),
                expense: loading ? '—' : _moneyText(summary.totalExpenses),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfitBreakdown extends StatelessWidget {
  const _ProfitBreakdown({
    required this.income,
    required this.expense,
  });

  final String income;
  final String expense;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Income',
            value: income,
            valueColor: AppColors.totalIncomeColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Total Expense',
            value: expense,
            valueColor: AppColors.totalExpenseColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildActionButton(
            title: 'Scan BOL',
            icon: 'assets/icons/scan.svg',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.camScan);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: buildActionButton(
            title: 'Add Load',
            icon: 'assets/icons/add.svg',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.addLoading);
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status Overview Section - Optimized with const and cached data
// ---------------------------------------------------------------------------

class _StatusOverviewSection extends StatelessWidget {
  const _StatusOverviewSection();

  String _padCount(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeReportCubit, HomeReportState>(
      builder: (context, state) {
        final counts = state is HomeReportSuccess
            ? state.data.loadStatusCounts
            : HomeLoadStatusCounts.empty();
        final loading =
            state is HomeReportLoading || state is HomeReportInitial;

        final items = <_StatusData>[
          _StatusData(
            title: 'Completed',
            count: loading ? '--' : _padCount(counts.delivered),
            icon: 'assets/icons/completed.svg',
            color: const Color(0xFF12B76A),
          ),
          _StatusData(
            title: 'Missing POD',
            count: loading ? '--' : _padCount(counts.pending),
            icon: 'assets/icons/missing_pod.svg',
            color: const Color(0xFFEAAA08),
          ),
          _StatusData(
            title: 'Expense',
            count: loading ? '--' : _padCount(counts.cancelled),
            icon: 'assets/icons/expense.svg',
            color: const Color(0xFFD92D20),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final data = items[index];
                  return SizedBox(
                    width: 160,
                    child: buildStatusCard(
                      title: data.title,
                      count: data.count,
                      icon: data.icon,
                      color: data.color,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Assigned Load Section
// ---------------------------------------------------------------------------

class _AssignedLoadSection extends StatelessWidget {
  const _AssignedLoadSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Assigned Load',
          onSeeAll: () {
            context.findAncestorStateOfType<BottomNavState>()?.switchTab(1);
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<HomeLoadsCubit, HomeLoadsState>(
          builder: (context, state) {
            if (state is HomeLoadsLoading || state is HomeLoadsInitial) {
              return const _HomeLoadsShimmer();
            }
            if (state is HomeLoadsFailure) {
              return _HomeLoadsError(message: state.errorMessage);
            }
            if (state is HomeLoadsSuccess) {
              if (state.assignedLoads.isEmpty) {
                return const _HomeLoadsEmpty(label: 'No assigned loads');
              }
              return Column(
                children: state.assignedLoads
                    .take(2)
                    .map((load) => _HomeLoadCardItem(load: load))
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// My Loads Section
// ---------------------------------------------------------------------------

class _MyLoadsSection extends StatelessWidget {
  const _MyLoadsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'My Loads',
          onSeeAll: () {
            context.findAncestorStateOfType<BottomNavState>()?.switchTab(1);
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<HomeLoadsCubit, HomeLoadsState>(
          builder: (context, state) {
            if (state is HomeLoadsLoading || state is HomeLoadsInitial) {
              return const _HomeLoadsShimmer();
            }
            if (state is HomeLoadsFailure) {
              return _HomeLoadsError(message: state.errorMessage);
            }
            if (state is HomeLoadsSuccess) {
              if (state.myLoads.isEmpty) {
                return const _HomeLoadsEmpty(label: 'No loads yet');
              }
              return Column(
                children: state.myLoads
                    .take(2)
                    .map((load) => _HomeLoadCardItem(load: load))
                    .toList(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _HomeLoadCardItem extends StatelessWidget {
  const _HomeLoadCardItem({required this.load});

  final AddLoadData load;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LoadDetailsScreen(load: load),
            ),
          );
        },
        child: buildLoadCard(
          loadNumber: LoadDisplayHelper.loadNumber(load),
          driverName: LoadDisplayHelper.driverName(load),
          pickupDate: LoadDisplayHelper.formattedDate(load),
          status: LoadDisplayHelper.statusLabel(load),
          statusColor: LoadDisplayHelper.statusColor(load),
        ),
      ),
    );
  }
}

class _HomeLoadsShimmer extends StatelessWidget {
  const _HomeLoadsShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _HomeLoadsEmpty extends StatelessWidget {
  const _HomeLoadsEmpty({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.secondaryTextColor,
        ),
      ),
    );
  }
}

class _HomeLoadsError extends StatelessWidget {
  const _HomeLoadsError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: AppColors.redColor),
            ),
          ),
          TextButton(
            onPressed: () {
              final isParent = AuthSession.isParentDriver == true;
              context.read<HomeLoadsCubit>().fetchPreviews(
                    includeAssigned: isParent,
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header - Reusable component
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              overlayColor: Colors.transparent,
            ),
            child: const Text(
              'View all',
              style: TextStyle(
                color: AppColors.secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

class _StatusData {
  final String title;
  final String count;
  final String icon;
  final Color color;

  const _StatusData({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}
