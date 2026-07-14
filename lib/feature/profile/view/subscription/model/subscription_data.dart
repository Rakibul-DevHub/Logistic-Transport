/**
class SubscriptionPlanResponse {
  final int code;
  final String? message;
  final List<SubscriptionPlan> data;

  SubscriptionPlanResponse({
    required this.code,
    this.message,
    required this.data,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null
          ? List<SubscriptionPlan>.from(
          json['data'].map((item) => SubscriptionPlan.fromJson(item)))
          : [],
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String title;
  final String slug;
  final String stripeProductId;
  final String stripePriceId;
  final double price;
  final double regularPrice;
  final int driverLimit;
  final int durationInMonths;
  final bool autoRenewalAvailable;
  final String status;
  final String createdAt;
  final String updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.slug,
    required this.stripeProductId,
    required this.stripePriceId,
    required this.price,
    required this.regularPrice,
    required this.driverLimit,
    required this.durationInMonths,
    required this.autoRenewalAvailable,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      stripeProductId: json['stripeProductId'] ?? '',
      stripePriceId: json['stripePriceId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      driverLimit: json['driverLimit'] ?? 0,
      durationInMonths: json['durationInMonths'] ?? 0,
      autoRenewalAvailable: json['autoRenewalAvailable'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  // Helper to get savings percentage
  double get savingsPercentage {
    if (regularPrice > 0 && price < regularPrice) {
      return ((regularPrice - price) / regularPrice) * 100;
    }
    return 0;
  }

  // Helper to get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedRegularPrice => '\$${regularPrice.toStringAsFixed(2)}';
}*/





///
///
///
/// todo:: updating the data..
///
///
///
///




// lib/feature/profile/view/subscription/model/subscription_data.dart

class SubscriptionPlanResponse {
  final int code;
  final String? message;
  final List<SubscriptionPlan> data;

  SubscriptionPlanResponse({
    required this.code,
    this.message,
    required this.data,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((item) => SubscriptionPlan.fromJson(item)).toList()
          : [],
    );
  }
}

// ✅ New model for Active Plan response
class ActivePlanResponse {
  final int code;
  final String? message;
  final ActivePlanData? data;

  ActivePlanResponse({
    required this.code,
    this.message,
    this.data,
  });

  factory ActivePlanResponse.fromJson(Map<String, dynamic> json) {
    return ActivePlanResponse(
      code: json['code'] ?? 0,
      message: json['message'],
      data: json['data'] != null ? ActivePlanData.fromJson(json['data']) : null,
    );
  }
}

// ✅ Active Plan Data (contains nested planId)
class ActivePlanData {
  final String id;
  final String userId;
  final SubscriptionPlan planId;
  final String stripeProductId;
  final String stripePriceId;
  final String stripeSubscriptionId;
  final double price;
  final int driverLimit;
  final bool cancelAtPeriodEnd;
  final String startsAt;
  final String expiresAt;
  final String status;
  final String createdAt;
  final String updatedAt;

  ActivePlanData({
    required this.id,
    required this.userId,
    required this.planId,
    required this.stripeProductId,
    required this.stripePriceId,
    required this.stripeSubscriptionId,
    required this.price,
    required this.driverLimit,
    required this.cancelAtPeriodEnd,
    required this.startsAt,
    required this.expiresAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ActivePlanData.fromJson(Map<String, dynamic> json) {
    return ActivePlanData(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      planId: json['planId'] != null
          ? SubscriptionPlan.fromJson({
        ...json['planId'],
        'expiresAt': json['expiresAt'] ?? '',
        'startsAt': json['startsAt'] ?? '', // ✅ Pass startsAt
      })
          : SubscriptionPlan(
        id: '',
        title: '',
        slug: '',
        stripeProductId: '',
        stripePriceId: '',
        price: 0,
        regularPrice: 0,
        driverLimit: 0,
        durationInMonths: 0,
        autoRenewalAvailable: false,
        status: '',
        createdAt: '',
        updatedAt: '',
        expiresAt: '',
        startsAt: '',
      ),
      stripeProductId: json['stripeProductId'] ?? '',
      stripePriceId: json['stripePriceId'] ?? '',
      stripeSubscriptionId: json['stripeSubscriptionId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      driverLimit: json['driverLimit'] ?? 0,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] ?? false,
      startsAt: json['startsAt'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

// lib/feature/profile/view/subscription/model/subscription_data.dart

class SubscriptionPlan {
  final String id;
  final String title;
  final String slug;
  final String stripeProductId;
  final String stripePriceId;
  final double price;
  final double regularPrice;
  final int driverLimit;
  final int durationInMonths;
  final bool autoRenewalAvailable;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String expiresAt;
  final String startsAt; // ✅ Add this field

  SubscriptionPlan({
    required this.id,
    required this.title,
    required this.slug,
    required this.stripeProductId,
    required this.stripePriceId,
    required this.price,
    required this.regularPrice,
    required this.driverLimit,
    required this.durationInMonths,
    required this.autoRenewalAvailable,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt = '',
    this.startsAt = '', // ✅ Default empty string
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      stripeProductId: json['stripeProductId'] ?? '',
      stripePriceId: json['stripePriceId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      regularPrice: (json['regularPrice'] ?? 0).toDouble(),
      driverLimit: json['driverLimit'] ?? 0,
      durationInMonths: json['durationInMonths'] ?? 0,
      autoRenewalAvailable: json['autoRenewalAvailable'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      startsAt: json['startsAt'] ?? '', // ✅ Parse startsAt
    );
  }

  // Helper to get savings percentage
  double get savingsPercentage {
    if (regularPrice > 0 && price < regularPrice) {
      return ((regularPrice - price) / regularPrice) * 100;
    }
    return 0;
  }

  // Helper to get formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  String get formattedRegularPrice => '\$${regularPrice.toStringAsFixed(2)}';
}