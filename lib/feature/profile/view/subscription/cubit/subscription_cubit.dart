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
}