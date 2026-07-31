/**
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/subscription_data.dart';

/// ==================== STATES ====================
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionSuccess extends SubscriptionState {
  final List<SubscriptionPlan> plans;

  const SubscriptionSuccess({required this.plans});

  @override
  List<Object?> get props => [plans];
}

class SubscriptionFailure extends SubscriptionState {
  final String errorMessage;

  const SubscriptionFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Result of starting a Stripe checkout purchase.
class PurchaseCheckoutResult {
  final String? checkoutUrl;
  final String? errorMessage;
  final bool alreadyHasActivePlan;

  const PurchaseCheckoutResult({
    this.checkoutUrl,
    this.errorMessage,
    this.alreadyHasActivePlan = false,
  });

  bool get isSuccess =>
      checkoutUrl != null && checkoutUrl!.isNotEmpty;
}

/// ==================== CUBIT ====================
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  SubscriptionCubit() : super(SubscriptionInitial());

  Future<void> getSubscriptionPlans() async {
    try {
      emit(SubscriptionLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const SubscriptionFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.activeSubscriptionPlans,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final planResponse = SubscriptionPlanResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (planResponse.data.isNotEmpty) {
          emit(SubscriptionSuccess(plans: planResponse.data));
        } else {
          emit(const SubscriptionFailure(
            errorMessage: 'No plans available',
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to load plans';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(SubscriptionFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(SubscriptionFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(SubscriptionInitial());
  }
}*/




///
///
/// todo:: implementing the purchase  and trial
///
///
///






// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:tag/core/network/network_caller_dio.dart';
// import 'package:tag/core/network/secure_storage_service.dart';
// import 'package:tag/core/utils/app_url.dart';
// import '../model/subscription_data.dart';
//
// // ==================== STATES ====================
// abstract class SubscriptionState extends Equatable {
//   const SubscriptionState();
//
//   @override
//   List<Object?> get props => [];
// }
//
// class SubscriptionInitial extends SubscriptionState {}
//
// class SubscriptionLoading extends SubscriptionState {}
//
// class SubscriptionSuccess extends SubscriptionState {
//   final List<SubscriptionPlan> plans;
//
//   const SubscriptionSuccess({required this.plans});
//
//   @override
//   List<Object?> get props => [plans];
// }
//
// class SubscriptionFailure extends SubscriptionState {
//   final String errorMessage;
//
//   const SubscriptionFailure({required this.errorMessage});
//
//   @override
//   List<Object?> get props => [errorMessage];
// }
//
// // ==================== CUBIT ====================
// class SubscriptionCubit extends Cubit<SubscriptionState> {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//   final SecureStorageService _storage = SecureStorageService.instance;
//
//   SubscriptionCubit() : super(SubscriptionInitial());
//
//   Future<void> getSubscriptionPlans() async {
//     try {
//       emit(SubscriptionLoading());
//
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         emit(const SubscriptionFailure(
//           errorMessage: 'Please login again',
//         ));
//         return;
//       }
//
//       final response = await _networkCaller.getRequest(
//         AppUrl.activeSubscriptionPlans,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       if (response.isSuccess) {
//         final planResponse = SubscriptionPlanResponse.fromJson(
//           response.jsonResponse ?? {},
//         );
//
//         if (planResponse.data.isNotEmpty) {
//           emit(SubscriptionSuccess(plans: planResponse.data));
//         } else {
//           emit(const SubscriptionFailure(
//             errorMessage: 'No plans available',
//           ));
//         }
//       } else {
//         String errorMsg = response.errorMessage ?? 'Failed to load plans';
//         if (response.jsonResponse != null) {
//           errorMsg = response.jsonResponse?['message'] ??
//               response.jsonResponse?['error'] ??
//               errorMsg;
//         }
//
//         emit(SubscriptionFailure(errorMessage: errorMsg));
//       }
//     } catch (e) {
//       emit(SubscriptionFailure(
//         errorMessage: 'An error occurred: ${e.toString()}',
//       ));
//     }
//   }
//
//   // ✅ Start Free Trial
//   Future<bool> startFreeTrial(String planId, bool autoRenewal) async {
//     try {
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         return false;
//       }
//
//       final Map<String, dynamic> requestBody = {
//         'planId': planId,
//         'autoRenewal': autoRenewal,
//       };
//
//       final response = await _networkCaller.postRequest(
//         AppUrl.subscriptionFreeTrial,
//         body: requestBody,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       return response.isSuccess;
//     } catch (e) {
//       debugPrint('❌ Start trial error: $e');
//       return false;
//     }
//   }
//
//   // ✅ Purchase Subscription
//   Future<String?> purchaseSubscription(String planId, bool autoRenewal) async {
//     try {
//       final accessToken = await _storage.getAccessToken();
//
//       if (accessToken == null || accessToken.isEmpty) {
//         return null;
//       }
//
//       final Map<String, dynamic> requestBody = {
//         'planId': planId,
//         'autoRenewal': autoRenewal,
//       };
//
//       final response = await _networkCaller.postRequest(
//         AppUrl.subscriptionPurchase,
//         body: requestBody,
//         headers: {
//           'Authorization': 'Bearer $accessToken',
//         },
//       );
//
//       if (response.isSuccess) {
//         final checkoutUrl = response.jsonResponse?['data']?['checkoutUrl'];
//         return checkoutUrl;
//       }
//       return null;
//     } catch (e) {
//       debugPrint('❌ Purchase error: $e');
//       return null;
//     }
//   }
//
//   void resetState() {
//     emit(SubscriptionInitial());
//   }
// }














// lib/feature/profile/view/subscription/cubit/subscription_cubit.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import '../model/subscription_data.dart';

// ==================== STATES ====================
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionSuccess extends SubscriptionState {
  final List<SubscriptionPlan> plans;

  const SubscriptionSuccess({required this.plans});

  @override
  List<Object?> get props => [plans];
}

class SubscriptionFailure extends SubscriptionState {
  final String errorMessage;

  const SubscriptionFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Result of starting a Stripe checkout purchase.
class PurchaseCheckoutResult {
  final String? checkoutUrl;
  final String? errorMessage;
  final bool alreadyHasActivePlan;

  const PurchaseCheckoutResult({
    this.checkoutUrl,
    this.errorMessage,
    this.alreadyHasActivePlan = false,
  });

  bool get isSuccess =>
      checkoutUrl != null && checkoutUrl!.isNotEmpty;
}

// ✅ My Active Plan States
abstract class MyActivePlanState extends Equatable {
  const MyActivePlanState();

  @override
  List<Object?> get props => [];
}

class MyActivePlanInitial extends MyActivePlanState {}

class MyActivePlanLoading extends MyActivePlanState {}

class MyActivePlanSuccess extends MyActivePlanState {
  final SubscriptionPlan plan;

  const MyActivePlanSuccess({required this.plan});

  @override
  List<Object?> get props => [plan];
}

class MyActivePlanFailure extends MyActivePlanState {
  final String errorMessage;

  const MyActivePlanFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class MyActivePlanEmpty extends MyActivePlanState {}

// ==================== CUBIT ====================
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  SubscriptionCubit() : super(SubscriptionInitial());

  Future<void> getSubscriptionPlans() async {
    try {
      emit(SubscriptionLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const SubscriptionFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.activeSubscriptionPlans,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final planResponse = SubscriptionPlanResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (planResponse.data.isNotEmpty) {
          emit(SubscriptionSuccess(plans: planResponse.data));
        } else {
          emit(const SubscriptionFailure(
            errorMessage: 'No plans available',
          ));
        }
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to load plans';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(SubscriptionFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(SubscriptionFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  Future<bool> startFreeTrial(String planId, bool autoRenewal) async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      final Map<String, dynamic> requestBody = {
        'planId': planId,
        'autoRenewal': autoRenewal,
      };

      debugPrint('📤 Starting trial for plan: $planId');

      final response = await _networkCaller.postRequest(
        AppUrl.subscriptionFreeTrial,
        body: requestBody,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        // ✅ Check if the plan matches what was requested
        final returnedPlanId = response.jsonResponse?['data']?['planId'];
        if (returnedPlanId != null && returnedPlanId != planId) {
          debugPrint('⚠️ WARNING: Requested plan $planId but got $returnedPlanId');
          // Optionally show a warning to the user
          return false; // Or handle differently
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Start trial error: $e');
      return false;
    }
  }



  // ✅ Purchase Subscription
  Future<PurchaseCheckoutResult> purchaseSubscription(
    String planId,
    bool autoRenewal,
  ) async {
    try {
      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        return const PurchaseCheckoutResult(
          errorMessage: 'Please login again',
        );
      }

      final response = await _networkCaller.postRequest(
        AppUrl.subscriptionPurchase,
        body: {
          'planId': planId,
          'autoRenewal': autoRenewal,
        },
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        final checkoutUrl =
            response.jsonResponse?['data']?['checkoutUrl']?.toString();
        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          return PurchaseCheckoutResult(checkoutUrl: checkoutUrl);
        }
        return const PurchaseCheckoutResult(
          errorMessage: 'Checkout URL missing from server response',
        );
      }

      String errorMsg =
          response.errorMessage ?? 'Failed to create checkout session';
      final json = response.jsonResponse;
      if (json != null) {
        errorMsg = (json['message'] ?? json['error'] ?? errorMsg).toString();
        final errors = json['error'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is Map && first['message'] != null) {
            errorMsg = first['message'].toString();
          }
        }
      }

      final alreadyHasPlan = response.statusCode == 409 ||
          errorMsg.toLowerCase().contains('already has an active plan');

      return PurchaseCheckoutResult(
        errorMessage: errorMsg,
        alreadyHasActivePlan: alreadyHasPlan,
      );
    } catch (e) {
      debugPrint('❌ Purchase error: $e');
      return PurchaseCheckoutResult(
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void resetState() {
    emit(SubscriptionInitial());
  }
}

// ==================== MY ACTIVE PLAN CUBIT ====================
class MyActivePlanCubit extends Cubit<MyActivePlanState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  MyActivePlanCubit() : super(MyActivePlanInitial());

  Future<void> getMyActivePlan() async {
    try {
      emit(MyActivePlanLoading());

      final accessToken = await _storage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        emit(const MyActivePlanFailure(
          errorMessage: 'Please login again',
        ));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.myActivePlan,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.isSuccess) {
        // ✅ Use ActivePlanResponse to parse the nested structure
        final activePlanResponse = ActivePlanResponse.fromJson(
          response.jsonResponse ?? {},
        );

        if (activePlanResponse.data != null) {
          final plan = activePlanResponse.data!.planId;
          emit(MyActivePlanSuccess(plan: plan));
        } else {
          emit(MyActivePlanEmpty());
        }
      } else if (response.statusCode == 404) {
        // No active plan found
        emit(MyActivePlanEmpty());
      } else {
        String errorMsg = response.errorMessage ?? 'Failed to load active plan';
        if (response.jsonResponse != null) {
          errorMsg = response.jsonResponse?['message'] ??
              response.jsonResponse?['error'] ??
              errorMsg;
        }

        emit(MyActivePlanFailure(errorMessage: errorMsg));
      }
    } catch (e) {
      emit(MyActivePlanFailure(
        errorMessage: 'An error occurred: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(MyActivePlanInitial());
  }
}