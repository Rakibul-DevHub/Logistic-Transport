
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_url.dart';
import '../../../../shared/components/Custom_Elevated_Button.dart';
import 'cubit/account_settings_cubit.dart';
import 'model/account_settings_data.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});

  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  // Password visibility states
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // User data
  UserData? _userData;

  // Store selected image file locally (not uploaded yet)
  File? _selectedImageFile;
  String? _selectedImagePath;

  // Tracks whether the next AccountSettingsSuccess is from an actual save
  bool _isSavingAction = false;

  // Delete account confirmation text controller
  final TextEditingController _deleteConfirmationController =
  TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deleteConfirmationController.dispose();
    super.dispose();
  }

  void _updateUserData(UserData userData) {
    setState(() {
      _userData = userData;
      _fullNameController.text = userData.name;
      _phoneNumberController.text = userData.phone;
      _selectedImageFile = null;
      _selectedImagePath = null;
    });
  }

  // Just pick the image, don't upload yet
  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _selectedImagePath = pickedFile.path;
        });

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Save changes - handles both profile update and image upload
  void _saveChanges(BuildContext context) {
    // Check if password fields are being changed
    final bool isChangingPassword = _oldPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;

    if (isChangingPassword) {
      _handleChangePassword(context);
      return;
    }

    _performSave(context);
  }

  // Perform the actual save (profile update with or without image)
  void _performSave(BuildContext context) async {
    _isSavingAction = true;
    final cubit = context.read<AccountSettingsCubit>();

    // If there's a selected image, upload it first
    if (_selectedImageFile != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Uploading image...'),
          backgroundColor: Colors.blue,
        ),
      );

      final filename = await cubit.uploadImage(_selectedImageFile!);

      if (filename != null) {
        cubit.updateUserProfile(
          name: _fullNameController.text.trim(),
          phone: _phoneNumberController.text.trim(),
          address: _userData?.address ?? '',
          profileImage: filename,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        _isSavingAction = false;
      }
    } else {
      cubit.updateUserProfile(
        name: _fullNameController.text.trim(),
        phone: _phoneNumberController.text.trim(),
        address: _userData?.address ?? '',
        profileImage: _userData?.profileImage ?? '',
      );
    }
  }

  void _handleChangePassword(BuildContext context) {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate old password
    if (oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your current password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate new password (6-8 characters)
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be less than 8 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must contain at least one uppercase letter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must contain at least one number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\]\\/;]').hasMatch(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must contain at least one special character'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm your new password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call API to change password
    _isSavingAction = true;
    final cubit = context.read<AccountSettingsCubit>();
    cubit.changePassword(
      currentPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }

  // ✅ Delete Account with confirmation - Fixed context issue
  void _showDeleteAccountDialog(BuildContext context) {
    // ✅ Capture the correct context that has access to the cubit
    final scaffoldContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleteEnabled = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Are you sure you want to delete your account?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This action cannot be undone. All your data will be permanently removed.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Type "DELETE ACCOUNT" to confirm:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _deleteConfirmationController,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                          decoration: InputDecoration(
                            hintText: 'DELETE ACCOUNT',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            final trimmedValue = value.trim();
                            // ✅ Case sensitive - must be exactly "DELETE ACCOUNT"
                            final isMatch = trimmedValue == 'DELETE ACCOUNT';
                            setState(() {
                              isDeleteEnabled = isMatch && trimmedValue.isNotEmpty;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _deleteConfirmationController.clear();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDeleteEnabled ? Colors.red : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  onPressed: isDeleteEnabled
                      ? () {
                    // Close dialog
                    Navigator.pop(dialogContext);
                    // ✅ Use the captured scaffoldContext to call delete
                    _deleteAccount(scaffoldContext);
                  }
                      : null,
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
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

  // Delete Account API call
  void _deleteAccount(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting account...'),
          backgroundColor: Colors.blue,
        ),
      );

      final cubit = context.read<AccountSettingsCubit>();
      final success = await cubit.deleteAccount();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
                (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccountSettingsCubit()..getUserProfile(),
      child: BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
        listener: (context, state) {
          if (state is AccountSettingsSuccess) {
            _updateUserData(state.userData);

            if (!_isSavingAction) {
              return;
            }
            _isSavingAction = false;

            // Show appropriate success message
            if (_oldPasswordController.text.isNotEmpty ||
                _newPasswordController.text.isNotEmpty ||
                _confirmPasswordController.text.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              _oldPasswordController.clear();
              _newPasswordController.clear();
              _confirmPasswordController.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is AccountSettingsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AccountSettingsLoading;

          if (state is AccountSettingsLoading && _userData == null) {
            return const Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: _buildAppBar(context),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(context),
                        const SizedBox(height: 24),
                        _buildEditProfileSection(),
                        const SizedBox(height: 24),
                        _buildSecuritySection(),
                        const SizedBox(height: 32),
                        CustomElevatedButton(
                          onPressed: isLoading ? null : () => _saveChanges(context),
                          buttonText: isLoading ? 'Saving...' : 'Save changes',
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.whiteColor,
                          height: 48,
                          borderRadius: BorderRadius.circular(30),
                          isFullWidth: true,
                          hasShadow: false,
                          icon: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.save, size: 20),
                          gap: 8,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 14),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: SvgPicture.asset('assets/icons/back_button_with_circle.svg'),
        ),
      ),
      title: const Text(
        'Account Setting',
        style: TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14.0),
          child: PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteAccountDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: _selectedImageFile != null
                        ? Image.file(
                      _selectedImageFile!,
                      fit: BoxFit.cover,
                    )
                        : _userData?.profileImage != null &&
                        _userData!.profileImage.isNotEmpty &&
                        _userData!.profileImage != 'users/user.png'
                        ? Image.network(
                      '${AppUrl.imageBaseUrl}/${_userData!.profileImage}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _userData?.initials ?? '',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Text(
                        _userData?.initials ?? '',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: SvgPicture.asset(
                    'assets/icons/edit_profile_image.svg',
                    width: 30,
                    height: 30,
                  ),
                ),
                if (_selectedImageFile != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_file,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData?.name ?? 'Loading...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData?.email ?? 'Loading...',
            style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 8),
          if (_userData != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _userData?.role.toUpperCase() ?? '',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Full Name Field
          _buildTextField(
            label: 'FULL NAME',
            controller: _fullNameController,
            hint: 'Enter your full name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          // Phone Number Field
          _buildTextField(
            label: 'PHONE NUMBER',
            controller: _phoneNumberController,
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Security',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Password Requirements Info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Password must be 6-8 characters, with at least 1 '
                        'uppercase letter, 1 number, and 1 special character (e.g. Pass@123)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Old Password Field
          _buildPasswordField(
            label: 'OLD PASSWORD',
            controller: _oldPasswordController,
            obscureText: _obscureOldPassword,
            onToggle: () {
              setState(() {
                _obscureOldPassword = !_obscureOldPassword;
              });
            },
          ),
          const SizedBox(height: 16),
          // New Password Field
          _buildPasswordField(
            label: 'NEW PASSWORD',
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            onToggle: () {
              setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              });
            },
          ),
          const SizedBox(height: 16),
          // Confirm New Password Field
          _buildPasswordField(
            label: 'CONFIRM NEW PASSWORD',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onToggle: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8ED), width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              prefixIcon: Icon(icon, size: 20, color: const Color(0xFF888888)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E8ED), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFB0B0B0),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                size: 20,
                color: Color(0xFF888888),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: const Color(0xFF888888),
                ),
                onPressed: onToggle,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}






///
///
///
///
/// todo:: separating the sections
///
///
///
///








