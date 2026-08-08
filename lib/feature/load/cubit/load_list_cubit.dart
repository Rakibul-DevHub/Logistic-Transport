import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tag/core/network/network_caller_dio.dart';
import 'package:tag/core/network/secure_storage_service.dart';
import 'package:tag/core/theme/app_colors.dart';
import 'package:tag/core/utils/app_url.dart';
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';
import 'package:tag/feature/load/model/load_list_data.dart';

// ---------------------------------------------------------------------------
// Home preview (My Loads + Assigned, top 2 each)
// ---------------------------------------------------------------------------

abstract class HomeLoadsState extends Equatable {
  const HomeLoadsState();

  @override
  List<Object?> get props => [];
}

class HomeLoadsInitial extends HomeLoadsState {}

class HomeLoadsLoading extends HomeLoadsState {}

class HomeLoadsSuccess extends HomeLoadsState {
  final List<AddLoadData> myLoads;
  final List<AddLoadData> assignedLoads;

  const HomeLoadsSuccess({required this.myLoads, required this.assignedLoads});

  @override
  List<Object?> get props => [myLoads, assignedLoads];
}

class HomeLoadsFailure extends HomeLoadsState {
  final String errorMessage;

  const HomeLoadsFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class HomeLoadsCubit extends Cubit<HomeLoadsState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  HomeLoadsCubit() : super(HomeLoadsInitial());

  Future<void> fetchPreviews({
    bool includeAssigned = true,
    bool silent = false,
  }) async {
    final previous = state;
    if (!silent) {
      emit(HomeLoadsLoading());
    }
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        if (silent && previous is HomeLoadsSuccess) return;
        emit(const HomeLoadsFailure(errorMessage: 'Please login again'));
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};

      final myFuture = _networkCaller.getRequest(
        AppUrl.getLoad('1', '2', LoadListType.self),
        headers: headers,
      );

      final assignedFuture = includeAssigned
          ? _networkCaller.getRequest(
              AppUrl.getLoad('1', '2', LoadListType.assigned),
              headers: headers,
            )
          : null;

      final myResponse = await myFuture;
      final assignedResponse = assignedFuture != null
          ? await assignedFuture
          : null;

      if (!myResponse.isSuccess) {
        if (silent && previous is HomeLoadsSuccess) return;
        emit(
          HomeLoadsFailure(
            errorMessage: myResponse.errorMessage ?? 'Failed to load my loads',
          ),
        );
        return;
      }

      final myLoads = LoadListResponse.fromJson(
        myResponse.jsonResponse ?? {},
      ).data;

      List<AddLoadData> assignedLoads = const [];
      if (assignedResponse != null && assignedResponse.isSuccess) {
        assignedLoads = LoadListResponse.fromJson(
          assignedResponse.jsonResponse ?? {},
        ).data;
      }

      emit(HomeLoadsSuccess(myLoads: myLoads, assignedLoads: assignedLoads));
    } catch (e) {
      debugPrint('❌ HomeLoadsCubit error: $e');
      if (silent && previous is HomeLoadsSuccess) return;
      emit(HomeLoadsFailure(errorMessage: e.toString()));
    }
  }
}

// ---------------------------------------------------------------------------
// Paginated list (Load tab)
// ---------------------------------------------------------------------------

abstract class LoadListState extends Equatable {
  const LoadListState();

  @override
  List<Object?> get props => [];
}

class LoadListInitial extends LoadListState {}

class LoadListLoading extends LoadListState {}

class LoadListSuccess extends LoadListState {
  final List<AddLoadData> loads;
  final LoadListPagination pagination;
  final String type;
  final bool isLoadingMore;

  const LoadListSuccess({
    required this.loads,
    required this.pagination,
    required this.type,
    this.isLoadingMore = false,
  });

  bool get hasMore => pagination.hasMore;

