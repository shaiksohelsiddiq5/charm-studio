class Campaign {
  final String id;
  final String title;
  final String client;
  final String category;
  final String productType;
  final String contentType;
  final String platform;
  final String aspectRatio;
  final String visualStyle;
  final List<String> requiredTools;
  final int budget;
  final String currency;
  final String deadline;
  final String status;
  final int applicantsCount;
  final String thumbnail;
  final String description;
  final List<String> deliverables;
  final String commercialUsage;
  final String targetAudience;

  Campaign({
    required this.id,
    required this.title,
    required this.client,
    required this.category,
    required this.productType,
    required this.contentType,
    required this.platform,
    required this.aspectRatio,
    required this.visualStyle,
    required this.requiredTools,
    required this.budget,
    required this.currency,
    required this.deadline,
    required this.status,
    required this.applicantsCount,
    required this.thumbnail,
    required this.description,
    required this.deliverables,
    required this.commercialUsage,
    required this.targetAudience,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? '',
      client: json['client'] ?? json['brandName'] ?? '',
      category: json['category'] ?? json['productType'] ?? '',
      productType: json['productType'] ?? '',
      contentType: json['contentType'] ?? (json['contentTypes'] is List && (json['contentTypes'] as List).isNotEmpty ? json['contentTypes'][0] : ''),
      platform: json['platform'] ?? (json['targetPlatforms'] is List && (json['targetPlatforms'] as List).isNotEmpty ? json['targetPlatforms'][0] : ''),
      aspectRatio: json['aspectRatio'] ?? '9:16',
      visualStyle: json['visualStyle'] ?? json['desiredStyle'] ?? 'Cinematic',
      requiredTools: List<String>.from(json['requiredTools'] ?? json['preferredAITools'] ?? []),
      budget: json['budget'] ?? json['budgetMax'] ?? 50000,
      currency: json['currency'] ?? '₹',
      deadline: json['deadline'] is String ? json['deadline'] : (json['deadline']?.toString() ?? ''),
      status: json['status'] ?? 'Active',
      applicantsCount: json['applicantsCount'] ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'] ?? json['campaignDescription'] ?? '',
      deliverables: List<String>.from(json['deliverables'] ?? []),
      commercialUsage: json['commercialUsage'] ?? json['commercialUsageRequirements'] ?? 'Full Commercial Buyout',
      targetAudience: json['targetAudience'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'client': client,
      'category': category,
      'productType': productType,
      'contentType': contentType,
      'platform': platform,
      'aspectRatio': aspectRatio,
      'visualStyle': visualStyle,
      'requiredTools': requiredTools,
      'budget': budget,
      'currency': currency,
      'deadline': deadline,
      'status': status,
      'applicantsCount': applicantsCount,
      'thumbnail': thumbnail,
      'description': description,
      'deliverables': deliverables,
      'commercialUsage': commercialUsage,
      'targetAudience': targetAudience,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Campaign &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
