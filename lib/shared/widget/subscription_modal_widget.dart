/**
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feature/profile/view/subscription/cubit/subscription_cubit.dart';
import '../../feature/profile/view/subscription/model/subscription_data.dart';

class SubscriptionWidget extends StatefulWidget {
  const SubscriptionWidget({super.key});

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget> {
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
      child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
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
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF213A63),
                ),
              ),
            );
          }

          if (state is SubscriptionSuccess) {
            _allPlans = state.plans;
          }

          final plans = _allPlans ?? [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF161B2F),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select the plan that best fits your needs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF73809A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: plans.isEmpty
                      ? const Center(
                    child: Text(
                      'No plans available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF73809A),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPlanCard(plans[index], index),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      if (_selectedPlanIndex != null)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _showConfirmationDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF213A63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue with Selected Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _startFreeTrial(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF213A63),
                              side: const BorderSide(color: Color(0xFF213A63), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Text(
                              'Start 7 Days Free Trial',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'No charge during trial. Cancel anytime.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF73809A),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final isRecommended = index == 1;
    final displayDuration = _getDisplayDuration(plan);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlanIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0F4FF)
              : isRecommended
              ? const Color(0xFFF8F9FC)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF213A63)
                : const Color(0xFFE4E7EC),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF213A63)
                                  : const Color(0xFF161B2F),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF213A63),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.driverLimit} drivers included',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF73809A),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF213A63)
                            : const Color(0xFF161B2F),
                      ),
                    ),
                    Text(
                      '/ $displayDuration',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF73809A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _featureItem('${plan.driverLimit} Drivers included'),
            const SizedBox(height: 8),
            _featureItem('${plan.durationInMonths} months duration'),
            const SizedBox(height: 8),
            _featureItem(
              plan.autoRenewalAvailable ? 'Auto-renewal available' : 'Manual renewal',
            ),
            const SizedBox(height: 8),
            _featureItem('Premium support'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF213A63)
                          : const Color(0xFFDDE2EB),
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFF213A63)
                        : Colors.white,
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF213A63),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5F6980),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    if (_selectedPlanIndex != null && _allPlans != null) {
      final selectedPlan = _allPlans![_selectedPlanIndex!];
      final displayDuration = _getDisplayDuration(selectedPlan);

      bool autoRenewal = true;
      String selectedOption = 'trial';

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
                                selectedPlan.durationInMonths >= 12
                                    ? 'Yearly'
                                    : 'Monthly',
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
      Navigator.pop(context);
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
          // Close the modal after launching checkout
          Navigator.pop(context);
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

  void _startFreeTrial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Icons.rocket_launch_rounded,
                color: Color(0xFF27AE60),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Start Free Trial'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Get started with a 7-day free trial!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF161B2F),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Access all Basic Plan features\n'
                  '• No payment required\n'
                  '• Cancel anytime during trial\n'
                  '• Automatic upgrade after 7 days',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5F6980),
                height: 1.5,
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Free trial started successfully!'),
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
            child: const Text('Start Free Trial'),
          ),
        ],
      ),
    );
  }
}

void showSubscriptionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) => const SubscriptionWidget(),
  );
}*/






///
///
///
/// todo:: select-unselect ,, navigation
///
///
///




import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/constants/app_routes.dart';
import '../../feature/profile/view/subscription/cubit/subscription_cubit.dart';
import '../../feature/profile/view/subscription/model/subscription_data.dart';

class SubscriptionWidget extends StatefulWidget {
  const SubscriptionWidget({super.key});

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget> {
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
      child: BlocConsumer<SubscriptionCubit, SubscriptionState>(
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
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF213A63),
                ),
              ),
            );
          }

          if (state is SubscriptionSuccess) {
            _allPlans = state.plans;
          }

          final plans = _allPlans ?? [];

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E7EC),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF161B2F),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select the plan that best fits your needs',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF73809A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: plans.isEmpty
                      ? const Center(
                    child: Text(
                      'No plans available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF73809A),
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPlanCard(plans[index], index),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      if (_selectedPlanIndex != null)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _handleContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF213A63),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Continue with Selected Plan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                      // ✅ Original free trial button (when nothing selected)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _startFreeTrial,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF213A63),
                              side: const BorderSide(
                                color: Color(0xFF213A63),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Text(
                              'Start 7 Days Free Trial',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        'No charge during trial. Cancel anytime.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF73809A),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final isRecommended = index == 1;
    final displayDuration = _getDisplayDuration(plan);

    return GestureDetector(
      onTap: () {
        // Select / Unselect
        setState(() {
          if (_selectedPlanIndex == index) {
            _selectedPlanIndex = null;
          } else {
            _selectedPlanIndex = index;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF0F4FF)
              : isRecommended
              ? const Color(0xFFF8F9FC)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF213A63)
                : const Color(0xFFE4E7EC),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF213A63)
                                  : const Color(0xFF161B2F),
                            ),
                          ),
                          if (isRecommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF213A63),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Recommended',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.driverLimit} drivers included',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF73809A),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${plan.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF213A63)
                            : const Color(0xFF161B2F),
                      ),
                    ),
                    Text(
                      '/ $displayDuration',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF73809A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _featureItem('${plan.driverLimit} Drivers included'),
            const SizedBox(height: 8),
            _featureItem('${plan.durationInMonths} months duration'),
            const SizedBox(height: 8),
            _featureItem(
              plan.autoRenewalAvailable
                  ? 'Auto-renewal available'
                  : 'Manual renewal',
            ),
            const SizedBox(height: 8),
            _featureItem('Premium support'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF213A63)
                          : const Color(0xFFDDE2EB),
                      width: 2,
                    ),
                    color:
                    isSelected ? const Color(0xFF213A63) : Colors.white,
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Color(0xFF213A63),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5F6980),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleContinue() {
    if (_selectedPlanIndex == null || _allPlans == null) return;
    final selectedPlan = _allPlans![_selectedPlanIndex!];
    // Close modal → open Subscription screen with plan id
    Navigator.pop(context, selectedPlan.id);
  }

  void _startFreeTrial() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                Icons.rocket_launch_rounded,
                color: Color(0xFF27AE60),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Start Free Trial'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get started with a 7-day free trial!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF161B2F),
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Access all Basic Plan features\n'
                  '• No payment required\n'
                  '• Cancel anytime during trial\n'
                  '• Automatic upgrade after 7 days',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF5F6980),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close dialog
              // Close modal → open Subscription screen for next steps
              Navigator.pop(context, '');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213A63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Free Trial'),
          ),
        ],
      ),
    );
  }
}

/// Shows modal only if user has NO active subscription.
/// After Continue / Free Trial confirm → opens Subscription screen.
Future<void> showSubscriptionModal(BuildContext context) async {
  // ✅ Skip modal if user already has a subscription / trial
  final activeCubit = MyActivePlanCubit();
  try {
    await activeCubit.getMyActivePlan();
    final state = activeCubit.state;

    if (state is MyActivePlanSuccess) {
      // Already subscribed (or trialing) — do not show modal
      return;
    }
  } catch (_) {
    // If check fails, still allow showing modal
  } finally {
    await activeCubit.close();
  }

  if (!context.mounted) return;

  final planId = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) => const SubscriptionWidget(),
  );

  if (!context.mounted) return;
  if (planId == null) return; // dismissed without action

  await Navigator.pushNamed(
    context,
    AppRoutes.subscriptionScreen,
    arguments: planId.isEmpty ? null : planId,
  );
}