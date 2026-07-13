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
}