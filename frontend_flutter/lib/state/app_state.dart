import 'package:flutter/material.dart';
import '../models/creator_model.dart';
import '../models/campaign_model.dart';
import '../models/message_model.dart';
import '../models/user_account_model.dart';
import '../services/mock_data_service.dart';
import '../services/matching_service.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  String _currentRoute = 'dashboard';
  String get currentRoute => _currentRoute;

  // User Authentication & Demo Account State
  UserAccount _currentUser = UserAccount.defaultBrand;
  UserAccount get currentUser => _currentUser;

  String? _authToken;
  String? get authToken => _authToken;

  bool _isAuthenticated = true;
  bool get isAuthenticated => _isAuthenticated;

  List<UserAccount> _demoAccounts = [];
  List<UserAccount> get demoAccounts => _demoAccounts;

  // Conversations & Direct Messaging
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  Conversation? _activeConversation;
  Conversation? get activeConversation => _activeConversation;

  List<Message> _messages = [];
  List<Message> get messages => _messages;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  String? _messageError;
  String? get messageError => _messageError;

  bool _isSuggestingReply = false;
  bool get isSuggestingReply => _isSuggestingReply;

  String? _suggestedReply;
  String? get suggestedReply => _suggestedReply;

  String _suggestedReplySource = 'gemini';
  String get suggestedReplySource => _suggestedReplySource;

  String? _suggestedReplyError;
  String? get suggestedReplyError => _suggestedReplyError;

  List<Creator> _creators = [];
  List<Creator> get creators => _filteredAndRankedCreators;

  List<Campaign> _campaigns = [];
  List<Campaign> get campaigns => _campaigns;

  Campaign? _activeCampaign;
  Campaign? get activeCampaign => _activeCampaign;

  Creator? _selectedCreator;
  Creator? get selectedCreator => _selectedCreator;

  final Set<String> _shortlistIds = {'creator-1', 'creator-2'};
  Set<String> get shortlistIds => _shortlistIds;
  int get shortlistCount => _shortlistIds.length;

  // Filter & Search states
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _filterSpecialization = 'All';
  String get filterSpecialization => _filterSpecialization;

  String _filterTool = 'All';
  String get filterTool => _filterTool;

  String _filterStyle = 'All';
  String get filterStyle => _filterStyle;

  String _filterFormat = 'All';
  String get filterFormat => _filterFormat;

  double _filterMaxBudget = 100000;
  double get filterMaxBudget => _filterMaxBudget;

  String _sortBy = 'relevance'; // 'relevance', 'price_asc', 'price_desc', 'experience'
  String get sortBy => _sortBy;

  bool _isGridView = true;
  bool get isGridView => _isGridView;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppState() {
    _initializeData();
  }

  void _initializeData() {
    _creators = MockDataService.getInitialCreators();
    final initialCampaigns = MockDataService.getInitialCampaigns();
    final seen = <String>{};
    _campaigns = initialCampaigns.where((c) => c.id.isNotEmpty && seen.add(c.id)).toList();
    if (_campaigns.isNotEmpty) {
      _activeCampaign = _campaigns.first;
    } else {
      _activeCampaign = null;
    }
    _recalculateMatches();
    loadConversations();
    fetchDemoAccounts();
    notifyListeners();
    loadDataFromBackend();
  }

  Future<void> loadDataFromBackend() async {
    _isLoading = true;
    notifyListeners();
    try {
      final fetchedCreators = await ApiService.fetchCreators();
      final fetchedCampaigns = await ApiService.fetchCampaigns();
      if (fetchedCreators.isNotEmpty) {
        _creators = fetchedCreators;
      }
      if (fetchedCampaigns.isNotEmpty) {
        final seen = <String>{};
        _campaigns = fetchedCampaigns.where((c) => c.id.isNotEmpty && seen.add(c.id)).toList();
        if (_campaigns.isNotEmpty) {
          if (_activeCampaign != null && _campaigns.any((c) => c.id == _activeCampaign!.id)) {
            _activeCampaign = _campaigns.firstWhere((c) => c.id == _activeCampaign!.id);
          } else {
            _activeCampaign = _campaigns.first;
          }
        } else {
          _activeCampaign = null;
        }
      }
      _recalculateMatches();
      await fetchDemoAccounts();
      await loadConversations();
    } catch (_) {
      // Offline fallback: retains mock data
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateTo(String route, {Creator? creator}) {
    _currentRoute = route;
    if (creator != null) {
      _selectedCreator = creator;
    }
    notifyListeners();
  }

  void setActiveCampaign(Campaign campaign) {
    final match = _campaigns.where((c) => c.id == campaign.id);
    _activeCampaign = match.isNotEmpty ? match.first : campaign;
    _recalculateMatches();
    notifyListeners();
  }

  void setActiveCampaignById(String? campaignId) {
    if (campaignId == null) {
      _activeCampaign = _campaigns.isNotEmpty ? _campaigns.first : null;
    } else {
      final match = _campaigns.where((c) => c.id == campaignId);
      if (match.isNotEmpty) {
        _activeCampaign = match.first;
      } else {
        _activeCampaign = _campaigns.isNotEmpty ? _campaigns.first : null;
      }
    }
    _recalculateMatches();
    notifyListeners();
  }

  void _recalculateMatches() {
    if (_activeCampaign == null) return;
    for (final creator in _creators) {
      final match = MatchingService.calculateMatch(creator, _activeCampaign!);
      creator.matchScore = match.score;
      creator.matchBreakdown = {
        'portfolioRelevance': match.breakdown.portfolioRelevance,
        'skillsSpecialization': match.breakdown.skillsSpecialization,
        'visualStyle': match.breakdown.visualStyle,
        'aiTools': match.breakdown.aiTools,
        'budgetCompatibility': match.breakdown.budgetCompatibility,
        'formatAndDelivery': match.breakdown.formatAndDelivery,
      };
      creator.matchExplanations = match.explanations;
      creator.isShortlisted = _shortlistIds.contains(creator.id);
    }
  }

  void toggleShortlist(String creatorId) {
    if (_shortlistIds.contains(creatorId)) {
      _shortlistIds.remove(creatorId);
    } else {
      _shortlistIds.add(creatorId);
    }
    for (final c in _creators) {
      if (c.id == creatorId) {
        c.isShortlisted = _shortlistIds.contains(creatorId);
      }
    }
    notifyListeners();
  }

  bool isShortlisted(String creatorId) => _shortlistIds.contains(creatorId);

  List<Creator> get shortlistedCreators {
    return _creators.where((c) => _shortlistIds.contains(c.id)).toList();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterSpecialization(String val) {
    _filterSpecialization = val;
    notifyListeners();
  }

  void setFilterTool(String val) {
    _filterTool = val;
    notifyListeners();
  }

  void setFilterStyle(String val) {
    _filterStyle = val;
    notifyListeners();
  }

  void setFilterFormat(String val) {
    _filterFormat = val;
    notifyListeners();
  }

  void setFilterMaxBudget(double val) {
    _filterMaxBudget = val;
    notifyListeners();
  }

  void setSortBy(String val) {
    _sortBy = val;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void addCampaign(Campaign campaign) {
    _campaigns.removeWhere((c) => c.id == campaign.id);
    _campaigns.insert(0, campaign);
    _activeCampaign = campaign;
    _recalculateMatches();
    notifyListeners();
  }

  List<Creator> get _filteredAndRankedCreators {
    List<Creator> list = List.from(_creators);

    // Search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((c) {
        final inName = c.name.toLowerCase().contains(q);
        final inBio = c.bio.toLowerCase().contains(q);
        final inSpec = c.specializations.any((s) => s.toLowerCase().contains(q));
        final inTools = c.aiTools.any((t) => t.toLowerCase().contains(q));
        return inName || inBio || inSpec || inTools;
      }).toList();
    }

    // Specialization filter
    if (_filterSpecialization != 'All') {
      list = list.where((c) =>
        c.specializations.any((s) => s.toLowerCase().contains(_filterSpecialization.toLowerCase()))
      ).toList();
    }

    // AI Tool filter
    if (_filterTool != 'All') {
      list = list.where((c) =>
        c.aiTools.any((t) => t.toLowerCase().contains(_filterTool.toLowerCase()))
      ).toList();
    }

    // Visual Style filter
    if (_filterStyle != 'All') {
      list = list.where((c) =>
        c.visualStyles.any((s) => s.toLowerCase().contains(_filterStyle.toLowerCase()))
      ).toList();
    }

    // Format filter
    if (_filterFormat != 'All') {
      list = list.where((c) =>
        c.supportedFormats.any((f) => f.toLowerCase().contains(_filterFormat.toLowerCase()))
      ).toList();
    }

    // Budget
    list = list.where((c) => c.startingPrice <= _filterMaxBudget).toList();

    // Sorting
    if (_sortBy == 'price_asc') {
      list.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    } else if (_sortBy == 'price_desc') {
      list.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
    } else if (_sortBy == 'experience') {
      list.sort((a, b) => b.completedProjects.compareTo(a.completedProjects));
    } else {
      // Relevance (match score)
      list.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    }

    return list;
  }

  // ==========================================
  // User Authentication & Demo Account Methods
  // ==========================================

  Future<void> fetchDemoAccounts() async {
    try {
      final accounts = await ApiService.fetchDemoAccounts();
      if (accounts.isNotEmpty) {
        _demoAccounts = accounts;
      } else {
        _demoAccounts = List.from(UserAccount.defaultDemoAccounts);
      }
    } catch (_) {
      _demoAccounts = List.from(UserAccount.defaultDemoAccounts);
    }
    notifyListeners();
  }

  void switchUser(UserAccount account) {
    _currentUser = account;
    _authToken = account.id;
    _isAuthenticated = true;
    _activeConversation = null;
    _messages = [];
    loadConversations();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      final res = await ApiService.login(email.trim(), password);
      if (res != null && res['token'] != null) {
        _authToken = res['token'];
        if (res['user'] != null) {
          _currentUser = UserAccount.fromJson(res['user']);
        } else {
          final match = _demoAccounts.where((a) => a.email.toLowerCase() == email.trim().toLowerCase());
          _currentUser = match.isNotEmpty ? match.first : UserAccount.defaultBrand;
        }
        _isAuthenticated = true;
        _activeConversation = null;
        _messages = [];
        await loadConversations();
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Offline fallback
    }

    final match = _demoAccounts.where((a) => a.email.toLowerCase() == email.trim().toLowerCase());
    if (match.isNotEmpty) {
      _currentUser = match.first;
      _authToken = match.first.id;
      _isAuthenticated = true;
      _activeConversation = null;
      _messages = [];
      await loadConversations();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _authToken = null;
    _activeConversation = null;
    _messages = [];
    _currentRoute = 'dashboard';
    notifyListeners();
  }

  // ==========================================
  // Direct Messaging & Conversations Methods
  // ==========================================

  Future<void> loadConversations() async {
    try {
      final fetched = await ApiService.fetchConversations(authToken: _authToken);
      if (fetched.isNotEmpty) {
        _conversations = fetched;
      } else {
        _conversations = _getFallbackConversations();
      }
    } catch (_) {
      _conversations = _getFallbackConversations();
    }

    if (_activeConversation != null) {
      final match = _conversations.where((c) => c.id == _activeConversation!.id);
      if (match.isNotEmpty) {
        _activeConversation = match.first;
      } else if (_conversations.isNotEmpty) {
        _activeConversation = _conversations.first;
      } else {
        _activeConversation = null;
      }
    } else if (_conversations.isNotEmpty) {
      _activeConversation = _conversations.first;
    }

    if (_activeConversation != null) {
      await loadMessagesForActiveConversation();
    }
    notifyListeners();
  }

  void selectConversation(Conversation conversation) {
    _activeConversation = conversation;
    loadMessagesForActiveConversation();
    notifyListeners();
  }

  void selectConversationByCreator(Creator creator) {
    final match = _conversations.where((c) =>
      c.participants.any((p) => p.userId == creator.id || p.name.toLowerCase() == creator.name.toLowerCase())
    );
    if (match.isNotEmpty) {
      _activeConversation = match.first;
      loadMessagesForActiveConversation();
    } else {
      final newConv = Conversation(
        id: 'conv_c_${creator.id}_${DateTime.now().millisecondsSinceEpoch}',
        participants: [
          ConversationParticipant(
            userId: _currentUser.id,
            name: _currentUser.name,
            role: _currentUser.role,
            avatar: _currentUser.avatar,
          ),
          ConversationParticipant(
            userId: creator.id,
            name: creator.name,
            role: 'creator',
            avatar: creator.avatar,
          ),
        ],
        campaignTitle: _activeCampaign?.title ?? 'Direct Creator Collaboration',
        lastMessageText: 'Started new conversation',
        unreadCount: 0,
        lastMessageTime: DateTime.now(),
      );
      _conversations.insert(0, newConv);
      _activeConversation = newConv;
      _messages = [
        Message(
          id: 'init_msg_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: newConv.id,
          senderId: _currentUser.id,
          senderName: _currentUser.name,
          senderRole: _currentUser.role,
          recipientId: creator.id,
          text: 'Hi ${creator.name}, we would love to collaborate with you on our upcoming creative campaign!',
          createdAt: DateTime.now(),
        ),
      ];
    }
    navigateTo('messages');
  }

  Future<void> loadMessagesForActiveConversation() async {
    final currentConv = _activeConversation;
    if (currentConv == null) {
      _messages = [];
      notifyListeners();
      return;
    }
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();

    try {
      final fetched = await ApiService.fetchMessages(currentConv.id, authToken: _authToken);
      if (fetched.isNotEmpty) {
        _messages = fetched;
      } else {
        _messages = _getFallbackMessagesForConversation(currentConv.id);
      }
    } catch (_) {
      _messages = _getFallbackMessagesForConversation(currentConv.id);
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _activeConversation == null) {
      return false;
    }
    _isSendingMessage = true;
    _messageError = null;
    notifyListeners();

    final otherParticipant = _activeConversation!.getOtherParticipant(_currentUser.id);
    final recipientId = otherParticipant.userId;

    try {
      final newMsg = await ApiService.sendMessage(
        _activeConversation!.id,
        trimmed,
        recipientId: recipientId,
        authToken: _authToken,
      );

      if (newMsg != null) {
        _messages.add(newMsg);
        _activeConversation!.lastMessageText = trimmed;
        _activeConversation!.lastMessageTime = DateTime.now();
        _isSendingMessage = false;
        notifyListeners();
        return true;
      } else {
        final localMsg = Message(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          conversationId: _activeConversation!.id,
          senderId: _currentUser.id,
          senderName: _currentUser.name,
          senderRole: _currentUser.role,
          recipientId: recipientId,
          text: trimmed,
          createdAt: DateTime.now(),
        );
        _messages.add(localMsg);
        _activeConversation!.lastMessageText = trimmed;
        _activeConversation!.lastMessageTime = DateTime.now();
        _isSendingMessage = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _messageError = 'Failed to send message: $e';
      _isSendingMessage = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> triggerSimulatedReply({String? promptHint}) async {
    if (_activeConversation == null) return false;

    final otherParticipant = _activeConversation!.getOtherParticipant(_currentUser.id);
    _isLoadingMessages = true;
    notifyListeners();

    try {
      final simMsg = await ApiService.simulateCreatorReply(
        _activeConversation!.id,
        customText: promptHint,
      );

      if (simMsg != null) {
        _messages.add(simMsg);
        _activeConversation!.lastMessageText = simMsg.text;
        _activeConversation!.lastMessageTime = DateTime.now();
        _isLoadingMessages = false;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Local fallback
    }

    final simMsg = Message(
      id: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _activeConversation!.id,
      senderId: otherParticipant.userId,
      senderName: otherParticipant.name,
      senderRole: otherParticipant.role,
      recipientId: _currentUser.id,
      text: "Thanks for reaching out! I've adjusted the color grading parameters and re-rendered the high-res styleframes for your campaign review.",
      createdAt: DateTime.now(),
      isSimulatedReply: true,
    );
    _messages.add(simMsg);
    _activeConversation!.lastMessageText = simMsg.text;
    _activeConversation!.lastMessageTime = DateTime.now();
    _isLoadingMessages = false;
    notifyListeners();
    return true;
  }

  void clearSuggestedReply() {
    _suggestedReply = null;
    _suggestedReplyError = null;
    notifyListeners();
  }

  Future<String?> getSuggestedReply(String conversationId, {String? userPrompt}) async {
    _isSuggestingReply = true;
    _suggestedReplyError = null;
    notifyListeners();

    try {
      final res = await ApiService.suggestReply(
        conversationId,
        prompt: userPrompt,
        authToken: _authToken,
      );

      if (res != null && res['suggestion'] != null) {
        _suggestedReply = res['suggestion'] as String;
        _suggestedReplySource = res['source'] as String? ?? 'gemini';
        _isSuggestingReply = false;
        notifyListeners();
        return _suggestedReply;
      }
    } catch (e) {
      // Fallback
    }

    final isBrand = _currentUser.isBrand;
    final otherParticipant = _activeConversation?.getOtherParticipant(_currentUser.id);
    final otherName = otherParticipant?.name ?? 'Collaborator';

    _suggestedReply = isBrand
        ? "Hi $otherName, thanks for the update! The latest direction looks great. Could you confirm if this includes 2 revision rounds on the final 9:16 cuts?"
        : "Hi $otherName, thank you for reaching out! I've prepped the Runway Gen-3 workflows for this style and can deliver the first cut within 3 days.";
    _suggestedReplySource = 'template_fallback';
    _isSuggestingReply = false;
    notifyListeners();
    return _suggestedReply;
  }

  List<Message> _getFallbackMessagesForConversation(String convId) {
    if (convId == 'conv_1') {
      return [
        Message(
          id: 'msg_f1',
          conversationId: 'conv_1',
          senderId: 'creator_aarav',
          senderName: 'Aarav Sharma',
          senderRole: 'creator',
          recipientId: 'user_aura',
          text: 'Hi Aura Beverages team! I reviewed your brief for the Summer Cold-Drink Campaign. I specialize in macro fluid condensation and have fine-tuned Runway Gen-3 workflows for zero-gravity citrus splashes.',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        Message(
          id: 'msg_f2',
          conversationId: 'conv_1',
          senderId: 'user_aura',
          senderName: 'Aura Beverages',
          senderRole: 'brand',
          recipientId: 'creator_aarav',
          text: 'Fantastic Aarav! We need a 15-second cutdown in 9:16 vertical for Instagram Reels, with ultra-crisp condensation water droplets on the glass curve. Can you meet the Oct 28 deadline?',
          createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
        ),
        Message(
          id: 'msg_f3',
          conversationId: 'conv_1',
          senderId: 'creator_aarav',
          senderName: 'Aarav Sharma',
          senderRole: 'creator',
          recipientId: 'user_aura',
          text: 'Absolutely. Turnaround takes 3 days. I can send the first styleframe moodboard by tomorrow afternoon.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ];
    } else if (convId == 'conv_2') {
      return [
        Message(
          id: 'msg_f4',
          conversationId: 'conv_2',
          senderId: 'creator_elena',
          senderName: 'Elena Rostova',
          senderRole: 'creator',
          recipientId: 'user_aura',
          text: 'Hello! I uploaded the obsidian fragrance lighting moodboard with volumetric beam effects for your review.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
    } else {
      return [
        Message(
          id: 'msg_f5',
          conversationId: convId,
          senderId: _currentUser.id,
          senderName: _currentUser.name,
          senderRole: _currentUser.role,
          recipientId: 'other_user',
          text: 'Hello! Looking forward to reviewing the creative deliverables together.',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
    }
  }

  List<Conversation> _getFallbackConversations() {
    return [
      Conversation(
        id: 'conv_1',
        participants: [
          ConversationParticipant(userId: 'user_aura', name: 'Aura Beverages', role: 'brand'),
          ConversationParticipant(
            userId: 'creator_aarav',
            name: 'Aarav Sharma',
            role: 'creator',
            avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
          ),
        ],
        campaignTitle: 'Summer Cold-Drink Campaign',
        lastMessageText: 'Turnaround takes 3 days. First styleframe tomorrow afternoon.',
        unreadCount: 0,
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Conversation(
        id: 'conv_2',
        participants: [
          ConversationParticipant(userId: 'user_aura', name: 'Aura Beverages', role: 'brand'),
          ConversationParticipant(
            userId: 'creator_elena',
            name: 'Elena Rostova',
            role: 'creator',
            avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
          ),
        ],
        campaignTitle: 'Obsidian Velvet Fragrance',
        lastMessageText: 'Sent obsidian fragrance lighting moodboard',
        unreadCount: 1,
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Conversation(
        id: 'conv_3',
        participants: [
          ConversationParticipant(userId: 'user_aura', name: 'Aura Beverages', role: 'brand'),
          ConversationParticipant(
            userId: 'creator_aria',
            name: 'Aria Chen',
            role: 'creator',
            avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
          ),
        ],
        campaignTitle: 'Direct Creator Collaboration',
        lastMessageText: 'Hi Aria! We loved your virtual human portfolio.',
        unreadCount: 0,
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
