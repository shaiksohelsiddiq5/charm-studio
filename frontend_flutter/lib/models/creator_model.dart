class PortfolioItem {
  final String id;
  final String title;
  final String category; // 'image', 'video', 'animation'
  final String contentType;
  final String aspectRatio;
  final List<String> tools;
  final String thumbnail;
  final String description;
  final String clientType;
  final String views;
  final List<String> tags;

  PortfolioItem({
    required this.id,
    required this.title,
    required this.category,
    required this.contentType,
    required this.aspectRatio,
    required this.tools,
    required this.thumbnail,
    required this.description,
    required this.clientType,
    required this.views,
    required this.tags,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    String thumb = (json['thumbnail'] ?? json['thumbnailUrl'] ?? '').toString();
    if (thumb.startsWith('http') && !thumb.contains('?')) {
      thumb = '$thumb?auto=format&fit=crop&w=800&q=80';
    }

    final catRaw = (json['category'] ?? json['contentType'] ?? 'image').toString().toLowerCase();
    final cat = catRaw.contains('video') ? 'video' : (catRaw.contains('animation') ? 'animation' : 'image');

    return PortfolioItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? '',
      category: cat,
      contentType: json['contentType'] ?? (cat == 'video' ? 'AI Video' : 'AI Visual'),
      aspectRatio: json['aspectRatio'] ?? '16:9',
      tools: List<String>.from(json['tools'] ?? json['toolsUsed'] ?? []),
      thumbnail: thumb,
      description: json['description'] ?? '',
      clientType: json['clientType'] ?? 'Commercial Client',
      views: json['views'] ?? '1.2M',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  double get aspectRatioValue {
    final clean = aspectRatio.trim();
    if (clean == '16:9') return 16 / 9;
    if (clean == '9:16') return 9 / 16;
    if (clean == '1:1') return 1.0;
    if (clean == '4:5') return 4 / 5;
    if (clean == '21:9') return 21 / 9;
    if (clean.contains(':')) {
      final parts = clean.split(':');
      final w = double.tryParse(parts[0]);
      final h = double.tryParse(parts[1]);
      if (w != null && h != null && h > 0) return w / h;
    }
    return 16 / 9;
  }

  bool get isVertical => aspectRatioValue < 0.9;
  bool get isSquare => (aspectRatioValue - 1.0).abs() < 0.1;
  bool get isLandscape => aspectRatioValue > 1.1;
}

class Creator {
  final String id;
  final String name;
  final String handle;
  final bool verified;
  final String avatar;
  final String coverImage;
  final String location;
  final String bio;
  final List<String> specializations;
  final List<String> aiTools;
  final List<String> visualStyles;
  final List<String> supportedFormats;
  final int startingPrice;
  final String currency;
  final int turnaroundDays;
  final String availability;
  final String commercialRights;
  final double rating;
  final int completedProjects;
  final List<PortfolioItem> portfolio;

  // Matching properties
  int matchScore;
  Map<String, dynamic>? matchBreakdown;
  List<String> matchExplanations;
  bool isShortlisted;

  Creator({
    required this.id,
    required this.name,
    required this.handle,
    required this.verified,
    required this.avatar,
    required this.coverImage,
    required this.location,
    required this.bio,
    required this.specializations,
    required this.aiTools,
    required this.visualStyles,
    required this.supportedFormats,
    required this.startingPrice,
    required this.currency,
    required this.turnaroundDays,
    required this.availability,
    required this.commercialRights,
    required this.rating,
    required this.completedProjects,
    required this.portfolio,
    this.matchScore = 85,
    this.matchBreakdown,
    this.matchExplanations = const [],
    this.isShortlisted = false,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? json['displayName'] ?? '';
    final String handle = (json['handle'] != null && (json['handle'] as String).isNotEmpty)
        ? json['handle']
        : (json['email'] != null && (json['email'] as String).contains('@')
            ? '@${(json['email'] as String).split('@').first}'
            : '@${name.toLowerCase().replaceAll(' ', '_')}');

    final rawPortfolio = json['portfolio'];
    final List<PortfolioItem> portfolioList = [];
    if (rawPortfolio is List) {
      for (final item in rawPortfolio) {
        if (item is Map<String, dynamic>) {
          portfolioList.add(PortfolioItem.fromJson(item));
        }
      }
    }

    int startingPrice = 25000;
    if (json['startingPrice'] is num) {
      startingPrice = (json['startingPrice'] as num).toInt();
    } else if (json['price'] is num) {
      startingPrice = (json['price'] as num).toInt();
    } else if (json['pricing'] is Map && json['pricing']['startingAt'] is num) {
      startingPrice = (json['pricing']['startingAt'] as num).toInt();
    }

    String currency = '₹';
    if (json['currency'] is String && (json['currency'] as String).isNotEmpty) {
      currency = json['currency'];
    } else if (json['pricing'] is Map && json['pricing']['currency'] is String) {
      currency = json['pricing']['currency'];
    }

    final List<String> specializations = [];
    if (json['specializations'] is List) {
      specializations.addAll(List<String>.from(json['specializations']));
    } else if (json['specialization'] is List) {
      specializations.addAll(List<String>.from(json['specialization']));
    }

    final List<String> supportedFormats = [];
    if (json['supportedFormats'] is List) {
      supportedFormats.addAll(List<String>.from(json['supportedFormats']));
    } else if (json['contentTypes'] is List) {
      supportedFormats.addAll(List<String>.from(json['contentTypes']));
    }
    if (supportedFormats.isEmpty) {
      supportedFormats.addAll(['Reels (9:16)', 'Video Ad (16:9)', 'Feed Stills (1:1)']);
    }

    final List<String> visualStyles = [];
    if (json['visualStyles'] is List) {
      visualStyles.addAll(List<String>.from(json['visualStyles']));
    } else if (json['contentStyle'] is String) {
      visualStyles.add(json['contentStyle']);
    }
    if (visualStyles.isEmpty) {
      visualStyles.addAll(['Cinematic', 'Photorealistic', 'Vibrant']);
    }

    final String avatar = (json['avatar'] is String && (json['avatar'] as String).isNotEmpty)
        ? json['avatar']
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';

    final String coverImage = (json['coverImage'] is String && (json['coverImage'] as String).isNotEmpty)
        ? json['coverImage']
        : 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=1400&q=80';

    return Creator(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: name,
      handle: handle,
      verified: json['verified'] ?? true,
      avatar: avatar,
      coverImage: coverImage,
      location: json['location'] ?? 'Global',
      bio: json['bio'] ?? '',
      specializations: specializations,
      aiTools: List<String>.from(json['aiTools'] ?? []),
      visualStyles: visualStyles,
      supportedFormats: supportedFormats,
      startingPrice: startingPrice,
      currency: currency,
      turnaroundDays: (json['turnaroundDays'] is num) ? (json['turnaroundDays'] as num).toInt() : 3,
      availability: (json['availability'] is String && (json['availability'] as String).isNotEmpty)
          ? (json['availability'] == 'available' ? 'Available Now' : json['availability'])
          : 'Available Now',
      commercialRights: json['commercialRights'] ?? 'Full Commercial Buyout Included',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.95,
      completedProjects: (json['completedProjects'] is num)
          ? (json['completedProjects'] as num).toInt()
          : (portfolioList.length * 8 + 14),
      portfolio: portfolioList,
      matchScore: (json['matchScore'] is num) ? (json['matchScore'] as num).toInt() : 85,
      matchBreakdown: json['matchBreakdown'] as Map<String, dynamic>?,
      matchExplanations: List<String>.from(json['matchExplanations'] ?? []),
      isShortlisted: json['isShortlisted'] ?? false,
    );
  }
}
