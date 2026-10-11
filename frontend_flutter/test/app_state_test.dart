import 'package:flutter_test/flutter_test.dart';
import 'package:kampus_vc/models/campaign_model.dart';
import 'package:kampus_vc/models/user_account_model.dart';
import 'package:kampus_vc/state/app_state.dart';
import 'package:kampus_vc/theme/app_theme.dart';
import 'package:kampus_vc/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppState Tests', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    test('Initializes with default creators and campaigns', () {
      expect(appState.creators.isNotEmpty, isTrue);
      expect(appState.campaigns.isNotEmpty, isTrue);
      expect(appState.activeCampaign, isNotNull);
      expect(appState.currentRoute, equals('dashboard'));
    });

    test('toggleShortlist updates shortlisted state properly with equality check', () {
      final firstCreatorId = appState.creators.first.id;
      final initiallyShortlisted = appState.isShortlisted(firstCreatorId);

      appState.toggleShortlist(firstCreatorId);
      expect(appState.isShortlisted(firstCreatorId), equals(!initiallyShortlisted));

      final creator = appState.creators.firstWhere((c) => c.id == firstCreatorId);
      expect(creator.isShortlisted, equals(!initiallyShortlisted));

      // Toggle back
      appState.toggleShortlist(firstCreatorId);
      expect(appState.isShortlisted(firstCreatorId), equals(initiallyShortlisted));
      expect(creator.isShortlisted, equals(initiallyShortlisted));
    });

    test('Search query filters creators by name or tools', () {
      final initialCount = appState.creators.length;
      appState.setSearchQuery('NonExistentCreatorQueryXYZ');
      expect(appState.creators.isEmpty, isTrue);

      appState.setSearchQuery('');
      expect(appState.creators.length, equals(initialCount));
    });

    test('Navigation updates currentRoute and selectedCreator', () {
      final creator = appState.creators.first;
      appState.navigateTo('portfolio', creator: creator);

      expect(appState.currentRoute, equals('portfolio'));
      expect(appState.selectedCreator, equals(creator));
    });

    test('Campaign equality is based on unique ID', () {
      final c1 = appState.campaigns.first;
      final c2 = Campaign(
        id: c1.id,
        title: 'Different Title',
        client: 'Different Client',
        category: 'Different Category',
        productType: 'Different Product',
        contentType: 'Different Type',
        platform: 'Different Platform',
        aspectRatio: '16:9',
        visualStyle: 'Different Style',
        requiredTools: [],
        budget: 100,
        currency: '₹',
        deadline: '',
        status: 'Active',
        applicantsCount: 0,
        thumbnail: '',
        description: '',
        deliverables: [],
        commercialUsage: '',
        targetAudience: '',
      );

      expect(c1 == c2, isTrue);
      expect(c1.hashCode, equals(c2.hashCode));
    });

    test('setActiveCampaignById updates active campaign and recalculates match scores', () {
      final secondCamp = appState.campaigns[1];
      appState.setActiveCampaignById(secondCamp.id);

      expect(appState.activeCampaign?.id, equals(secondCamp.id));
      expect(appState.creators.first.matchScore, isNotNull);
    });

    test('setActiveCampaignById with non-existent ID falls back safely', () {
      appState.setActiveCampaignById('non-existent-campaign-id');
      expect(appState.activeCampaign, isNotNull);
      expect(appState.activeCampaign?.id, equals(appState.campaigns.first.id));
    });

    test('addCampaign deduplicates when adding a campaign with an existing ID', () {
      final existingId = appState.campaigns.first.id;
      final initialCount = appState.campaigns.length;

      final updatedCampaign = Campaign(
        id: existingId,
        title: 'Updated Campaign Title',
        client: 'Client',
        category: 'Category',
        productType: 'Product',
        contentType: 'Type',
        platform: 'Platform',
        aspectRatio: '9:16',
        visualStyle: 'Style',
        requiredTools: [],
        budget: 50000,
        currency: '₹',
        deadline: '',
        status: 'Active',
        applicantsCount: 0,
        thumbnail: '',
        description: 'Updated',
        deliverables: [],
        commercialUsage: '',
        targetAudience: '',
      );

      appState.addCampaign(updatedCampaign);
      expect(appState.campaigns.length, equals(initialCount));
      expect(appState.campaigns.first.title, equals('Updated Campaign Title'));
      expect(appState.activeCampaign?.id, equals(existingId));
    });
  });

  group('AppTheme Tests', () {
    test('AppTheme.lightTheme builds correctly with valid CardThemeData', () {
      final theme = AppTheme.lightTheme;
      expect(theme.cardTheme, isNotNull);
      expect(theme.cardTheme.elevation, equals(0));
    });
  });

  group('ApiService Tests', () {
    test('generateBrief returns structured production brief with metadata', () async {
      final brief = await ApiService.generateBrief({
        'name': 'Cold-Drink Summer Splash',
        'description': 'Citrus sparkling soda commercial',
      });

      expect(brief, isNotNull);
      expect(brief!['campaignTitle'], isNotNull);
      expect(brief['metadata'], isNotNull);
      expect(brief['metadata']['source'], isNotNull);
      expect(brief['suggestedDeliverables'], isA<List>());
    });

    test('createCampaign returns populated Campaign object', () async {
      final campaign = await ApiService.createCampaign({
        'title': 'Test Artisan Soda Campaign',
        'campaignDescription': 'Ultra cinematic splash shot',
        'budgetMax': 60000,
        'contentType': 'AI Video',
      });

      expect(campaign, isNotNull);
      expect(campaign.title, equals('Test Artisan Soda Campaign'));
      expect(campaign.budget, equals(60000));
      expect(campaign.id.isNotEmpty, isTrue);
    });
  });

  group('UserAccount & Authentication Tests', () {
    test('Default user initializes as Aura Beverages brand account', () {
      final appState = AppState();
      expect(appState.currentUser.name, equals('Aura Beverages'));
      expect(appState.currentUser.isBrand, isTrue);
      expect(appState.isAuthenticated, isTrue);
    });

    test('switchUser changes identity and reloads conversations', () {
      final appState = AppState();
      final aarav = UserAccount.defaultDemoAccounts.firstWhere((a) => a.name.contains('Aarav'));

      appState.switchUser(aarav);

      expect(appState.currentUser.id, equals(aarav.id));
      expect(appState.currentUser.name, equals(aarav.name));
      expect(appState.currentUser.isCreator, isTrue);
      expect(appState.isAuthenticated, isTrue);
    });

    test('logout cleanses session state and route', () {
      final appState = AppState();
      appState.logout();

      expect(appState.isAuthenticated, isFalse);
      expect(appState.authToken, isNull);
      expect(appState.messages.isEmpty, isTrue);
    });

    test('login with valid demo email succeeds', () async {
      final appState = AppState();
      final success = await appState.login(email: 'elena@anim-lab.studio', password: 'password123');

      expect(success, isTrue);
      expect(appState.currentUser.name, equals('Elena Rostova'));
      expect(appState.isAuthenticated, isTrue);
    });
  });

  group('Direct Messaging & Conversation Tests', () {
    test('loadConversations populates conversations and selects initial thread', () async {
      final appState = AppState();
      await appState.loadConversations();

      expect(appState.conversations.isNotEmpty, isTrue);
      expect(appState.activeConversation, isNotNull);
      expect(appState.messages.isNotEmpty, isTrue);
    });

    test('sendMessage rejects empty text and sends valid text', () async {
      final appState = AppState();
      await appState.loadConversations();

      final emptyResult = await appState.sendMessage('   ');
      expect(emptyResult, isFalse);

      final initialCount = appState.messages.length;
      final sendResult = await appState.sendMessage('Test directive for water droplet condensation.');
      expect(sendResult, isTrue);
      expect(appState.messages.length, equals(initialCount + 1));
      expect(appState.messages.last.text, equals('Test directive for water droplet condensation.'));
      expect(appState.activeConversation?.lastMessageText, equals('Test directive for water droplet condensation.'));
    });

    test('triggerSimulatedReply generates response flagged as simulated', () async {
      final appState = AppState();
      await appState.loadConversations();

      final simResult = await appState.triggerSimulatedReply();
      expect(simResult, isTrue);
      expect(appState.messages.last.isSimulatedReply, isTrue);
    });

    test('getSuggestedReply and clearSuggestedReply manage AI reply state properly', () async {
      final appState = AppState();
      expect(appState.suggestedReply, isNull);
      expect(appState.isSuggestingReply, isFalse);

      final reply = await appState.getSuggestedReply('conv_1');
      expect(reply, isNotNull);
      expect(reply!.isNotEmpty, isTrue);
      expect(appState.suggestedReply, equals(reply));
      expect(appState.isSuggestingReply, isFalse);
      expect(['gemini', 'template_fallback'].contains(appState.suggestedReplySource), isTrue);

      appState.clearSuggestedReply();
      expect(appState.suggestedReply, isNull);
    });

    test('selectConversationByCreator finds or creates conversation and navigates', () {
      final appState = AppState();
      final creator = appState.creators.first;

      appState.selectConversationByCreator(creator);

      expect(appState.currentRoute, equals('messages'));
      expect(appState.activeConversation, isNotNull);
      expect(
        appState.activeConversation!.participants.any((p) => p.userId == creator.id || p.name == creator.name),
        isTrue,
      );
    });
  });

  group('Portfolio Item Aspect Ratio Tests', () {
    test('PortfolioItem calculates aspect ratios correctly', () {
      final appState = AppState();
      final item16_9 = appState.creators.first.portfolio.firstWhere((p) => p.aspectRatio == '16:9');
      expect(item16_9.isLandscape, isTrue);
      expect(item16_9.isVertical, isFalse);
      expect((item16_9.aspectRatioValue - 16 / 9).abs() < 0.01, isTrue);

      final item9_16 = appState.creators.first.portfolio.firstWhere((p) => p.aspectRatio == '9:16');
      expect(item9_16.isVertical, isTrue);
      expect(item9_16.isLandscape, isFalse);
      expect((item9_16.aspectRatioValue - 9 / 16).abs() < 0.01, isTrue);
    });
  });
}
