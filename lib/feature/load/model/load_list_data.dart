
import 'package:tag/feature/bill_of_loading/model/add_load_data.dart';

class LoadListPagination {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;

  const LoadListPagination({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
  });

  factory LoadListPagination.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LoadListPagination(
        totalCount: 0,
        totalPages: 0,
        currentPage: 1,
        itemsPerPage: 10,
      );
    }
    return LoadListPagination(
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 10,
    );
  }

  bool get hasMore => currentPage < totalPages;
}

class LoadListResponse {
  final List<AddLoadData> data;
  final LoadListPagination pagination;

  const LoadListResponse({
    required this.data,
    required this.pagination,
  });

  factory LoadListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final loads = <AddLoadData>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          loads.add(AddLoadData.fromJson(item));
        } else if (item is Map) {
          loads.add(AddLoadData.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return LoadListResponse(
      data: loads,
      pagination: LoadListPagination.fromJson(
        json['pagination'] is Map
            ? Map<String, dynamic>.from(json['pagination'] as Map)
            : null,
      ),
    );
  }
}

/// Query type for [AppUrl.getLoad].
abstract final class LoadListType {
  static const String self = 'self';
  static const String assigned = 'assigned';

  /// Client-only: merges self + assigned (not sent to API as-is).
  static const String all = 'all';
}



