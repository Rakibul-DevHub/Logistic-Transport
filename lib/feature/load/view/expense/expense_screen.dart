import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/theme/app_text_style.dart';
import 'package:tag/shared/components/Custom_Elevated_Button.dart';

import 'controller/add_load_expense_cubit.dart';
import 'model/load_expense_data.dart';

class ExpenseScreen extends StatelessWidget {
  final ExpenseScreenArgs args;

  const ExpenseScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddLoadExpenseCubit(),
      child: _ExpenseView(args: args),
    );
  }
}

class _ExpenseView extends StatefulWidget {
  final ExpenseScreenArgs args;

  const _ExpenseView({required this.args});

  @override
  State<_ExpenseView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<_ExpenseView> {
  String _selectedExpenseType = 'Fuel';

  final TextEditingController _amountController =
  TextEditingController();
  final TextEditingController _notesController =
  TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  DateTime _selectedDate = DateTime.now();
  File? _receiptFile;

  static const List<String> _expenseTypes = [
    'Fuel',
    'Toll',
    'Maintenance',
    'Repair',
    'Food',
    'Accommodation',
    'Other',
  ];

  static const Color primaryDark = Color(0xFF1F3555);
  static const Color screenBg = Color(0xFFE7ECF2);
  static const Color fieldFill = Color(0xFFF3F3F3);
  static const Color labelGray = Color(0xFF95A0AF);
  static const Color textDark = Color(0xFF1F3555);
  static const Color receiptBorder = Color(0xFFD1D9E6);
  static const Color receiptFill = Color(0xFFEDF0F5);

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryDark,
              onPrimary: Colors.white,
              onSurface: primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickReceipt() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt_outlined,
                      color: primaryDark,
                    ),
                    title: const Text('Take a photo'),
                    onTap: () {
                      Navigator.pop(
                        context,
                        ImageSource.camera,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: primaryDark,
                    ),
                    title: const Text('Choose from gallery'),
                    onTap: () {
                      Navigator.pop(
                        context,
                        ImageSource.gallery,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) return;

      final pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (pickedImage == null || !mounted) return;

      setState(() {
        _receiptFile = File(pickedImage.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select receipt: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeReceipt() {
    setState(() => _receiptFile = null);
  }

  void _saveExpense() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (widget.args.loadMongoId.trim().isEmpty) {
      _showError('Load ID is missing');
      return;
    }

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    final apiDate = DateFormat(
      'yyyy-MM-dd',
    ).format(_selectedDate);

    context.read<AddLoadExpenseCubit>().createExpense(
      loadId: widget.args.loadMongoId,
      type: _selectedExpenseType,
      amount: amount,
      date: apiDate,
      receiptFile: _receiptFile,
      notes: _notesController.text,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String get _receiptName {
    final file = _receiptFile;
    if (file == null) return '';

    return file.path
        .split(Platform.pathSeparator)
        .last;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
        AddLoadExpenseCubit,
        AddLoadExpenseState>(
      listener: (context, state) {
        if (state is AddLoadExpenseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is AddLoadExpenseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context, state.data);
        }
      },
      builder: (context, state) {
        final isLoading =
        state is AddLoadExpenseLoading;

        return Scaffold(
          backgroundColor: screenBg,
          appBar: _buildAppBar(isLoading),
          body: AbsorbPointer(
            absorbing: isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildCurrentTripCard(),
                  const SizedBox(height: 24),
                  _buildExpenseTypeSection(),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildAmountSection(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateSection(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildReceiptUploadSection(),
                  const SizedBox(height: 24),
                  _buildNotesSection(),
                  const SizedBox(height: 32),
                  _buildSaveButton(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(bool isLoading) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed:
        isLoading ? null : () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back,
          color: primaryDark,
        ),
      ),
      title: const Text(
        'Add Expense',
        style: TextStyle(
          color: primaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildCurrentTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'CURRENT TRIP\n',
                  style: AppTextStyle.SFProDisplay_White,
                ),
                TextSpan(
                  text: 'Id #${widget.args.displayLoadId}',
                  style:
                  AppTextStyle.SFProDisplay_White.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Expenses for this route',
            style: TextStyle(
              color: Color(0xFFACBCD3),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${widget.args.totalExpenses.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expense Type',
          style: TextStyle(
            color: labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedExpenseType,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: labelGray,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
              dropdownColor: Colors.white,
              items: _expenseTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedExpenseType = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: labelGray,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 16,
                    color: textDark,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            color: labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: fieldFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat(
                      'MM/dd/yyyy',
                    ).format(_selectedDate),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  color: labelGray,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Receipt',
          style: TextStyle(
            color: labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickReceipt,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: receiptFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _receiptFile == null
                    ? receiptBorder
                    : Colors.green,
                width: 1.5,
              ),
            ),
            child: _receiptFile == null
                ? const Column(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFDDE3ED),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF7A8BA0),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Snap a photo or choose from gallery',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: labelGray,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'JPG or PNG up to 10MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB0B8C4),
                  ),
                ),
              ],
            )
                : Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _receiptName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _removeReceipt,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            color: labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: fieldFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 14,
              color: textDark,
            ),
            decoration: const InputDecoration(
              hintText:
              'Add details about this expense...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(
      AddLoadExpenseState state,
      ) {
    final isLoading =
    state is AddLoadExpenseLoading;

    final buttonText = state is AddLoadExpenseLoading
        ? state.message
        : 'Save Expense';

    return CustomElevatedButton(
      onPressed: isLoading ? null : _saveExpense,
      buttonText: buttonText,
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      disabledBackgroundColor:
      primaryDark.withOpacity(0.6),
      width: double.infinity,
      height: 56,
      elevation: 0,
      padding:
      const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(30),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      isFullWidth: true,
      hasShadow: false,
    );
  }
}