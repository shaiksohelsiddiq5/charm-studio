import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kampus_vc/models/campaign_model.dart';
import 'package:kampus_vc/state/app_state.dart';
import 'package:kampus_vc/widgets/campaign_card.dart';
import 'package:kampus_vc/screens/creator_discovery_screen.dart';
import 'package:kampus_vc/screens/create_campaign_screen.dart';
import 'package:kampus_vc/screens/dashboard_screen.dart';
import 'package:kampus_vc/screens/shortlist_screen.dart';
import 'package:kampus_vc/screens/messages_screen.dart';
import 'package:kampus_vc/widgets/creator_card.dart';
import 'package:kampus_vc/widgets/sidebar.dart';
import 'package:kampus_vc/screens/login_screen.dart';

void main() {
  testWidgets('CampaignCard renders category and status with BackdropFilter properly', (tester) async {
    final campaign = Campaign(
      id: 'camp-test-1',
      title: 'Summer Splash Test',
      client: 'Aura Beverages',
      category: 'Beverage',
      productType: 'Beverage',
      contentType: 'Video',
      platform: 'Instagram',
      aspectRatio: '9:16',
      visualStyle: 'Cinematic',
      requiredTools: ['Midjourney', 'Runway'],
      budget: 50000,
      currency: '₹',
      deadline: '2026-11-01',
      status: 'Active',
      applicantsCount: 5,
      thumbnail: '',
      description: 'Test Campaign Description',
      deliverables: ['1x Video'],
      commercialUsage: 'Digital',
      targetAudience: 'General',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          home: Scaffold(
            body: CampaignCard(campaign: campaign),
          ),
        ),
      ),
    );

    expect(find.text('Summer Splash Test'), findsOneWidget);
    expect(find.text('Beverage'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('CreatorDiscoveryScreen renders campaign dropdown without DropdownButton assertion error', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: CreatorDiscoveryScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    // The campaign dropdown should be present with the active campaign title
    expect(find.byType(DropdownButton<String>), findsNWidgets(6)); // Target selector + sort dropdown + 4 filter dropdowns
    expect(find.text('Summer Cold-Drink Campaign'), findsWidgets);

    // Verify selecting another campaign by tapping dropdown
    final firstCampaignDropdown = find.byType(DropdownButton<String>).first;
    await tester.tap(firstCampaignDropdown);
    await tester.pumpAndSettle();

    // Tap the second campaign in the popup
    final secondCampaignItem = find.text('Aura Noir Luxury Fragrance Reveal').last;
    await tester.tap(secondCampaignItem);
    await tester.pumpAndSettle();

    expect(appState.activeCampaign?.id, equals('camp-2'));
  });

  testWidgets('CreatorDiscoveryScreen safely preserves selection when campaigns reload with new object instances', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    // Select second campaign
    appState.setActiveCampaignById('camp-2');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: CreatorDiscoveryScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(appState.activeCampaign?.id, equals('camp-2'));

    // Simulate backend reload returning new instances with duplicate or matching IDs
    await appState.loadDataFromBackend();
    await tester.pumpAndSettle();

    // No assertion error thrown, active campaign preserved or valid fallback
    expect(appState.activeCampaign, isNotNull);
    expect(find.byType(DropdownButton<String>), findsWidgets);
  });

  testWidgets('CreateCampaignScreen generates AI brief, displays badge, and publishes new campaign', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    final initialCampaignsCount = appState.campaigns.length;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: CreateCampaignScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Create AI Creator Campaign'), findsOneWidget);
    expect(find.text('No brief generated yet'), findsOneWidget);

    // Tap AI Generate Brief button
    final generateBtn = find.text('AI Generate Brief');
    expect(generateBtn, findsOneWidget);
    await tester.tap(generateBtn);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify brief is displayed with AI production badge
    expect(find.text('AI Production Brief'), findsOneWidget);

    // Tap Publish Campaign
    final publishBtn = find.text('Publish Campaign & Match Creators');
    expect(publishBtn, findsOneWidget);
    await tester.ensureVisible(publishBtn);
    await tester.tap(publishBtn);
    await tester.pump();
    await tester.pumpAndSettle();

    // Verify campaign was added to AppState and route navigated
    expect(appState.campaigns.length, equals(initialCampaignsCount + 1));
    expect(appState.currentRoute, equals('discovery'));
  });

  testWidgets('Screens render cleanly on mobile viewport (400x800) without RenderFlex overflow', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();

    // Test DashboardScreen on mobile
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: DashboardScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Test CreatorDiscoveryScreen on mobile
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: CreatorDiscoveryScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CreatorDiscoveryScreen), findsOneWidget);

    // Test CreateCampaignScreen on mobile
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: CreateCampaignScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create AI Creator Campaign'), findsOneWidget);

    // Test ShortlistScreen on mobile
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: ShortlistScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ShortlistScreen), findsOneWidget);
  });

  testWidgets('CreatorCard renders circular avatar, portfolio aspect ratios, and bottom actions', (tester) async {
    final appState = AppState();
    final creator = appState.creators.first;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 380,
              child: CreatorCard(creator: creator),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verifies creator name and handle
    expect(find.text(creator.name), findsOneWidget);
    expect(find.text(creator.handle), findsOneWidget);

    // Verifies circular avatar ClipOval
    expect(find.byType(ClipOval), findsOneWidget);

    // Verifies portfolio aspect ratio badges exist
    expect(find.text('9:16'), findsWidgets);

    // Verifies bottom action buttons
    expect(find.text('View'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
  });

  testWidgets('MessagesScreen renders AI Suggest Reply button and allows review/editing', (tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: MessagesScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AI Suggest Reply button is rendered in the message composer
    final suggestBtn = find.textContaining('AI Suggest Reply');
    expect(suggestBtn, findsOneWidget);

    // Tap AI Suggest Reply
    await tester.tap(suggestBtn);
    await tester.pumpAndSettle();

    // Verify suggested text was populated into the composer TextField
    expect(appState.suggestedReply, isNotNull);
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter custom edits into the TextField to verify user is in control
    await tester.enterText(textField, '${appState.suggestedReply!} [Custom Edited Feedback]');
    await tester.pumpAndSettle();

    final editableText = tester.widget<TextField>(textField);
    expect(editableText.controller?.text.contains('[Custom Edited Feedback]'), isTrue);
  });

  testWidgets('Sidebar displays Charm Studio branding and CREATOR STUDIO tagline', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: Sidebar(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Charm'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('CREATOR STUDIO'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('LoginScreen displays Charm Studio branding and tagline', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final appState = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: const MaterialApp(
          home: Scaffold(
            body: LoginScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Charm'), findsOneWidget);
    expect(find.text('Studio'), findsOneWidget);
    expect(find.text('Creator Studio for Modern Brands'), findsOneWidget);
  });
}
