/**
    import 'package:flutter/cupertino.dart';
    import 'package:flutter_bloc/flutter_bloc.dart';
    import 'package:equatable/equatable.dart';
    import 'package:tag/core/network/network_caller_dio.dart';
    import 'package:tag/core/network/secure_storage_service.dart';
    import 'package:tag/core/utils/app_url.dart';
    import '../model/account_settings_data.dart';

    // ==================== STATES ====================
    abstract class AccountSettingsState extends Equatable {
    const AccountSettingsState();

    @override
    List<Object?> get props => [];
    }

    class AccountSettingsInitial extends AccountSettingsState {}

    class AccountSettingsLoading extends AccountSettingsState {}

    class AccountSettingsSuccess extends AccountSettingsState {
    final UserData userData;

    const AccountSettingsSuccess({required this.userData});

    @override
    List<Object?> get props => [userData];
    }

    class AccountSettingsFailure extends AccountSettingsState {
    final String errorMessage;

    const AccountSettingsFailure({required this.errorMessage});

    @override
    List<Object?> get props => [errorMessage];
    }

    // ==================== CUBIT ====================
    class AccountSettingsCubit extends Cubit<AccountSettingsState> {
    final NetworkCallerDio _networkCaller = NetworkCallerDio();
    final SecureStorageService _storage = SecureStorageService.instance;

    AccountSettingsCubit() : super(AccountSettingsInitial());

    Future<void> getUserProfile() async {
    try {
    emit(AccountSettingsLoading());

    final accessToken = await _storage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
    emit(const AccountSettingsFailure(
    errorMessage: 'Please login again',
    ));
    return;
    }

    debugPrint('🔑 Access Token: $accessToken');
    debugPrint('🌐 Fetching user profile from: ${AppUrl.userProfile}');

    final response = await _networkCaller.getRequest(
    AppUrl.userProfile,
    headers: {
    'Authorization': 'Bearer $accessToken',
    },
    );

    debugPrint('📡 Response Status: ${response.statusCode}');
    debugPrint('📡 Response Body: ${response.jsonResponse}');

    if (response.isSuccess) {
    final userProfile = AccountSettingResponse.fromJson(
    response.jsonResponse ?? {},
    );

    if (userProfile.data != null) {
    debugPrint('✅ User Data: ${userProfile.data!.name}');
    debugPrint('✅ User Email: ${userProfile.data!.email}');
    emit(AccountSettingsSuccess(userData: userProfile.data!));
    } else {
    debugPrint('❌ No user data in response');
    emit(const AccountSettingsFailure(
    errorMessage: 'Invalid response from server',
    ));
    }
    } else {
    String errorMsg = response.errorMessage ?? 'Failed to load profile';
    if (response.jsonResponse != null) {
    errorMsg = response.jsonResponse?['message'] ??
    response.jsonResponse?['error'] ??
    errorMsg;
    }

    debugPrint('❌ Error: $errorMsg');
    emit(AccountSettingsFailure(errorMessage: errorMsg));
    }
    } catch (e) {
    debugPrint('❌ Exception: $e');
    emit(AccountSettingsFailure(
    errorMessage: 'An error occurred: ${e.toString()}',
    ));
    }
    }

    Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
    }) async {
    try {
    emit(AccountSettingsLoading());

    final accessToken = await _storage.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
    emit(const AccountSettingsFailure(
    errorMessage: 'Please login again',
    ));
    return;
    }

    final Map<String, dynamic> requestBody = {
    'currentPassword': currentPassword,
    'password': newPassword,
    'confirmPassword': confirmPassword,
    };

    debugPrint('🌐 Changing password...');

    final response = await _networkCaller.postRequest(
    AppUrl.changePassword,
    body: requestBody,
    headers: {
    'Authorization': 'Bearer $accessToken',
    },
    );

    debugPrint('📡 Change Password Response Status: ${response.statusCode}');
    debugPrint('📡 Change Password Response Body: ${response.jsonResponse}');

    if (response.isSuccess) {
    debugPrint('✅ Password changed successfully');

    // The change-password response already returns the updated user
    // object under `data`, so use it directly instead of firing a
    // second request via getUserProfile().
    final userDataJson = response.jsonResponse?['data'];
    if (userDataJson != null) {
    final userData = UserData.fromJson(userDataJson);
    emit(AccountSettingsSuccess(userData: userData));
    } else {
    // Fallback: response didn't include user data for some reason —
    // fetch it separately so the UI still has something to show.
    debugPrint('⚠️ No user data in change-password response, '
    'falling back to getUserProfile()');
    await getUserProfile();
    }
    } else {
    String errorMsg = response.errorMessage ?? 'Failed to change password';
    if (response.jsonResponse != null) {
    errorMsg = response.jsonResponse?['message'] ??
    response.jsonResponse?['error'] ??
    errorMsg;
    }

    debugPrint('❌ Password change failed: $errorMsg');
    emit(AccountSettingsFailure(errorMessage: errorMsg));
    }
    } catch (e) {
    debugPrint('❌ Exception: $e');
    emit(AccountSettingsFailure(
    errorMessage: 'An error occurred: ${e.toString()}',
    ));
    }
    }

    void resetState() {
    emit(AccountSettingsInitial());
    }
    }*/

