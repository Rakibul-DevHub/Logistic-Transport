/**
import 'model/subscription_data.dart';
import 'package:flutter/material.dart';
import 'cubit/subscription_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isYearly = false; // ✅ Default to Monthly
  int? _selectedPlanIndex;
  List<SubscriptionPlan>? _allPlans;

  // ✅ Helper to get display duration
  String _getDisplayDuration(SubscriptionPlan plan) {
    if (plan.durationInMonths >= 12) {
      final years = plan.durationInMonths ~/ 12;
      final remainingMonths = plan.durationInMonths % 12;
      if (remainingMonths == 0) {
        return '$years year${years > 1 ? 's' : ''}';
      }
      return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
    } else {
      return '${plan.durationInMonths} month${plan.durationInMonths > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit()..getSubscriptionPlans(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: _buildAppBar(),
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF223B63),
                ),
              );
            }

            if (state is SubscriptionSuccess) {
              _allPlans = state.plans;
            }

            // ✅ Filter plans based on toggle
            final filteredPlans = _allPlans?.where((plan) {
              if (isYearly) {
                return plan.durationInMonths >= 12;
              } else {
                return plan.durationInMonths < 12;
              }
            }).toList() ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 18),

                  // =========================
                  // FREE TRIAL CARD
                  // =========================
                  _buildFreeTrialCard(),

                  const SizedBox(height: 24),

                  // =========================
                  // TOGGLE
                  // =========================
                  _buildToggle(),

                  const SizedBox(height: 22),

                  // =========================
                  // PLAN CARDS
                  // =========================
                  if (filteredPlans.isNotEmpty)
                    ...filteredPlans.asMap().entries.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlanCard(plan, index, isYearly),
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          isYearly ? 'No yearly plans available' : 'No monthly plans available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5F6677),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // =========================
  // FREE TRIAL CARD
  // =========================
  Widget _buildFreeTrialCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE3E7EE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Free Trial Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2235),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Accessing all premium features',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F6677),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3267F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Trial',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F6677),
                ),
              ),
              Text(
                '5 days left',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF223B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF223B63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // TOGGLE
  // =========================
  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Monthly',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: !isYearly
                ? const Color(0xFF1B2235)
                : const Color(0xFF444B5A),
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () {
            setState(() {
              isYearly = !isYearly;
              _selectedPlanIndex = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48,
            height: 26,
            padding: const EdgeInsets.symmetric(
              horizontal: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF223B63),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: isYearly
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Row(
          children: [
            Text(
              'Yearly',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isYearly
                    ? const Color(0xFF1B2235)
                    : const Color(0xFF444B5A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF6C778C),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SAVE 20%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================
  // PLAN CARD
  // =========================
  Widget _buildPlanCard(SubscriptionPlan plan, int index, bool isYearlyPlan) {
    final isSelected = _selectedPlanIndex == index;

    // ✅ Determine if this is the middle plan (Recommended)
    final isRecommended = index == 1 && _allPlans != null && _allPlans!.length > 1;

    final displayDuration = _getDisplayDuration(plan);
    final periodLabel = isYearlyPlan ? 'year' : 'month';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF223B63)
                    : const Color(0xFFE3E7EE),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF223B63) : const Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),

                // Price
                Text(
                  '\$${plan.price.toStringAsFixed(2)} / $displayDuration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF223B63) : const Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),

                // Regular Price (if on sale)
                if (plan.regularPrice > plan.price)
                  Text(
                    '\$${plan.regularPrice.toStringAsFixed(2)} value',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 16,
                      color: Color(0xFF9AA2B1),
                    ),
                  ),

                const SizedBox(height: 28),

                // Features
                _featureItem('${plan.driverLimit} Drivers included'),
                const SizedBox(height: 18),
                _featureItem('${plan.durationInMonths} months duration'),
                const SizedBox(height: 18),
                _featureItem(
                  plan.autoRenewalAvailable ? 'Auto-renewal available' : 'Manual renewal',
                ),
                const SizedBox(height: 18),
                _featureItem('Premium support'),

                const SizedBox(height: 34),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlanIndex = index;
                      });
                      _handlePlanSelection(plan);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isSelected
                          ? const Color(0xFF223B63)
                          : const Color(0xFFF0F4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Select Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF223B63),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'Secure payment via Stripe. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5F6677),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MOST POPULAR BADGE
          if (isRecommended)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF223B63),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureItem(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF223B63),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            size: 15,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1B2235),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _handlePlanSelection(SubscriptionPlan plan) {
    final displayDuration = _getDisplayDuration(plan);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirm Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You have selected:',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5F6980),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${plan.title} - \$${plan.price.toStringAsFixed(2)} / $displayDuration',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF161B2F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF27AE60),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will be charged after the 7-day free trial ends',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected ${plan.title}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213A63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFFF5F5F7),
      centerTitle: true,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1B2235),
            ),
          ),
        ),
      ),
      title: const Text(
        'Subscription',
        style: TextStyle(
          color: Color(0xFF1B2235),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}*/













