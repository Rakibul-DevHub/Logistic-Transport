import 'package:flutter/material.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String _selectedCategory = 'General Inquiry';

  final List<String> _categories = [
    'General Inquiry',
    'Technical Issue',
    'Account & Billing',
    'Feature Request',
    'Report a Problem',
    'Other',
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I add a new driver?',
      'answer': 'Tap on the Drivers tab from the bottom navigation, then click on the + button to add a new driver. Fill in their details and send an invitation.',
      'expanded': false,
    },
    {
      'question': 'How to upload a BOL or POD document?',
      'answer': 'Go to Load Details, click on Upload BOL or Upload POD button. You can take a photo or select from gallery.',
      'expanded': false,
    },
    {
      'question': 'How to track my loads?',
      'answer': 'All your active loads are visible on the dashboard. Tap on any load to view detailed tracking information and status.',
      'expanded': false,
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can reach us via email at support@logitrack.com or call us at +1 (555) 123-4567. Our support team is available 24/7.',
      'expanded': false,
    },
    {
      'question': 'How to change my password?',
      'answer': 'Go to Account Settings, then Security section. Enter your old password and new password to update.',
      'expanded': false,
    },
    {
      'question': 'What is the refund policy?',
      'answer': 'We offer a 30-day money-back guarantee for all annual subscriptions. Monthly subscriptions can be cancelled anytime.',
      'expanded': false,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleFaq(int index) {
    setState(() {
      _faqs[index]['expanded'] = !_faqs[index]['expanded'];
    });
  }

  void _submitSupportRequest() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _subjectController.clear();
      _messageController.clear();

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF213A63),
                    const Color(0xFF2C4A7A),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'re here to assist you 24/7',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B2235),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Call Support',
                    subtitle: '+1 (555) 123-4567',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      // Launch phone dialer
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    icon: Icons.email_rounded,
                    title: 'Email Us',
                    subtitle: 'support@logitrack.com',
                    color: const Color(0xFF2196F3),
                    onTap: () {
                      // Launch email
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B2235),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Expand all or navigate to full FAQ
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF213A63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // FAQ List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return _buildFaqItem(
                  question: faq['question'],
                  answer: faq['answer'],
                  isExpanded: faq['expanded'],
                  onTap: () => _toggleFaq(index),
                );
              },
            ),
            const SizedBox(height: 24),

            // Contact Form Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE4E7EC),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.message_outlined,
                          color: Color(0xFF213A63),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Send us a message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2235),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE2EB),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF7E8495),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1B2235),
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject Field
                  const Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE2EB),
                      ),
                    ),
                    child: TextField(
                      controller: _subjectController,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B2235),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Brief description of your issue',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A93A5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE2EB),
                      ),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B2235),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A93A5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message Field
                  const Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFDDE2EB),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1B2235),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Please provide details about your issue...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A93A5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  CustomElevatedButton(
                    onPressed: _submitSupportRequest,
                    buttonText: 'Send Message',
                    backgroundColor: const Color(0xFF213A63),
                    foregroundColor: Colors.white,
                    height: 52,
                    borderRadius: BorderRadius.circular(32),
                    isFullWidth: true,
                    hasShadow: false,
                    icon: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send_rounded, size: 20),
                    gap: 8,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B2235),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF73809A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1B2235),
              ),
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF7E8495),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF73809A),
                  height: 1.5,
                ),
              ),
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
              size: 22,
            ),
          ),
        ),
      ),
      title: const Text(
        'Help & Support',
        style: TextStyle(
          color: Color(0xFF161B2F),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}