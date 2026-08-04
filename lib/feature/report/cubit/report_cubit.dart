/**
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/report/model/report_data.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final ReportData data;

  const ReportSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class ReportFailure extends ReportState {
  final String errorMessage;

  const ReportFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class ReportCubit extends Cubit<ReportState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  ReportCubit() : super(ReportInitial());

  /// This Week — Monday → Sunday of the current week.
  Future<void> fetchThisWeek() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return fetchRange(monday, sunday);
  }

  /// This Month — 1st → last day of current month.
  /// (Also used as default; can call [fetch] with no dates if needed.)
  Future<void> fetchThisMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    return fetchRange(first, last);
  }

  /// Last Month — 1st day → last day of previous month.
  Future<void> fetchLastMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month - 1, 1);
    final last = DateTime(now.year, now.month, 0);
    return fetchRange(first, last);
  }

  /// Custom range (calendar start → end).
  Future<void> fetchRange(DateTime start, DateTime end) {
    return fetch(
      startDate: _apiDate.format(_dateOnly(start)),
      endDate: _apiDate.format(_dateOnly(end)),
    );
  }

  Future<void> fetch({String? startDate, String? endDate}) async {
    emit(ReportLoading());
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const ReportFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.report(startDate, endDate),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        emit(ReportFailure(
          errorMessage: response.errorMessage ?? 'Failed to load report',
        ));
        return;
      }

      final parsed = ReportResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        emit(ReportFailure(
          errorMessage: parsed.message ?? 'Report data is empty',
        ));
        return;
      }

      emit(ReportSuccess(data: parsed.data!));
    } catch (e) {
      debugPrint('❌ ReportCubit error: $e');
      emit(ReportFailure(errorMessage: e.toString()));
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
*/













///
///
///todo:: updating for the internal refresh of report
///
///











import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/report/model/report_data.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportSuccess extends ReportState {
  final ReportData data;

  const ReportSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

class ReportFailure extends ReportState {
  final String errorMessage;

  const ReportFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class ReportCubit extends Cubit<ReportState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  static final DateFormat _apiDate = DateFormat('yyyy-MM-dd');

  ReportCubit() : super(ReportInitial());

  /// This Week — Monday → Sunday of the current week.
  Future<void> fetchThisWeek({bool silent = false}) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return fetchRange(monday, sunday, silent: silent);
  }

  /// This Month — 1st → last day of current month.
  Future<void> fetchThisMonth({bool silent = false}) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    return fetchRange(first, last, silent: silent);
  }

  /// Last Month — 1st day → last day of previous month.
  Future<void> fetchLastMonth({bool silent = false}) {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month - 1, 1);
    final last = DateTime(now.year, now.month, 0);
    return fetchRange(first, last, silent: silent);
  }

  /// Custom range (calendar start → end).
  Future<void> fetchRange(DateTime start, DateTime end, {bool silent = false}) {
    return fetch(
      startDate: _apiDate.format(_dateOnly(start)),
      endDate: _apiDate.format(_dateOnly(end)),
      silent: silent,
    );
  }

  Future<void> fetch({String? startDate, String? endDate, bool silent = false}) async {
    if (!silent) {
      emit(ReportLoading());
    }

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        if (!silent) {
          emit(const ReportFailure(errorMessage: 'Please login again'));
        }
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.report(startDate, endDate),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        if (!silent) {
          emit(ReportFailure(
            errorMessage: response.errorMessage ?? 'Failed to load report',
          ));
        }
        return;
      }

      final parsed = ReportResponse.fromJson(response.jsonResponse!);
      if (parsed.data == null) {
        if (!silent) {
          emit(ReportFailure(
            errorMessage: parsed.message ?? 'Report data is empty',
          ));
        }
        return;
      }

      emit(ReportSuccess(data: parsed.data!));
    } catch (e) {
      debugPrint('❌ ReportCubit error: $e');
      if (!silent) {
        emit(ReportFailure(errorMessage: e.toString()));
      }
    }
  }

  /// Silent refresh convenience methods (following HomeScreen pattern)
  Future<void> fetchThisWeekSilently() => fetchThisWeek(silent: true);
  Future<void> fetchThisMonthSilently() => fetchThisMonth(silent: true);
  Future<void> fetchRangeSilently(DateTime start, DateTime end) =>
      fetchRange(start, end, silent: true);

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}