///
///
///
/// todo: updating
///
///
///

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:tag/core/network/network_caller_dio.dart';
// import 'package:tag/core/network/secure_storage_service.dart';
// import 'package:tag/core/utils/app_url.dart';
// import '../model/account_settings_data.dart';
// import 'dart:io';
//
// // lib/feature/profile/view/account_settings/cubit/account_settings_cubit.dart
//
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:tag/core/network/network_caller_dio.dart';
// import 'package:tag/core/network/secure_storage_service.dart';
// import 'package:tag/core/utils/app_url.dart';
// import '../model/account_settings_data.dart';
//
// // ==================== STATES ====================
// abstract class AccountSettingsState extends Equatable {
//   const AccountSettingsState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class AccountSettingsInitial extends AccountSettingsState {}
//
// class AccountSettingsLoading extends AccountSettingsState {}
//
// class AccountSettingsSuccess extends AccountSettingsState {
//   final UserData userData;
//
//   const AccountSettingsSuccess({required this.userData});
//
//   @override
//   List<Object?> get props => [userData];
// }
//
// class AccountSettingsFailure extends AccountSettingsState {
//   final String errorMessage;
//
//   const AccountSettingsFailure({required this.errorMessage});
//
//   @override
//   List<Object?> get props => [errorMessage];
// }
//
// // ==================== CUBIT ====================
// class AccountSettingsCubit extends Cubit<AccountSettingsState> {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//   final SecureStorageService _storage = SecureStorageService.instance;
//
//   AccountSettingsCubit() : super(AccountSettingsInitial());
//
//   Future<void> getUserProfile() async {
//     try {
//       emit(AccountSettingsLoading());
//
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         emit(const AccountSettingsFailure(errorMessage: 'Please login again'));
//         return;
//       }
//
//       debugPrint('🔑 Access Token: $accessToken');
//       debugPrint('🌐 Fetching user profile from: ${AppUrl.userProfile}');
//
//       final response = await _networkCaller.getRequest(
//         AppUrl.userProfile,
//         headers: {'Authorization': 'Bearer $accessToken'},
//       );
//
//       debugPrint('📡 Response Status: ${response.statusCode}');
//       debugPrint('📡 Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         final userProfile = AccountSettingResponse.fromJson(
//           response.jsonResponse ?? {},
//         );
//
//         if (userProfile.data != null) {
//           debugPrint('✅ User Data: ${userProfile.data!.name}');
//           debugPrint('✅ User Email: ${userProfile.data!.email}');
//           emit(AccountSettingsSuccess(userData: userProfile.data!));
//         } else {
//           debugPrint('❌ No user data in response');
//           emit(
//             const AccountSettingsFailure(
//               errorMessage: 'Invalid response from server',
//             ),
//           );
//         }
//       } else {
//         String errorMsg = response.errorMessage ?? 'Failed to load profile';
//         if (response.jsonResponse != null) {
//           errorMsg =
//               response.jsonResponse?['message'] ??
//               response.jsonResponse?['error'] ??
//               errorMsg;
//         }
//
//         debugPrint('❌ Error: $errorMsg');
//         emit(AccountSettingsFailure(errorMessage: errorMsg));
//       }
//     } catch (e) {
//       debugPrint('❌ Exception: $e');
//       emit(
//         AccountSettingsFailure(
//           errorMessage: 'An error occurred: ${e.toString()}',
//         ),
//       );
//     }
//   }
//
//   ///============= Upload image - Now uses POST method
//   Future<String?> uploadImage(File imageFile) async {
//     try {
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         debugPrint('❌ No access token found');
//         return null;
//       }
//
//       debugPrint('📤 Uploading image: ${imageFile.path}');
//       debugPrint('📤 File size: ${await imageFile.length()} bytes');
//
//       // ✅ Pass method: 'POST' for image upload
//       final response = await _networkCaller.uploadImage(
//         AppUrl.singleImageUpload,
//         imageFile: imageFile,
//         headers: {'Authorization': 'Bearer $accessToken'},
//         fileFieldName: 'file',
//         method: 'POST', // ✅ Specify POST method
//       );
//
//       debugPrint('📡 Upload Response Status: ${response.statusCode}');
//       debugPrint('📡 Upload Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         final filename = response.jsonResponse?['data']?['filename'];
//         debugPrint('✅ Upload successful: $filename');
//         return filename;
//       } else {
//         debugPrint('❌ Upload failed: ${response.errorMessage}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('❌ Upload error: $e');
//       return null;
//     }
//   }
//
//
//
//
//   ///=================== Update user profile - FIXED
//   Future<void> updateUserProfile({
//     required String name,
//     required String phone,
//     required String address,
//     required String profileImage,
//   }) async
//   {
//     try {
//       emit(AccountSettingsLoading());
//
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         emit(const AccountSettingsFailure(errorMessage: 'Please login again'));
//         return;
//       }
//
//       final Map<String, dynamic> requestBody = {
//         'name': name,
//         'phone': phone,
//         'address': address,
//         'profileImage': profileImage,
//       };
//
//       debugPrint('🌐 Updating user profile...');
//       debugPrint('📦 Body: $requestBody');
//
//       final response = await _networkCaller.putRequest(
//         AppUrl.userProfileUpdate,
//         body: requestBody,
//         headers: {'Authorization': 'Bearer $accessToken'},
//       );
//
//       debugPrint('📡 Update Response Status: ${response.statusCode}');
//       debugPrint('📡 Update Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         final userDataJson = response.jsonResponse?['data'];
//         if (userDataJson != null) {
//           final userData = UserData.fromJson(userDataJson);
//           emit(AccountSettingsSuccess(userData: userData));
//         } else {
//           await getUserProfile();
//         }
//       } else {
//         String errorMsg = response.errorMessage ?? 'Failed to update profile';
//         if (response.jsonResponse != null) {
//           errorMsg =
//               response.jsonResponse?['message'] ??
//               response.jsonResponse?['error'] ??
//               errorMsg;
//         }
//
//         debugPrint('❌ Update failed: $errorMsg');
//         emit(AccountSettingsFailure(errorMessage: errorMsg));
//       }
//     } catch (e) {
//       debugPrint('❌ Exception: $e');
//       emit(
//         AccountSettingsFailure(
//           errorMessage: 'An error occurred: ${e.toString()}',
//         ),
//       );
//     }
//   }
//
//
//
//   ///========================= delete account
//
//   Future<bool> deleteAccount() async {
//     try {
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         return false;
//       }
//
//       final response = await _networkCaller.deleteRequest(
//         AppUrl.deleteUserAccount,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       if (response.isSuccess) {
//         // Clear all stored tokens
//         await _storage.deleteAllTokens();
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       debugPrint('❌ Delete account error: $e');
//       return false;
//     }
//   }
//
//   Future<void> changePassword({
//     required String currentPassword,
//     required String newPassword,
//     required String confirmPassword,
//   }) async {
//     try {
//       emit(AccountSettingsLoading());
//
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         emit(const AccountSettingsFailure(errorMessage: 'Please login again'));
//         return;
//       }
//
//       final Map<String, dynamic> requestBody = {
//         'currentPassword': currentPassword,
//         'password': newPassword,
//         'confirmPassword': confirmPassword,
//       };
//
//       debugPrint('🌐 Changing password...');
//
//       final response = await _networkCaller.postRequest(
//         AppUrl.changePassword,
//         body: requestBody,
//         headers: {'Authorization': 'Bearer $accessToken'},
//       );
//
//       debugPrint('📡 Change Password Response Status: ${response.statusCode}');
//       debugPrint('📡 Change Password Response Body: ${response.jsonResponse}');
//
//       if (response.isSuccess) {
//         debugPrint('✅ Password changed successfully');
//
//         final userDataJson = response.jsonResponse?['data'];
//         if (userDataJson != null) {
//           final userData = UserData.fromJson(userDataJson);
//           emit(AccountSettingsSuccess(userData: userData));
//         } else {
//           debugPrint(
//             '⚠️ No user data in change-password response, '
//             'falling back to getUserProfile()',
//           );
//           await getUserProfile();
//         }
//       } else {
//         String errorMsg = response.errorMessage ?? 'Failed to change password';
//         if (response.jsonResponse != null) {
//           errorMsg =
//               response.jsonResponse?['message'] ??
//               response.jsonResponse?['error'] ??
//               errorMsg;
//         }
//
//         debugPrint('❌ Password change failed: $errorMsg');
//         emit(AccountSettingsFailure(errorMessage: errorMsg));
//       }
//     } catch (e) {
//       debugPrint('❌ Exception: $e');
//       emit(
//         AccountSettingsFailure(
//           errorMessage: 'An error occurred: ${e.toString()}',
//         ),
//       );
//     }
//   }
//
//   void resetState() {
//     emit(AccountSettingsInitial());
//   }
// }




