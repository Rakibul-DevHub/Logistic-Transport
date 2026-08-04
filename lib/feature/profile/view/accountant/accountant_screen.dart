import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tag/feature/profile/view/accountant/cubit/accountant_cubit.dart';
import 'package:tag/feature/profile/view/accountant/model/accountant_data.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';

class SendToAccountantScreen extends StatefulWidget {
  const SendToAccountantScreen({super.key});

  @override
  State<SendToAccountantScreen> createState() =>
      _SendToAccountantScreenState();
}

class _SendToAccountantScreenState extends State<SendToAccountantScreen> {
  bool _isSetupComplete = false;
  String _selectedPeriod = 'month'; // 'month' or 'quarter'
  bool _handledInitialLoad = false;
  bool _accountantDropdownExpanded = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _labelDate = DateFormat('MMM d');

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  ({DateTime from, DateTime to}) _rangeForPeriod(String period) {
    final now = DateTime.now();
    if (period == 'quarter') {
      // Q1: Jan–Mar, Q2: Apr–Jun, Q3: Jul–Sep, Q4: Oct–Dec
      final qStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
      final from = DateTime(now.year, qStartMonth, 1);
      // Last day of the quarter's last month (qStartMonth + 2)
      final to = DateTime(now.year, qStartMonth + 3, 0);
      return (from: from, to: to);
    }
    // This month: 1st → last day of the month
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    return (from: from, to: to);
  }

  String _monthPeriodLabel() {
    final range = _rangeForPeriod('month');
    return '${_labelDate.format(range.from)} - ${_labelDate.format(range.to)}';
  }

  String _quarterPeriodLabel() {
    final now = DateTime.now();
    final q = ((now.month - 1) ~/ 3) + 1;
    const names = {
      1: 'January – March',
      2: 'April – June',
      3: 'July – September',
      4: 'October – December',
    };
    return 'Q$q: ${names[q]}';
  }

