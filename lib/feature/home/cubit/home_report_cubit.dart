import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/home/model/home_report_data.dart';

abstract class HomeReportState extends Equatable {
  const HomeReportState();

  @override
  List<Object?> get props => [];
}

class HomeReportInitial extends HomeReportState {}

class HomeReportLoading extends HomeReportState {}

class HomeReportSuccess extends HomeReportState {
  final HomeReportData data;

  const HomeReportSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class HomeReportFailure extends HomeReportState {
  final String errorMessage;

  const HomeReportFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class HomeReportCubit extends Cubit<HomeReportState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  HomeReportCubit() : super(HomeReportInitial());

  Future<void> fetch({bool silent = false}) async {
    final previous = state;
    if (!silent) {
      emit(HomeReportLoading());
    }
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        if (silent && previous is HomeReportSuccess) return;
        emit(const HomeReportFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.homeReport,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        if (silent && previous is HomeReportSuccess) return;
        emit(HomeReportFailure(
          errorMessage: response.errorMessage ?? 'Failed to load home report',
        ));
        return;
      }

      final parsed = HomeReportResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        if (silent && previous is HomeReportSuccess) return;
        emit(HomeReportFailure(
          errorMessage: parsed.message ?? 'Home report data is empty',
        ));
        return;
      }

      emit(HomeReportSuccess(data: parsed.data!));
    } catch (e) {
      debugPrint('❌ HomeReportCubit error: $e');
      if (silent && previous is HomeReportSuccess) return;
      emit(HomeReportFailure(errorMessage: e.toString()));
    }
  }
}
