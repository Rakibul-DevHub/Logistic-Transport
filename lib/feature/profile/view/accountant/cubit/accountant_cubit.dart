import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/profile/view/accountant/model/accountant_data.dart';

abstract class AccountantState extends Equatable {
  const AccountantState();

  @override
  List<Object?> get props => [];
}

class AccountantInitial extends AccountantState {}

class AccountantLoading extends AccountantState {}

class AccountantEmpty extends AccountantState {}

class AccountantLoaded extends AccountantState {
  final AccountantData data;

  const AccountantLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class AccountantSaving extends AccountantState {}

class AccountantRemoving extends AccountantState {
  final AccountantData data;

  const AccountantRemoving({required this.data});

  @override
  List<Object?> get props => [data];
}

class AccountantSending extends AccountantState {
  final AccountantData data;

  const AccountantSending({required this.data});

  @override
  List<Object?> get props => [data];
}

class AccountantFailure extends AccountantState {
  final String errorMessage;
  final AccountantData? data;

  const AccountantFailure({
    required this.errorMessage,
    this.data,
  });

  @override
  List<Object?> get props => [errorMessage, data];
}

class AccountantCubit extends Cubit<AccountantState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  AccountantCubit() : super(AccountantInitial());

  AccountantData? get _currentData {
    final s = state;
    if (s is AccountantLoaded) return s.data;
    if (s is AccountantSending) return s.data;
    if (s is AccountantRemoving) return s.data;
    if (s is AccountantFailure) return s.data;
    return null;
  }

  Future<String?> _token() async {
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return null;
    return accessToken;
  }

  Future<void> getAccountant() async {
    emit(AccountantLoading());
    try {
      final token = await _token();
      if (token == null) {
        emit(const AccountantFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getAccountant,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 404) {
        emit(AccountantEmpty());
        return;
      }

      if (!response.isSuccess || response.jsonResponse == null) {
        // No accountant configured yet
        if (response.statusCode == 400 || response.statusCode == 404) {
          emit(AccountantEmpty());
          return;
        }
        emit(AccountantFailure(
          errorMessage:
              response.errorMessage ?? 'Failed to load accountant',
        ));
        return;
      }

      final parsed = AccountantResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null || parsed.data!.value.email.trim().isEmpty) {
        emit(AccountantEmpty());
        return;
      }

      emit(AccountantLoaded(data: parsed.data!));
    } catch (e) {
      debugPrint('❌ getAccountant error: $e');
      emit(AccountantFailure(errorMessage: e.toString()));
    }
  }

  Future<bool> addAccountant({
    required String name,
    required String email,
  }) async {
    emit(AccountantSaving());
    try {
      final token = await _token();
      if (token == null) {
        emit(const AccountantFailure(errorMessage: 'Please login again'));
        return false;
      }

      final response = await _networkCaller.putRequest(
        AppUrl.addAccountant,
        body: {
          'name': name.trim(),
          'email': email.trim(),
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        final msg = response.jsonResponse?['message']?.toString() ??
            response.errorMessage ??
            'Failed to save accountant';
        emit(AccountantFailure(errorMessage: msg));
        return false;
      }

      final parsed = AccountantResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        emit(const AccountantFailure(
          errorMessage: 'Accountant saved but response was empty',
        ));
        return false;
      }

      emit(AccountantLoaded(data: parsed.data!));
      return true;
    } catch (e) {
      debugPrint('❌ addAccountant error: $e');
      emit(AccountantFailure(errorMessage: e.toString()));
      return false;
    }
  }

  Future<bool> removeAccountant() async {
    final existing = _currentData;
    if (existing == null) {
      emit(AccountantEmpty());
      return true;
    }

    emit(AccountantRemoving(data: existing));
    try {
      final token = await _token();
      if (token == null) {
        emit(AccountantFailure(
          errorMessage: 'Please login again',
          data: existing,
        ));
        return false;
      }

      final response = await _networkCaller.deleteRequest(
        AppUrl.removeAccountant,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess &&
          response.statusCode != 200 &&
          response.statusCode != 204) {
        final msg = response.jsonResponse?['message']?.toString() ??
            response.errorMessage ??
            'Failed to remove accountant';
        emit(AccountantFailure(errorMessage: msg, data: existing));
        return false;
      }

      emit(AccountantEmpty());
      return true;
    } catch (e) {
      debugPrint('❌ removeAccountant error: $e');
      emit(AccountantFailure(errorMessage: e.toString(), data: existing));
      return false;
    }
  }

  Future<({bool ok, String message, String? sentTo})> sendReport({
    required String fromDate,
    required String toDate,
  }) async {
    final existing = _currentData;
    emit(AccountantSending(
      data: existing ??
          AccountantData(
            id: '',
            key: 'accountant',
            userId: '',
            value: AccountantValue(name: '', email: ''),
          ),
    ));

    try {
      final token = await _token();
      if (token == null) {
        emit(AccountantFailure(
          errorMessage: 'Please login again',
          data: existing,
        ));
        return (
          ok: false,
          message: 'Please login again',
          sentTo: null,
        );
      }

      final response = await _networkCaller.postRequest(
        AppUrl.sendReportAccountant,
        body: {
          'fromDate': fromDate,
          'toDate': toDate,
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        final msg = response.jsonResponse?['message']?.toString() ??
            response.errorMessage ??
            'Failed to send report';
        emit(AccountantFailure(errorMessage: msg, data: existing));
        return (ok: false, message: msg, sentTo: null);
      }

      final parsed =
          SendReportAccountantResponse.fromJson(response.jsonResponse!);
      final message =
          parsed.message ?? 'Report sent to accountant successfully';

      if (existing != null) {
        emit(AccountantLoaded(data: existing));
      } else {
        emit(AccountantEmpty());
      }

      return (ok: true, message: message, sentTo: parsed.sentTo);
    } catch (e) {
      debugPrint('❌ sendReportAccountant error: $e');
      emit(AccountantFailure(errorMessage: e.toString(), data: existing));
      return (ok: false, message: e.toString(), sentTo: null);
    }
  }
}