  Future<void> _saveInfo(AccountantCubit cubit) async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter accountant email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final ok = await cubit.addAccountant(name: name, email: email);
    if (!mounted) return;
    if (ok) {
      setState(() => _isSetupComplete = true);
    }
  }

  Future<void> _handleSendBundle(AccountantCubit cubit) async {
    final range = _rangeForPeriod(_selectedPeriod);
    final result = await cubit.sendReport(
      fromDate: _apiDate.format(range.from),
      toDate: _apiDate.format(range.to),
    );
    if (!mounted || !result.ok) return;

    showDialog(
      context: context,
      barrierDismissible: false,
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
        content: Text(
          result.sentTo != null && result.sentTo!.isNotEmpty
              ? '${result.message}\n\nSent to: ${result.sentTo}'
              : result.message,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF5F6980),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // close popup
              if (context.mounted) {
                Navigator.pop(context); // back to Profile (bottom nav)
              }
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

  Future<void> _handleRemoveAccountant(AccountantCubit cubit) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Remove Accountant?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF161B2F),
          ),
        ),
        content: const Text(
          'This will remove the saved accountant. You will need to set up a new one before sending reports.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF5F6980),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF73809A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Remove'),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final ok = await cubit.removeAccountant();
    if (!mounted || !ok) return;

    _emailController.clear();
    _nameController.clear();
    setState(() {
      _isSetupComplete = false;
      _accountantDropdownExpanded = false;
    });
  }

  void _applyLoadedAccountant(AccountantData data) {
    _emailController.text = data.value.email;
    _nameController.text = data.value.name;
    if (!_isSetupComplete) {
      setState(() => _isSetupComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AccountantCubit()..getAccountant(),
      child: BlocConsumer<AccountantCubit, AccountantState>(
        listener: (context, state) {
          if (state is AccountantLoaded && !_handledInitialLoad) {
            _handledInitialLoad = true;
            _applyLoadedAccountant(state.data);
          } else if (state is AccountantEmpty && !_handledInitialLoad) {
            _handledInitialLoad = true;
            setState(() => _isSetupComplete = false);
          } else if (state is AccountantLoaded &&
              state.data.value.email.isNotEmpty &&
              _emailController.text.trim().isEmpty) {
            _applyLoadedAccountant(state.data);
          } else if (state is AccountantEmpty && _handledInitialLoad) {
            // After remove → back to setup
            if (_isSetupComplete) {
              setState(() => _isSetupComplete = false);
            }
          }

          if (state is AccountantFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
            if (state.data != null && state.data!.value.email.isNotEmpty) {
              setState(() => _isSetupComplete = true);
            }
          }
        },
        builder: (context, state) {
          final cubit = context.read<AccountantCubit>();
          final isBootLoading =
              state is AccountantLoading || state is AccountantInitial;
          final isSaving = state is AccountantSaving;
          final isSending = state is AccountantSending;
          final isRemoving = state is AccountantRemoving;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F5F7),
            appBar: _buildAppBar(),
            body: isBootLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF213A63),
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _isSetupComplete
                        ? _buildReportingView(
                            cubit: cubit,
                            isSending: isSending,
                            isRemoving: isRemoving,
                            accountant: _currentAccountant(state),
                          )
                        : _buildSetupView(
                            cubit: cubit,
                            isSaving: isSaving,
                          ),
                  ),
          );
        },
      ),
    );
  }

  AccountantData? _currentAccountant(AccountantState state) {
    if (state is AccountantLoaded) return state.data;
    if (state is AccountantSending) return state.data;
    if (state is AccountantRemoving) return state.data;
    if (state is AccountantFailure) return state.data;
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // VIEW 1: ACCOUNTANT SETUP
  // ─────────────────────────────────────────────────────────────
  Widget _buildSetupView({
    required AccountantCubit cubit,
    required bool isSaving,
  }) {
    return SingleChildScrollView(
      key: const ValueKey('setup_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
                const Text(
                  'Accountant Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _emailController,
                  hint: 'e.g. finance@firm.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isSaving,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Accountant Name (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1B2235),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Full name or firm name',
                  icon: Icons.person_outline_rounded,
                  enabled: !isSaving,
                ),
                const SizedBox(height: 34),
                CustomElevatedButton(
                  onPressed: isSaving ? null : () => _saveInfo(cubit),
                  buttonText: isSaving ? 'Saving...' : 'Save Info.',
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
  // VIEW 2: FINANCIAL REPORTING
  // ─────────────────────────────────────────────────────────────
  Widget _buildReportingView({
    required AccountantCubit cubit,
    required bool isSending,
    required bool isRemoving,
    AccountantData? accountant,
  }) {
    final range = _rangeForPeriod(_selectedPeriod);
    final rangeLabel =
        '${_labelDate.format(range.from)} - ${_labelDate.format(range.to)}, ${range.to.year}';
    final email = accountant?.value.email.isNotEmpty == true
        ? accountant!.value.email
        : _emailController.text.trim();
    final name = accountant?.value.name.isNotEmpty == true
        ? accountant!.value.name
        : _nameController.text.trim();
    final busy = isSending || isRemoving;

    return SingleChildScrollView(
      key: const ValueKey('reporting_view'),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 20),

          // Saved accountant dropdown (shown only when setup exists)
          _buildAccountantDropdown(
            cubit: cubit,
            name: name,
            email: email,
            isRemoving: isRemoving,
            enabled: !busy,
          ),
          const SizedBox(height: 16),

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
                    Expanded(
                      child: GestureDetector(
                        onTap: busy
                            ? null
                            : () =>
                                setState(() => _selectedPeriod = 'month'),
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
                                _monthPeriodLabel(),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: busy
                            ? null
                            : () =>
                                setState(() => _selectedPeriod = 'quarter'),
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
                                _quarterPeriodLabel(),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5FB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.date_range_rounded,
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
                            'Report Period',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF73809A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rangeLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF161B2F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Documents Included',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF73809A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'BOL, POD, Expenses',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF161B2F),
                            ),
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
          CustomElevatedButton(
            onPressed: busy ? null : () => _handleSendBundle(cubit),
            buttonText:
                isSending ? 'Sending...' : 'Send Bundle to Accountant',
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

  Widget _buildAccountantDropdown({
    required AccountantCubit cubit,
    required String name,
    required String email,
    required bool isRemoving,
    required bool enabled,
  }) {
    final title = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Accountant');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: enabled
                ? () => setState(
                      () => _accountantDropdownExpanded =
                          !_accountantDropdownExpanded,
                    )
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF213A63),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved Accountant',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF73809A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B2235),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (name.isNotEmpty && email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF73809A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _accountantDropdownExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF7E8495),
                  ),
                ],
              ),
            ),
          ),
          if (_accountantDropdownExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE4E7EC)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF73809A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.isNotEmpty ? name : '—',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF73809A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isNotEmpty ? email : '—',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1B2235),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: enabled
                          ? () => _handleRemoveAccountant(cubit)
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: isRemoving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(
                        isRemoving ? 'Removing...' : 'Remove Accountant',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    bool enabled = true,
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
        enabled: enabled,
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
          onTap: () => Navigator.pop(context),
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