///
///
///
/// todo:: implementing the purchage and trial
///
///
///












// lib/feature/profile/view/subscription/subscription_screen.dart

import 'package:url_launcher/url_launcher.dart';

import 'model/subscription_data.dart';
import 'package:flutter/material.dart';
import 'cubit/subscription_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widget/subscription_modal_widget.dart';
import 'cubit/subscription_cubit.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool isYearly = false;
  int? _selectedPlanIndex;
  List<SubscriptionPlan>? _allPlans;

  String _getDisplayDuration(SubscriptionPlan plan) {
    if (plan.durationInMonths >= 12) {
      final years = plan.durationInMonths ~/ 12;
      final remainingMonths = plan.durationInMonths % 12;
      if (remainingMonths == 0) {
        return '$years year${years > 1 ? 's' : ''}';
      }
      return '$years year${years > 1 ? 's' : ''} $remainingMonths month${remainingMonths > 1 ? 's' : ''}';
    } else {
      return '${plan.durationInMonths} month${plan.durationInMonths > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit()..getSubscriptionPlans(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: _buildAppBar(),
        body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SubscriptionLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF223B63),
                ),
              );
            }

            if (state is SubscriptionSuccess) {
              _allPlans = state.plans;
            }

            final filteredPlans = _allPlans?.where((plan) {
              if (isYearly) {
                return plan.durationInMonths >= 12;
              } else {
                return plan.durationInMonths < 12;
              }
            }).toList() ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  _buildFreeTrialCard(),
                  const SizedBox(height: 24),
                  _buildToggle(),
                  const SizedBox(height: 22),
                  if (filteredPlans.isNotEmpty)
                    ...filteredPlans.asMap().entries.map((entry) {
                      final index = entry.key;
                      final plan = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPlanCard(plan, index, isYearly),
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          isYearly ? 'No yearly plans available' : 'No monthly plans available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF5F6677),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // ✅ Show Subscription Modal Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => showSubscriptionModal(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF213A63),
                        side: const BorderSide(color: Color(0xFF213A63), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'View All Plans',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFreeTrialCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E7EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '7-Day Free Trial Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2235),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Accessing all premium features',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5F6677),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3267F6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Trial',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Progress',
                style: TextStyle(fontSize: 14, color: Color(0xFF5F6677)),
              ),
              Text(
                '5 days left',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF223B63),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF223B63)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Monthly',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: !isYearly ? const Color(0xFF1B2235) : const Color(0xFF444B5A),
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () {
            setState(() {
              isYearly = !isYearly;
              _selectedPlanIndex = null;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 48,
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF223B63),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: isYearly ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Row(
          children: [
            Text(
              'Yearly',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isYearly ? const Color(0xFF1B2235) : const Color(0xFF444B5A),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C778C),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SAVE 20%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index, bool isYearlyPlan) {
    final isSelected = _selectedPlanIndex == index;
    final isRecommended = index == 1 && _allPlans != null && _allPlans!.length > 1;
    final displayDuration = _getDisplayDuration(plan);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
        _showConfirmationDialog(plan);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF0F4FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF223B63) : const Color(0xFFE3E7EE),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFF223B63) : const Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${plan.price.toStringAsFixed(2)} / $displayDuration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? const Color(0xFF223B63) : const Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),
                if (plan.regularPrice > plan.price)
                  Text(
                    '\$${plan.regularPrice.toStringAsFixed(2)} value',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 16,
                      color: Color(0xFF9AA2B1),
                    ),
                  ),
                const SizedBox(height: 28),
                _featureItem('${plan.driverLimit} Drivers included'),
                const SizedBox(height: 18),
                _featureItem('${plan.durationInMonths} months duration'),
                const SizedBox(height: 18),
                _featureItem(
                  plan.autoRenewalAvailable ? 'Auto-renewal available' : 'Manual renewal',
                ),
                const SizedBox(height: 18),
                _featureItem('Premium support'),
                const SizedBox(height: 34),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedPlanIndex = index;
                      });
                      _showConfirmationDialog(plan);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: isSelected
                          ? const Color(0xFF223B63)
                          : const Color(0xFFF0F4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text(
                      isSelected ? 'Selected' : 'Select Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF223B63),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Secure payment via Stripe. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5F6677),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isRecommended)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF223B63),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureItem(String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF223B63),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 15, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1B2235),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Updated Confirmation Dialog for Subscription Screen
  void _showConfirmationDialog(SubscriptionPlan selectedPlan) {
    bool autoRenewal = true;
    String selectedOption = 'trial';
    final displayDuration = _getDisplayDuration(selectedPlan);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF27AE60),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confirm Plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF161B2F),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF213A63).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPlan.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF161B2F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${selectedPlan.price.toStringAsFixed(2)} / $displayDuration',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF5F6980),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF213A63),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedPlan.durationInMonths >= 12 ? 'Yearly' : 'Monthly',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Auto Renewal Option
                    const Text(
                      'Auto Renewal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF161B2F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auto-renewal',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: autoRenewal
                                        ? const Color(0xFF213A63)
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  autoRenewal
                                      ? 'Plan will renew automatically'
                                      : 'Manual renewal required',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: autoRenewal
                                        ? Colors.green[700]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: autoRenewal,
                            onChanged: (value) {
                              setState(() {
                                autoRenewal = value;
                              });
                            },
                            activeColor: const Color(0xFF213A63),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose Payment Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF161B2F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Trial Option
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedOption == 'trial'
                            ? const Color(0xFFE8F5E9)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedOption == 'trial'
                              ? Colors.green
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'trial',
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                            activeColor: Colors.green,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Free Trial',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF161B2F),
                                  ),
                                ),
                                Text(
                                  '7 days free, then \$${selectedPlan.price.toStringAsFixed(2)} / $displayDuration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedOption == 'trial')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'FREE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Purchase Option
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedOption == 'purchase'
                            ? const Color(0xFFE3F2FD)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedOption == 'purchase'
                              ? const Color(0xFF213A63)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'purchase',
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                              });
                            },
                            activeColor: const Color(0xFF213A63),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Purchase Now',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF161B2F),
                                  ),
                                ),
                                Text(
                                  'Pay \$${selectedPlan.price.toStringAsFixed(2)} / $displayDuration',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedOption == 'purchase')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF213A63),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PAY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (selectedOption == 'trial') {
                      _startSubscriptionTrial(context, selectedPlan.id, autoRenewal);
                    } else {
                      _startSubscriptionPurchase(context, selectedPlan.id, autoRenewal);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == 'trial'
                        ? Colors.green
                        : const Color(0xFF213A63),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    selectedOption == 'trial'
                        ? 'Start Free Trial'
                        : 'Purchase Now',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startSubscriptionTrial(BuildContext context, String planId, bool autoRenewal) async {
    final cubit = context.read<SubscriptionCubit>();
    final success = await cubit.startFreeTrial(planId, autoRenewal);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Free trial started successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _startSubscriptionPurchase(BuildContext context, String planId, bool autoRenewal) async {
    final cubit = context.read<SubscriptionCubit>();
    final checkoutUrl = await cubit.purchaseSubscription(planId, autoRenewal);

    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open checkout page'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: const Color(0xFFF5F5F7),
      centerTitle: true,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1B2235),
            ),
          ),
        ),
      ),
      title: const Text(
        'Subscription',
        style: TextStyle(
          color: Color(0xFF1B2235),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}