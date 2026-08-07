/**
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
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      if (token == null || token.isEmpty) {
        if (silent && previous is HomeReportSuccess) return;
        emit(const HomeReportFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.homeReport,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📊 Response Status: ${response.isSuccess}');
      debugPrint('📊 Response Data: ${response.jsonResponse}');

      if (!response.isSuccess || response.jsonResponse == null) {
        if (silent && previous is HomeReportSuccess) return;
        emit(HomeReportFailure(
          errorMessage: response.errorMessage ?? 'Failed to load home report',
        ));
        return;
      }

      final parsed = HomeReportResponse.fromJson(response.jsonResponse!);
      debugPrint('✅ Parsed Data: ${parsed.data != null ? "Success" : "Null"}');

      if (parsed.data == null) {
        if (silent && previous is HomeReportSuccess) return;
        emit(HomeReportFailure(
          errorMessage: parsed.message ?? 'Home report data is empty',
        ));
        return;
      }

      // Debug all counts
      final counts = parsed.data!.loadStatusCounts;
      debugPrint('✅ Missing POD: ${counts.missingPod}');
      debugPrint('✅ Pending: ${counts.pending}');
      debugPrint('✅ Completed (Delivered): ${counts.delivered}');
      debugPrint('✅ Draft: ${counts.draft}');
      debugPrint('✅ In Transit: ${counts.inTransit}');
      debugPrint('✅ Cancelled: ${counts.cancelled}');

      emit(HomeReportSuccess(data: parsed.data!));
    } catch (e, stackTrace) {
      debugPrint('❌ HomeReportCubit error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      if (silent && previous is HomeReportSuccess) return;
      emit(HomeReportFailure(errorMessage: e.toString()));
    }
  }
}*/







///
///
///
///
/// todo::: cacheing data
///
///
///
///




import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/home/model/home_report_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class HomeReportState extends Equatable {
  const HomeReportState();

  @override
  List<Object?> get props => [];
}

class HomeReportInitial extends HomeReportState {}

class HomeReportLoading extends HomeReportState {}

class HomeReportSuccess extends HomeReportState {
  final HomeReportData data;
  final bool fromCache;

  const HomeReportSuccess({required this.data, this.fromCache = false});

  @override
  List<Object?> get props => [data, fromCache];
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

  // Cache keys
  static const String _cacheKey = 'home_report_cache';

  HomeReportCubit() : super(HomeReportInitial()) {
    // Load cached data on initialization
    _loadFromCache();
  }

  /// Load cached data from SharedPreferences
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(cachedJson);
        final data = HomeReportData.fromJson(jsonMap);
        emit(HomeReportSuccess(data: data, fromCache: true));
        debugPrint('📦 Loaded home report from cache');
      }
    } catch (e) {
      debugPrint('❌ Failed to load home report from cache: $e');
    }
  }

  /// Save data to cache
  Future<void> _saveToCache(HomeReportData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convert to JSON
      final jsonData = {
        'summary': {
          'totalIncome': data.summary.totalIncome,
          'totalExpenses': data.summary.totalExpenses,
          'totalProfit': data.summary.totalProfit,
          'profitMargin': data.summary.profitMargin,
        },
        'loadStatusCounts': {
          'draft': data.loadStatusCounts.draft,
          'pending': data.loadStatusCounts.pending,
          'inTransit': data.loadStatusCounts.inTransit,
          'delivered': data.loadStatusCounts.delivered,
          'cancelled': data.loadStatusCounts.cancelled,
          'missing-pod': data.loadStatusCounts.missingPod,
        }
      };
      await prefs.setString(_cacheKey, jsonEncode(jsonData));
      debugPrint('💾 Saved home report to cache');
    } catch (e) {
      debugPrint('❌ Failed to save home report to cache: $e');
    }
  }

  Future<void> fetch({bool silent = false}) async {
    final previous = state;
    if (!silent) {
      emit(HomeReportLoading());
    }
    try {
      final token = await _storage.getAccessToken();
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      if (token == null || token.isEmpty) {
        if (silent && previous is HomeReportSuccess) return;
        emit(const HomeReportFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.homeReport,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📊 Response Status: ${response.isSuccess}');
      debugPrint('📊 Response Data: ${response.jsonResponse}');

      if (!response.isSuccess || response.jsonResponse == null) {
        // If silent refresh fails, keep cached data
        if (silent && previous is HomeReportSuccess) {
          // Keep showing cached data
          return;
        }
        emit(HomeReportFailure(
          errorMessage: response.errorMessage ?? 'Failed to load home report',
        ));
        return;
      }

      final parsed = HomeReportResponse.fromJson(response.jsonResponse!);
      debugPrint('✅ Parsed Data: ${parsed.data != null ? "Success" : "Null"}');

      if (parsed.data == null) {
        if (silent && previous is HomeReportSuccess) {
          // Keep cached data if available
          return;
        }
        emit(HomeReportFailure(
          errorMessage: parsed.message ?? 'Home report data is empty',
        ));
        return;
      }

      // Save to cache
      await _saveToCache(parsed.data!);

      // Debug all counts
      final counts = parsed.data!.loadStatusCounts;
      debugPrint('✅ Missing POD: ${counts.missingPod}');
      debugPrint('✅ Pending: ${counts.pending}');
      debugPrint('✅ Completed (Delivered): ${counts.delivered}');
      debugPrint('✅ Draft: ${counts.draft}');
      debugPrint('✅ In Transit: ${counts.inTransit}');
      debugPrint('✅ Cancelled: ${counts.cancelled}');

      emit(HomeReportSuccess(data: parsed.data!, fromCache: false));
    } catch (e, stackTrace) {
      debugPrint('❌ HomeReportCubit error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      // If silent refresh fails and we have cached data, keep it
      if (silent && previous is HomeReportSuccess) {
        // Keep cached data
        return;
      }
      emit(HomeReportFailure(errorMessage: e.toString()));
    }
  }

  /// Clear cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      debugPrint('🗑️ Cleared home report cache');
    } catch (e) {
      debugPrint('❌ Failed to clear home report cache: $e');
    }
  }
}