  LoadListSuccess copyWith({
    List<AddLoadData>? loads,
    LoadListPagination? pagination,
    String? type,
    bool? isLoadingMore,
  }) {
    return LoadListSuccess(
      loads: loads ?? this.loads,
      pagination: pagination ?? this.pagination,
      type: type ?? this.type,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [loads, pagination, type, isLoadingMore];
}

class LoadListFailure extends LoadListState {
  final String errorMessage;

  const LoadListFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class LoadListCubit extends Cubit<LoadListState> {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  static const int pageSize = 10;

  String _type = LoadListType.self;
  bool _isFetchingMore = false;

  // Used only when type == all
  int _selfPage = 1;
  int _assignedPage = 1;
  bool _selfHasMore = false;
  bool _assignedHasMore = false;

  LoadListCubit() : super(LoadListInitial());

  String get currentType => _type;

  Future<void> fetchLoads({required String type, bool refresh = true}) async {
    _type = type;
    if (refresh) {
      emit(LoadListLoading());
    }

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(const LoadListFailure(errorMessage: 'Please login again'));
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};

      if (type == LoadListType.all) {
        final selfFuture = _networkCaller.getRequest(
          AppUrl.getLoad('1', '$pageSize', LoadListType.self),
          headers: headers,
        );
        final assignedFuture = _networkCaller.getRequest(
          AppUrl.getLoad('1', '$pageSize', LoadListType.assigned),
          headers: headers,
        );

        final selfResponse = await selfFuture;
        final assignedResponse = await assignedFuture;

        if (!selfResponse.isSuccess && !assignedResponse.isSuccess) {
          emit(
            LoadListFailure(
              errorMessage: selfResponse.errorMessage ?? 'Failed to load loads',
            ),
          );
          return;
        }

        final selfParsed = selfResponse.isSuccess
            ? LoadListResponse.fromJson(selfResponse.jsonResponse ?? {})
            : null;
        final assignedParsed = assignedResponse.isSuccess
            ? LoadListResponse.fromJson(assignedResponse.jsonResponse ?? {})
            : null;

        _selfPage = selfParsed?.pagination.currentPage ?? 1;
        _assignedPage = assignedParsed?.pagination.currentPage ?? 1;
        _selfHasMore = selfParsed?.pagination.hasMore ?? false;
        _assignedHasMore = assignedParsed?.pagination.hasMore ?? false;

        final merged = _mergeAllLoads([
          ...?selfParsed?.data,
          ...?assignedParsed?.data,
        ]);

        emit(
          LoadListSuccess(
            loads: merged,
            pagination: LoadListPagination(
              totalCount: merged.length,
              totalPages: (_selfHasMore || _assignedHasMore) ? 2 : 1,
              currentPage: 1,
              itemsPerPage: pageSize,
            ),
            type: type,
          ),
        );

        // Warm page 2 immediately so first scroll feels instant.
        _prefetchNextPageSilently();
        return;
      }

      final response = await _networkCaller.getRequest(
        AppUrl.getLoad('1', '$pageSize', type),
        headers: headers,
      );

      if (!response.isSuccess) {
        emit(
          LoadListFailure(
            errorMessage: response.errorMessage ?? 'Failed to load loads',
          ),
        );
        return;
      }

      final parsed = LoadListResponse.fromJson(response.jsonResponse ?? {});
      emit(
        LoadListSuccess(
          loads: parsed.data,
          pagination: parsed.pagination,
          type: type,
        ),
      );

      _prefetchNextPageSilently();
    } catch (e) {
      debugPrint('❌ LoadListCubit fetch error: $e');
      emit(LoadListFailure(errorMessage: e.toString()));
    }
  }

  void _prefetchNextPageSilently() {
    Future.microtask(() => loadMore(silent: true));
  }

  /// [silent] = true → background prefetch (no bottom spinner).
  /// [silent] = false → user is near the end; show spinner if still waiting.
  Future<void> loadMore({bool silent = true}) async {
    final current = state;
    if (current is! LoadListSuccess) return;
    if (!current.hasMore) return;

    // Already fetching — only upgrade UI to spinner if user reached the end.
    if (_isFetchingMore) {
      if (!silent && !current.isLoadingMore) {
        emit(current.copyWith(isLoadingMore: true));
      }
      return;
    }

    _isFetchingMore = true;
    if (!silent) {
      emit(current.copyWith(isLoadingMore: true));
    }

    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) {
        emit(current.copyWith(isLoadingMore: false));
        _isFetchingMore = false;
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};

      if (current.type == LoadListType.all) {
        final nextLoads = <AddLoadData>[];

        if (_selfHasMore) {
          final next = _selfPage + 1;
          final res = await _networkCaller.getRequest(
            AppUrl.getLoad('$next', '$pageSize', LoadListType.self),
            headers: headers,
          );
          if (res.isSuccess) {
            final parsed = LoadListResponse.fromJson(res.jsonResponse ?? {});
            nextLoads.addAll(parsed.data);
            _selfPage = parsed.pagination.currentPage;
            _selfHasMore = parsed.pagination.hasMore;
          } else {
            _selfHasMore = false;
          }
        }

        if (_assignedHasMore) {
          final next = _assignedPage + 1;
          final res = await _networkCaller.getRequest(
            AppUrl.getLoad('$next', '$pageSize', LoadListType.assigned),
            headers: headers,
          );
          if (res.isSuccess) {
            final parsed = LoadListResponse.fromJson(res.jsonResponse ?? {});
            nextLoads.addAll(parsed.data);
            _assignedPage = parsed.pagination.currentPage;
            _assignedHasMore = parsed.pagination.hasMore;
          } else {
            _assignedHasMore = false;
          }
        }

        final merged = _mergeAllLoads([...current.loads, ...nextLoads]);
        emit(
          LoadListSuccess(
            loads: merged,
            pagination: LoadListPagination(
              totalCount: merged.length,
              totalPages: (_selfHasMore || _assignedHasMore) ? 2 : 1,
              currentPage: 1,
              itemsPerPage: pageSize,
            ),
            type: LoadListType.all,
            isLoadingMore: false,
          ),
        );
        return;
      }

      final nextPage = current.pagination.currentPage + 1;
      final response = await _networkCaller.getRequest(
        AppUrl.getLoad('$nextPage', '$pageSize', current.type),
        headers: headers,
      );

      if (!response.isSuccess) {
        emit(current.copyWith(isLoadingMore: false));
        _isFetchingMore = false;
        return;
      }

      final parsed = LoadListResponse.fromJson(response.jsonResponse ?? {});
      emit(
        LoadListSuccess(
          loads: [...current.loads, ...parsed.data],
          pagination: parsed.pagination,
          type: current.type,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      debugPrint('❌ LoadListCubit loadMore error: $e');
      emit(current.copyWith(isLoadingMore: false));
    } finally {
      _isFetchingMore = false;
    }
  }

  List<AddLoadData> _mergeUnique(List<AddLoadData> loads) {
    final seen = <String>{};
    final result = <AddLoadData>[];
    for (final load in loads) {
      final key = (load.id ?? load.loadId ?? '').trim();
      if (key.isEmpty) {
        result.add(load);
        continue;
      }
      if (seen.add(key)) result.add(load);
    }
    return result;
  }

  /// Deduplicates self and assigned loads, then mixes them in API-date order
  /// instead of keeping the current user's loads above all assigned loads.
  List<AddLoadData> _mergeAllLoads(List<AddLoadData> loads) {
    final merged = _mergeUnique(loads);
    merged.sort((a, b) => _sortTime(b).compareTo(_sortTime(a)));
    return merged;
  }

  DateTime _sortTime(AddLoadData load) {
    for (final raw in [load.createdAt, load.updatedAt, load.pickupDate]) {
      if (raw == null || raw.isEmpty) continue;
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return parsed.toLocal();
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

// ---------------------------------------------------------------------------
// Display helpers shared by Home + Load cards
// ---------------------------------------------------------------------------

abstract final class LoadDisplayHelper {
  static String loadNumber(AddLoadData load) {
    final id = load.loadId?.trim();
    if (id != null && id.isNotEmpty) return '#$id';
    return '#—';
  }

  static String company(AddLoadData load) {
    final name = load.companyName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Unknown company';
  }

  static String driverName(
    AddLoadData load, {
    Map<String, String>? namesByUserId,
    String? currentUserId,
    String? currentUserName,
  }) {
    final fromApi = load.driverName?.trim();
    if (fromApi != null && fromApi.isNotEmpty) return fromApi;

    final userId = load.userId?.trim();
    if (userId != null && userId.isNotEmpty) {
      final mapped = namesByUserId?[userId]?.trim();
      if (mapped != null && mapped.isNotEmpty) return mapped;

      if (currentUserId != null &&
          userId == currentUserId &&
          currentUserName != null &&
          currentUserName.trim().isNotEmpty) {
        return currentUserName.trim();
      }
    }

    return 'Unknown driver';
  }

  static String pickupAddress(AddLoadData load) {
    final list = load.pickupAddresses;
    if (list != null && list.isNotEmpty) return list.first;
    return '—';
  }

  static String deliveryAddress(AddLoadData load) {
    final list = load.deliveryAddresses;
    if (list != null && list.isNotEmpty) return list.first;
    return '—';
  }

  static DateTime? pickupDate(AddLoadData load) {
    final raw = load.pickupDate;
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return null;
    }
  }

  static DateTime? deliveryDate(AddLoadData load) {
    final raw = load.deliveryDate;
    if (raw != null && raw.isNotEmpty) {
      try {
        return DateTime.parse(raw).toLocal();
      } catch (_) {}
    }

    // Completed loads often only have updatedAt as the delivery timestamp.
    final status = (load.status ?? '').toLowerCase().trim();
    final isCompleted = status == 'completed' || status == 'delivered';
    if (isCompleted) {
      final updated = load.updatedAt;
      if (updated != null && updated.isNotEmpty) {
        try {
          return DateTime.parse(updated).toLocal();
        } catch (_) {}
      }
    }
    return null;
  }

  static String formattedDate(AddLoadData load) {
    final date = pickupDate(load);
    if (date == null) return '—';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String formattedDateTime(AddLoadData load) {
    final date = pickupDate(load);
    if (date == null) return '—';
    return DateFormat('MMM dd, HH:mm').format(date);
  }

  static String amount(AddLoadData load) {
    final rate = load.rate;
    if (rate == null) return '+\$0';
    final value = rate.toDouble();
    if (value == value.roundToDouble()) {
      return '+\$${value.toInt()}';
    }
    return '+\$${value.toStringAsFixed(2)}';
  }

  static String statusLabel(AddLoadData load) {
    final raw = (load.status ?? 'pending').toLowerCase().trim();
    switch (raw) {
      case 'completed':
      case 'delivered':
        return 'Completed';
      case 'missing_pod':
      case 'missingpod':
      case 'missing pod':
        return 'Missing POD';
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return 'In Progress';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  static Color statusColor(AddLoadData load) {
    final raw = (load.status ?? 'pending').toLowerCase().trim();
    switch (raw) {
      case 'completed':
      case 'delivered':
        return AppColors.assigned;
      case 'missing_pod':
      case 'missingpod':
      case 'missing pod':
        return AppColors.waiting;
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
        return const Color(0xFF2563EB);
      case 'pending':
      default:
        return AppColors.waiting;
    }
  }

  /// Maps API status → load-screen filter chips.
  static String filterBucket(AddLoadData load) {
    final raw = (load.status ?? 'pending').toLowerCase().trim();
    switch (raw) {
      case 'completed':
      case 'delivered':
        return 'Completed';
      case 'missing_pod':
      case 'missingpod':
      case 'missing pod':
        return 'Missing POD';
      case 'in_progress':
      case 'inprogress':
      case 'in progress':
      case 'pending':
      default:
        return 'In Progress';
    }
  }
}