///
///
///
///
///
///
/// todo:: impleting the dlete operation
///
///
///
///






import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/account_settings_data.dart';

// ==================== STATES ====================
abstract class AccountSettingsState extends Equatable {
  const AccountSettingsState();

  @override
  List<Object?> get props => [];
}

class AccountSettingsInitial extends AccountSettingsState {}

class AccountSettingsLoading extends AccountSettingsState {}

class AccountSettingsSuccess extends AccountSettingsState {
  final UserData userData;

  const AccountSettingsSuccess({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class AccountSettingsFailure extends AccountSettingsState {
  final String errorMessage;

  const AccountSettingsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// ==================== CUBIT ====================
class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  AccountSettingsCubit() : super(AccountSettingsInitial());

  Future<void> getUserProfile() async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.userProfile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userProfile = AccountSettingResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (userProfile.data != null) {
          emit(AccountSettingsSuccess(userData: userProfile.data!));
        } else {
          emit(const AccountSettingsFailure(
            errorMessage: 'Invalid response from server',
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to load profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Upload image
  Future<String?> uploadImage(File imageFile) async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return null;
      }

      final response = await _networkCaller.uploadImage(
        AppUrl.singleImageUpload,
        imageFile: imageFile,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
        fileFieldName: 'file',
        method: 'POST',
      );

      if (response.isSuccess) {
        final filename = response.jsonResponse?['data']?['filename'];
        debugPrint('✅ Upload successful: $filename');
        return filename;
      } else {
        debugPrint('❌ Upload failed: ${response.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
    required String profileImage,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'name': name,
        'phone': phone,
        'address': address,
        'profileImage': profileImage,
      };

      final response = await _networkCaller.putRequest(
        AppUrl.userProfileUpdate,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          emit(AccountSettingsSuccess(userData: userData));
        } else {
          await getUserProfile();
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to update profile';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      emit(AccountSettingsLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const AccountSettingsFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final Map<String, dynamic> requestBody = {
        'currentPassword': currentPassword,
        'password': newPassword,
        'confirmPassword': confirmPassword,
      };

      final response = await _networkCaller.postRequest(
        AppUrl.changePassword,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final userDataJson = response.jsonResponse?['data'];
        if (userDataJson != null) {
          final userData = UserData.fromJson(userDataJson);
          emit(AccountSettingsSuccess(userData: userData));
        } else {
          await getUserProfile();
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to change password';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(AccountSettingsFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(AccountSettingsFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  // ✅ Delete Account
  Future<bool> deleteAccount() async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('❌ No access token found');
        return false;
      }

      debugPrint('🗑️ Deleting account...');

      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteUserAccount,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      debugPrint('📡 Delete Response Status: ${response.statusCode}');
      debugPrint('📡 Delete Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        // Clear all stored tokens
        await _storage.deleteAllTokens();
        debugPrint('✅ Account deleted successfully');
        return true;
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to delete account';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }
        debugPrint('❌ Delete failed: $errorMsg');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      return false;
    }
  }

  void resetState() {
    emit(AccountSettingsInitial());
  }
}