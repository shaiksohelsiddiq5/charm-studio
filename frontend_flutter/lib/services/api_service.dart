import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/creator_model.dart';
import '../models/campaign_model.dart';
import '../models/message_model.dart';
import '../models/user_account_model.dart';
import 'mock_data_service.dart';

class ApiService {
  static const String baseUrl = 'https://charm-studio-backend.onrender.com/api';

  static Future<List<Creator>> fetchCreators({
    String? search,
    String? specialization,
    String? tool,
    String? style,
    String? campaignId,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (specialization != null && specialization != 'All') queryParams['specialization'] = specialization;
      if (tool != null && tool != 'All') queryParams['tool'] = tool;
      if (style != null && style != 'All') queryParams['style'] = style;
      if (campaignId != null) queryParams['campaignId'] = campaignId;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final uri = Uri.parse('$baseUrl/creators').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = data['creators'] ?? data['data'];
        if (rawList is List) {
          return rawList
              .map((item) => Creator.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Backend unavailable; fallback to offline mock data
    }
    return MockDataService.getInitialCreators();
  }

  static Future<List<Campaign>> fetchCampaigns() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/campaigns')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawList = data['campaigns'] ?? data['data'];
        if (rawList is List) {
          final seen = <String>{};
          return rawList
              .map((item) => Campaign.fromJson(item as Map<String, dynamic>))
              .where((c) => c.id.isNotEmpty && seen.add(c.id))
              .toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return MockDataService.getInitialCampaigns();
  }

  static Future<Map<String, dynamic>?> generateBrief(dynamic input) async {
    String promptText = '';
    if (input is String) {
      promptText = input;
    } else if (input is Map<String, dynamic>) {
      promptText = input['prompt'] ?? input['description'] ?? input['name'] ?? '';
      if (input['name'] != null && input['description'] != null && promptText != input['name']) {
        promptText = '${input['name']}: ${input['description']}';
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/campaigns/ai-brief'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': promptText}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        if (data['brief'] != null && data['brief'] is Map<String, dynamic>) {
          return data['brief'] as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Offline fallback brief
    }

    final formMap = input is Map<String, dynamic> ? input : <String, dynamic>{};
    return {
      'campaignTitle': formMap['name'] ?? 'Summer Cold-Drink Campaign',
      'productDescription': promptText.isNotEmpty ? promptText : 'High-energy commercial capturing chilled beverage with condensation droplets and citrus splash.',
      'contentRequirements': 'High resolution visual production with photorealistic liquid dynamics.',
      'suggestedVisualStyles': ['Cinematic', 'Photorealistic', 'Vibrant'],
      'suggestedDeliverables': [
        '2x 15-second Vertical Video Ads (9:16)',
        '4x 4K Feed Product Stills with condensation detail (1:1)',
        'Prompt sequences and camera trajectory logs'
      ],
      'requiredSkills': ['AI Video Generation', 'Liquid VFX', 'Color Grading'],
      'preferredAITools': ['Runway Gen-3', 'Midjourney v6', 'Luma Dream Machine'],
      'suggestedTimeline': '7-10 business days',
      'questionsAboutMissingInformation': [
        'Are there specific hex brand colors required for the bottle label?',
        'Do you require raw generation seed values and prompt engineering manifests?'
      ],
      'executiveSummary': 'High-energy vertical video commercial capturing chilled glass condensation, ice cubes, and fresh citrus slice splash for Instagram Reels & TikTok.',
      'creativeDirection': {
        'lighting': 'Studio rim lighting with condensation macro-glare and back illumination.',
        'cameraAndComposition': '120fps high-speed fluid dynamics, 85mm macro lens.',
        'negativePrompts': '--no cartoon, low resolution, plastic texture, artifacts.',
      },
      'metadata': {
        'model': 'local_deterministic_fallback',
        'source': 'template_fallback',
        'generatedAt': DateTime.now().toIso8601String(),
      }
    };
  }

  static Future<Campaign> createCampaign(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/campaigns'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final campaignJson = data['data'] ?? data['campaign'];
        if (campaignJson is Map<String, dynamic>) {
          return Campaign.fromJson(campaignJson);
        }
      }
    } catch (_) {
      // Fallback to local
    }

    // Local fallback object
    return Campaign(
      id: payload['id'] ?? 'camp-${DateTime.now().millisecondsSinceEpoch}',
      title: payload['title'] ?? 'Untitled Campaign',
      client: payload['brandName'] ?? payload['client'] ?? 'Aura Beverages Co.',
      category: payload['productType'] ?? payload['category'] ?? 'Beverage & Commercial',
      productType: payload['productType'] ?? 'Beverage',
      contentType: (payload['contentTypes'] is List && (payload['contentTypes'] as List).isNotEmpty)
          ? payload['contentTypes'][0]
          : (payload['contentType'] ?? 'AI Video'),
      platform: (payload['targetPlatforms'] is List && (payload['targetPlatforms'] as List).isNotEmpty)
          ? payload['targetPlatforms'][0]
          : (payload['platform'] ?? 'Instagram Reels & TikTok'),
      aspectRatio: payload['aspectRatio'] ?? '9:16',
      visualStyle: payload['desiredStyle'] ?? payload['visualStyle'] ?? 'Cinematic',
      requiredTools: List<String>.from(payload['preferredAITools'] ?? payload['requiredTools'] ?? ['Runway Gen-3']),
      budget: (payload['budgetMax'] ?? payload['budget'] ?? 50000) as int,
      currency: payload['currency'] ?? '₹',
      deadline: payload['deadline']?.toString() ?? '2026-10-28',
      status: payload['status'] ?? 'Active',
      applicantsCount: 0,
      thumbnail: payload['thumbnail'] ?? 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
      description: payload['campaignDescription'] ?? payload['description'] ?? '',
      deliverables: List<String>.from(payload['deliverables'] ?? ['Hero 15s Vertical Video Ad']),
      commercialUsage: payload['commercialUsageRequirements'] ?? payload['commercialUsage'] ?? 'Full Commercial Buyout',
      targetAudience: payload['targetAudience'] ?? 'Consumers & Social Audience',
    );
  }

  static Future<bool> addToShortlist(String campaignId, String creatorId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shortlists'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'campaignId': campaignId, 'creatorId': creatorId}),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeFromShortlist(String campaignId, String creatorId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/shortlists/$campaignId/$creatorId'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> fetchShortlists(String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shortlists/$campaignId'),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'];
        if (list is List) {
          return list
              .map((item) => (item['creatorId'] ?? item['creator']?['_id'] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // Fallback
    }
    return [];
  }

  // ==========================================
  // Messaging & Conversations
  // ==========================================
  static Future<List<Conversation>> fetchConversations({String? authToken}) async {
    try {
      final headers = <String, String>{};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'];
        if (list is List) {
          return list
              .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Backend offline fallback handled by state
    }
    return [];
  }

  static Future<List<Message>> fetchMessages(String conversationId, {String? authToken}) async {
    try {
      final headers = <String, String>{};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'];
        if (list is List) {
          return list
              .map((item) => Message.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Offline fallback
    }
    return [];
  }

  static Future<Message?> sendMessage(
    String conversationId,
    String text, {
    String? recipientId,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final bodyMap = <String, dynamic>{'text': text};
      if (recipientId != null && recipientId.isNotEmpty) {
        bodyMap['recipientId'] = recipientId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: headers,
        body: json.encode(bodyMap),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return Message.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Error handled by state
    }
    return null;
  }

  static Future<Message?> simulateCreatorReply(
    String conversationId, {
    String? customText,
  }) async {
    try {
      final bodyMap = <String, dynamic>{};
      if (customText != null) bodyMap['customText'] = customText;

      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/simulate-reply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyMap),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return Message.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Error
    }
    return null;
  }

  static Future<Map<String, dynamic>?> suggestReply(
    String conversationId, {
    String? prompt,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final bodyMap = <String, dynamic>{};
      if (prompt != null && prompt.trim().isNotEmpty) {
        bodyMap['prompt'] = prompt.trim();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/suggest-reply'),
        headers: headers,
        body: json.encode(bodyMap),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['suggestion'] != null) {
          return {
            'suggestion': data['data']['suggestion'].toString(),
            'source': data['data']['metadata']?['source']?.toString() ?? 'gemini',
            'model': data['data']['metadata']?['model']?.toString() ?? 'gemini-3.8-flash',
          };
        }
      }
    } catch (_) {
      // Offline fallback handled in state
    }
    return null;
  }

  // ==========================================
  // Auth & Demo Accounts
  // ==========================================
  static Future<List<UserAccount>> fetchDemoAccounts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/demo-accounts'),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final list = data['data'];
        if (list is List) {
          return list
              .map((item) => UserAccount.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {
      // Fallback
    }

    return const [
      UserAccount.defaultBrand,
      UserAccount(
        id: 'demo_creator_user_1',
        name: 'Aria Chen',
        email: 'aria@ai-creators.io',
        role: 'creator',
        companyName: 'AI Culinary Studio',
        avatarText: 'AC',
        description: 'AI Culinary Visualist & Commercial Specialist',
      ),
      UserAccount(
        id: 'demo_creator_user_2',
        name: 'Marcus Vance',
        email: 'marcus@cinematic-ai.com',
        role: 'creator',
        companyName: 'Cinematic AI Productions',
        avatarText: 'MV',
        description: 'Sci-Fi & Commercial Filmmaker',
      ),
      UserAccount(
        id: 'demo_creator_user_3',
        name: 'Elena Rostova',
        email: 'elena@anim-lab.studio',
        role: 'creator',
        companyName: 'Anim Lab Studio',
        avatarText: 'ER',
        description: 'Hybrid AI Animator & Motion Graphics',
      ),
      UserAccount(
        id: 'demo_creator_user_6',
        name: 'Aarav Sharma',
        email: 'aarav@generative-motion.ai',
        role: 'creator',
        companyName: 'Generative Motion VFX',
        avatarText: 'AS',
        description: 'Macro Liquid VFX & Runway Gen-3 Director',
      ),
    ];
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Fallback handled in AppState
    }
    return null;
  }
}
