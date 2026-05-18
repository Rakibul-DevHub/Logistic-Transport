
import 'package:flutter/material.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

class SendToAccountantScreen extends StatefulWidget {
  const SendToAccountantScreen({super.key});

  @override
  State<SendToAccountantScreen> createState() =>
      _SendToAccountantScreenState();
}

class _SendToAccountantScreenState
    extends State<SendToAccountantScreen> {
  // State for view switching
  bool _isSetupComplete = false;
  String _selectedPeriod = 'month'; // 'month' or 'quarter'

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveInfo() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter accountant email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Transition to Financial Reporting view
    setState(() => _isSetupComplete = true);
  }

  void _handleSendBundle() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            const Text(
              'Bundle Sent!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF161B2F),
              ),
            ),
          ],
        ),
        content: const Text(
          'The financial documents have been successfully emailed to your registered accountant.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF5F6980),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Reset to setup view
              setState(() {
                _isSetupComplete = false;
                _emailController.clear();
                _nameController.clear();
                _selectedPeriod = 'month';
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF213A63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isSetupComplete
            ? _buildReportingView()
            : _buildSetupView(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VIEW 1: ACCOUNTANT SETUP (Original Design)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSetupView() {
    return SingleChildScrollView(
      key: const ValueKey('setup_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // HEADER
          const Text(
            'Accountant Setup',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF161B2F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Configure your financial reporting destination.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF73809A),
            ),
          ),
          const SizedBox(height: 24),

          // MAIN CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
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
                // INFO BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF263B63),
                            width: 1.6,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.info_outline,
                            size: 22,
                            color: Color(0xFF263B63),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'This email will be used to bundle\n'
                              'and send your delivery documents,\n'
                              'fuel receipts, and route manifests\n'
                              'directly for tax preparation.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF5F6980),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // EMAIL LABEL
                const Text(
                  'Accountant Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),

                // EMAIL FIELD
                _buildTextField(
                  controller: _emailController,
                  hint: 'e.g. finance@firm.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 22),

                // NAME LABEL
                const Text(
                  'Accountant Name (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),

                // NAME FIELD
                _buildTextField(
                  controller: _nameController,
                  hint: 'Full name or firm name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 34),

                // BUTTON
                CustomElevatedButton(
                  onPressed: _saveInfo,
                  buttonText: 'Save Info.',
                  backgroundColor: const Color(0xFF213A63),
                  foregroundColor: Colors.white,
                  height: 56,
                  borderRadius: BorderRadius.circular(32),
                  isFullWidth: true,
                  hasShadow: false,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          const SizedBox(height: 38),

          // SECURE TRANSFER CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 24,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FB),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE4E7EC),
              ),
            ),
            child: Column(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF155EEF),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF155EEF),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Secure Transfer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'End-to-end encrypted document delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B8499),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VIEW 2: FINANCIAL REPORTING & BUNDLE SUMMARY
  // ─────────────────────────────────────────────────────────────
  Widget _buildReportingView() {
    return SingleChildScrollView(
      key: const ValueKey('reporting_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // HEADER
          const Text(
            'Financial Reporting',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF161B2F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select the reporting period to bundle all legal and expense documents for your accountant.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF73809A),
            ),
          ),
          const SizedBox(height: 24),

          // FINANCIAL REPORTING CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
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
                // Period Selection Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Color(0xFF213A63),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Financial Reporting',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2235),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select period to bundle documents',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF73809A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Period Selection Buttons
                const Text(
                  'Select Period',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // This Month
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = 'month'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == 'month'
                                ? const Color(0xFFE8F0FE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPeriod == 'month'
                                  ? const Color(0xFF213A63)
                                  : const Color(0xFFE4E7EC),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: _selectedPeriod == 'month'
                                    ? const Color(0xFF213A63)
                                    : const Color(0xFF7E8495),
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This Month',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedPeriod == 'month'
                                      ? const Color(0xFF213A63)
                                      : const Color(0xFF1B2235),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Oct 1 - Present',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _selectedPeriod == 'month'
                                      ? const Color(0xFF213A63)
                                      : const Color(0xFF73809A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // This Quarter
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPeriod = 'quarter'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedPeriod == 'quarter'
                                ? const Color(0xFFE8F0FE)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPeriod == 'quarter'
                                  ? const Color(0xFF213A63)
                                  : const Color(0xFFE4E7EC),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: _selectedPeriod == 'quarter'
                                    ? const Color(0xFF213A63)
                                    : const Color(0xFF7E8495),
                                size: 24,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This Quarter',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedPeriod == 'quarter'
                                      ? const Color(0xFF213A63)
                                      : const Color(0xFF1B2235),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Q4: Oct - Dec',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _selectedPeriod == 'quarter'
                                      ? const Color(0xFF213A63)
                                      : const Color(0xFF73809A),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // BUNDLE SUMMARY CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
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
                const Text(
                  'Bundle Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 16),

                // Total Loads Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF213A63),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Loads',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF73809A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '12',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF161B2F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Total Documents Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_rounded,
                        color: Color(0xFF213A63),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Documents',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF73809A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              const Text(
                                '36',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF161B2F),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(BOL, POD, Expenses)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF73809A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildDocTag('BOL'),
                        const SizedBox(height: 4),
                        _buildDocTag('POD'),
                        const SizedBox(height: 4),
                        _buildDocTag('Expenses'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // INFO BOX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF213A63),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'A PDF bundle will be generated and emailed directly to your registered accountant upon clicking send.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6980),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // SEND BUTTON
          CustomElevatedButton(
            onPressed: _handleSendBundle,
            buttonText: 'Send Bundle to Accountant',
            backgroundColor: const Color(0xFF213A63),
            foregroundColor: Colors.white,
            height: 56,
            borderRadius: BorderRadius.circular(32),
            isFullWidth: true,
            hasShadow: false,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDocTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFDDE2EB),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5F6980),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDDE2EB),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1B2235),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF7E8495),
            size: 22,
          ),
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF8A93A5),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
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
          onTap: () {
            if (_isSetupComplete) {
              setState(() => _isSetupComplete = false);
            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            height: 42,
            width: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSetupComplete ? Icons.close_rounded : Icons.arrow_back_rounded,
              color: const Color(0xFF1B2235),
              size: 22,
            ),
          ),
        ),
      ),
      title: const Text(
        'Send to Accountant',
        style: TextStyle(
          color: Color(0xFF161B2F),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}