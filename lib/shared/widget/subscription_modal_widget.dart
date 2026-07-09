import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final bool isRecommended;

  SubscriptionPlan({
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    this.isRecommended = false,
  });
}

class SubscriptionWidget extends StatefulWidget {
  const SubscriptionWidget({super.key});

  @override
  State<SubscriptionWidget> createState() => _SubscriptionWidgetState();
}

class _SubscriptionWidgetState extends State<SubscriptionWidget> {
  int? _selectedPlanIndex;

  final List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      name: 'Basic Plan',
      description: 'For individual drivers',
      price: 29.99,
      features: [
        'Load tracking',
        'Expense tracking',
        'Reports',
      ],
    ),
    SubscriptionPlan(
      name: 'Standard Plan',
      description: 'Owner + 1 Driver',
      price: 59.99,
      isRecommended: true,
      features: [
        'Everything in Basic',
        'Driver assignment',
        'Team access',
      ],
    ),
    SubscriptionPlan(
      name: 'Premium Plan',
      description: 'Up to 3 users',
      price: 99.99,
      features: [
        'Multiple drivers',
        'Full access',
        'Priority support',
        'Advanced analytics',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE4E7EC),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
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

          // Plans List - Using Expanded with ListView
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPlanCard(_plans[index], index),
                );
              },
            ),
          ),

          // Bottom Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Dynamic Button - Shows different based on selection
                if (_selectedPlanIndex != null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handleContinue(),
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

                // Footer text
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
  }

  Widget _buildPlanCard(SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;

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
              : plan.isRecommended
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
            // Plan Header
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
                            plan.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF213A63)
                                  : const Color(0xFF161B2F),
                            ),
                          ),
                          if (plan.isRecommended) ...[
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
                        plan.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF73809A),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
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
                    const Text(
                      '/month',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF73809A),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            ...plan.features.map(
                  (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF213A63)
                            : const Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF213A63),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF161B2F)
                            : const Color(0xFF5F6980),
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selection Indicator
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

  void _startFreeTrial() {
    // Show free trial confirmation
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close modal
              // Navigate to onboarding or dashboard
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

  void _handleContinue() {
    if (_selectedPlanIndex != null) {
      final selectedPlan = _plans[_selectedPlanIndex!];

      // Show confirmation or proceed
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
                  Icons.check_circle,
                  color: Color(0xFF27AE60),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Plan Selected'),
            ],
          ),
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
                '${selectedPlan.name} - \$${selectedPlan.price}/month',
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
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close modal
                // Navigate to payment or confirmation screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected ${selectedPlan.name}'),
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
  }
}

// Helper function to show the subscription modal
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
}

// Example usage in a button
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        backgroundColor: const Color(0xFFF5F5F7),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: () => showSubscriptionModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF213A63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
            ),
            child: const Text(
              'View Subscription Plans',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}