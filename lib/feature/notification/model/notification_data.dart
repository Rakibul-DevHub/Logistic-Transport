class NotificationListResponse {
  final int? code;
  final List<AppNotification> data;
  final NotificationPagination pagination;

  const NotificationListResponse({
    this.code,
    required this.data,
    required this.pagination,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return NotificationListResponse(
      code: json['code'] is int
          ? json['code'] as int
          : int.tryParse('${json['code']}'),
      data: raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  AppNotification.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      pagination: json['pagination'] is Map<String, dynamic>
          ? NotificationPagination.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : NotificationPagination.empty(),
    );
  }
}

class NotificationPagination {
  final int totalCount;
  final int totalPages;
  final int currentPage;
  final int itemsPerPage;

  const NotificationPagination({
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
  });

  factory NotificationPagination.empty() => const NotificationPagination(
        totalCount: 0,
        totalPages: 0,
        currentPage: 1,
        itemsPerPage: 11,
      );

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      totalCount: _toInt(json['totalCount']),
      totalPages: _toInt(json['totalPages']),
      currentPage: _toInt(json['currentPage'], fallback: 1),
      itemsPerPage: _toInt(json['itemsPerPage'], fallback: 11),
    );
  }

  bool get hasMore => currentPage < totalPages;
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool viewStatus;
  final DateTime createdAt;
  /// Mongo / business load id used by GET /load/:id
  final String? loadId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.viewStatus,
    required this.createdAt,
    this.loadId,
  });

  /// API: viewStatus false = unread
  bool get isRead => viewStatus;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt']?.toString();
    DateTime created;
    try {
      created =
          rawDate != null ? DateTime.parse(rawDate).toLocal() : DateTime.now();
    } catch (_) {
      created = DateTime.now();
    }

    return AppNotification(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'default').toString(),
      viewStatus: json['viewStatus'] == true,
      createdAt: created,
      loadId: _extractLoadId(json),
    );
  }

  static String? _extractLoadId(Map<String, dynamic> json) {
    String? pick(dynamic v) {
      final s = v?.toString().trim();
      if (s == null || s.isEmpty || s == 'null') return null;
      return s;
    }

    // Prefer explicit load refs when present; otherwise use notification `_id`.
    final direct = pick(json['loadId']) ??
        pick(json['load_id']) ??
        pick(json['loadMongoId']) ??
        pick(json['mongoLoadId']) ??
        pick(json['relatedId']) ??
        pick(json['entityId']) ??
        pick(json['referenceId']) ??
        pick(json['refId']) ??
        pick(json['resourceId']);
    if (direct != null) return direct;

    final loadField = json['load'];
    if (loadField is String) {
      final s = pick(loadField);
      if (s != null) return s;
    } else if (loadField is Map) {
      final map = Map<String, dynamic>.from(loadField);
      final fromLoad = pick(map['_id']) ??
          pick(map['id']) ??
          pick(map['loadId']) ??
          pick(map['load_id']);
      if (fromLoad != null) return fromLoad;
    }

    for (final key in ['data', 'meta', 'payload', 'reference', 'body']) {
      final nested = json[key];
      if (nested is Map) {
        final map = Map<String, dynamic>.from(nested);
        final fromNested = pick(map['loadId']) ??
            pick(map['load_id']) ??
            pick(map['loadMongoId']) ??
            pick(map['_id']) ??
            pick(map['id']);
        if (fromNested != null) return fromNested;

        final nestedLoad = map['load'];
        if (nestedLoad is String) {
          final s = pick(nestedLoad);
          if (s != null) return s;
        } else if (nestedLoad is Map) {
          final lm = Map<String, dynamic>.from(nestedLoad);
          final fromNestedLoad = pick(lm['_id']) ??
              pick(lm['id']) ??
              pick(lm['loadId']);
          if (fromNestedLoad != null) return fromNestedLoad;
        }
      }
    }

    // Backend: use notification `_id` as the load id for GET /load/:id
    return pick(json['_id']) ?? pick(json['id']);
  }

  AppNotification copyWith({bool? viewStatus}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      viewStatus: viewStatus ?? this.viewStatus,
      createdAt: createdAt,
      loadId: loadId,
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
