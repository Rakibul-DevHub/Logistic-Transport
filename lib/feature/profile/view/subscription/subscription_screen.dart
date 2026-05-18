import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState
    extends State<SubscriptionScreen> {
  bool isYearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            const SizedBox(height: 18),

            // =========================
            // FREE TRIAL CARD
            // =========================
            Container(
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
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '7-Day Free Trial Active',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                Color(0xFF1B2235),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Accessing all premium features',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                Color(0xFF5F6677),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xFF3267F6),
                          borderRadius:
                          BorderRadius.circular(
                            22,
                          ),
                        ),
                        child: const Text(
                          'Trial',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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
                    borderRadius:
                    BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 8,
                      backgroundColor:
                      const Color(0xFFE5E7EB),
                      valueColor:
                      const AlwaysStoppedAnimation(
                        Color(0xFF223B63),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // TOGGLE
            // =========================
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Text(
                  'Monthly',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isYearly
                        ? const Color(0xFF444B5A)
                        : const Color(0xFF1B2235),
                  ),
                ),

                const SizedBox(width: 14),

                GestureDetector(
                  onTap: () {
                    setState(() {
                      isYearly = !isYearly;
                    });
                  },
                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 250),
                    width: 48,
                    height: 26,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF223B63),
                      borderRadius:
                      BorderRadius.circular(30),
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
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                        const Color(0xFF6C778C),
                        borderRadius:
                        BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SAVE 20%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =========================
            // PLAN CARD
            // =========================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.fromLTRB(
                    22,
                    26,
                    22,
                    20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(14),
                    border: Border.all(
                      color:
                      const Color(0xFF223B63),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pro Plan',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.w600,
                          color: Color(0xFF1B2235),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        isYearly
                            ? '\$199.99 / year'
                            : '\$19.99 / month',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.w700,
                          color: Color(0xFF1B2235),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        '\$249.99 value',
                        style: TextStyle(
                          decoration:
                          TextDecoration
                              .lineThrough,
                          fontSize: 16,
                          color: Color(0xFF9AA2B1),
                        ),
                      ),

                      const SizedBox(height: 28),

                      _featureItem(
                        'Unlimited Loads',
                      ),

                      const SizedBox(height: 18),

                      _featureItem(
                        'Full Reports',
                      ),

                      const SizedBox(height: 18),

                      _featureItem(
                        'Send documents to accountant',
                      ),

                      const SizedBox(height: 18),

                      _featureItem(
                        'Priority support',
                      ),

                      const SizedBox(height: 34),

                      // BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style:
                          ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                            const Color(
                              0xFF223B63,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                32,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Upgrade to Pro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          'Secure payment via Stripe. Cancel anytime.',
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                            Color(0xFF5F6677),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // MOST POPULAR BADGE
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF223B63),
                      borderRadius:
                      BorderRadius.only(
                        topRight:
                        Radius.circular(12),
                        bottomLeft:
                        Radius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Most Popular',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String title) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
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