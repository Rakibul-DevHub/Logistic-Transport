import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/notification/model/notification_data.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<AppNotification> items;
  final NotificationPagination pagination;
  final bool isLoadingMore;

  const NotificationSuccess({
    required this.items,
    required this.pagination,
    this.isLoadingMore = false,
  });

  bool get hasMore => pagination.hasMore;

  NotificationSuccess copyWith({
    List<AppNotification>? items,
    NotificationPagination? pagination,
    bool? isLoadingMore,
  }) {
    return NotificationSuccess(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [items, pagination, isLoadingMore];
}

class NotificationFailure extends NotificationState {
  final String errorMessage;

  const NotificationFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  static const int _pageSize = 11;
  bool _fetchingMore = false;

  NotificationCubit() : super(NotificationInitial());

  Future<void> fetch({bool refresh = true}) async {
    if (refresh) emit(NotificationLoading());

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const NotificationFailure(errorMessage: 'Please login again'));
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getAllNotification('1', '$_pageSize'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        emit(NotificationFailure(
          errorMessage:
              response.errorMessage ?? 'Failed to load notifications',
        ));
        return;
      }

      final parsed = NotificationListResponse.fromJson(response.jsonResponse!);
      emit(NotificationSuccess(
        items: parsed.data,
        pagination: parsed.pagination,
      ));
    } catch (e) {
      debugPrint('❌ NotificationCubit fetch error: $e');
      emit(NotificationFailure(errorMessage: e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! NotificationSuccess) return;
    if (!current.hasMore || _fetchingMore || current.isLoadingMore) return;

    _fetchingMore = true;
    emit(current.copyWith(isLoadingMore: true));

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(current.copyWith(isLoadingMore: false));
        _fetchingMore = false;
        return;
      }

      final nextPage = current.pagination.currentPage + 1;
      final response = await _networkCaller.getRequest(
        AppUrl.getAllNotification('$nextPage', '$_pageSize'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        emit(current.copyWith(isLoadingMore: false));
        _fetchingMore = false;
        return;
      }

      final parsed = NotificationListResponse.fromJson(response.jsonResponse!);
      emit(NotificationSuccess(
        items: [...current.items, ...parsed.data],
        pagination: parsed.pagination,
        isLoadingMore: false,
      ));
    } catch (e) {
      debugPrint('❌ NotificationCubit loadMore error: $e');
      emit(current.copyWith(isLoadingMore: false));
    } finally {
      _fetchingMore = false;
    }
  }

  /// GET /load/:loadId → AddLoadData for details screen.
  Future<AddLoadData?> fetchLoadById(String loadId) async {
    final id = loadId.trim();
    if (id.isEmpty) return null;

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final response = await _networkCaller.getRequest(
        AppUrl.getIdLoadDetails(id),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!response.isSuccess || response.jsonResponse == null) {
        debugPrint('❌ fetchLoadById failed: ${response.errorMessage}');
        return null;
      }

      final json = response.jsonResponse!;
      final raw = json['data'] ?? json;
      if (raw is Map<String, dynamic>) {
        return AddLoadData.fromJson(raw);
      }
      if (raw is Map) {
        return AddLoadData.fromJson(Map<String, dynamic>.from(raw));
      }
      return null;
    } catch (e) {
      debugPrint('❌ NotificationCubit fetchLoadById error: $e');
      return null;
    }
  }

  void markAsReadLocal(String id) {
    final current = state;
    if (current is! NotificationSuccess) return;
    emit(current.copyWith(
      items: current.items
          .map((n) => n.id == id ? n.copyWith(viewStatus: true) : n)
          .toList(),
    ));
  }

  void markAllAsReadLocal() {
    final current = state;
    if (current is! NotificationSuccess) return;
    emit(current.copyWith(
      items: current.items.map((n) => n.copyWith(viewStatus: true)).toList(),
    ));
  }
}
