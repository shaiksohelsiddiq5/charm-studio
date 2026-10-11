import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'state/app_state.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_nav.dart';
import 'screens/dashboard_screen.dart';
import 'screens/creator_discovery_screen.dart';
import 'screens/creator_portfolio_screen.dart';
import 'screens/create_campaign_screen.dart';
import 'screens/shortlist_screen.dart';
import 'screens/my_campaigns_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/user_account_menu_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const KampusVCApp(),
    ),
  );
}

class KampusVCApp extends StatelessWidget {
  const KampusVCApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Charm Studio — CREATOR STUDIO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: appState.isAuthenticated ? const MainLayoutScreen() : const LoginScreen(),
    );
  }
}

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final route = appState.currentRoute;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      drawer: isDesktop ? null : const Drawer(child: Sidebar()),
      body: Row(
        children: [
          // Desktop Persistent Sidebar
          if (isDesktop) const Sidebar(),

          // Main App Body
          Expanded(
            child: Column(
              children: [
                const TopNav(),
                Expanded(
                  child: _buildCurrentScreen(route),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen(String route) {
    switch (route) {
      case 'dashboard':
        return const DashboardScreen();
      case 'discovery':
        return const CreatorDiscoveryScreen();
      case 'portfolio':
        return const CreatorPortfolioScreen();
      case 'create_campaign':
        return const CreateCampaignScreen();
      case 'shortlist':
        return const ShortlistScreen();
      case 'my_campaigns':
        return const MyCampaignsScreen();
      case 'messages':
        return const MessagesScreen();
      case 'settings':
        return const SettingsView();
      default:
        return const DashboardScreen();
    }
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account & Workspace Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text('Manage company billing, AI workspace seats, identity switching, and escrow preferences.', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: user.isBrand ? AppColors.primary : AppColors.purple,
                      backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                      child: user.avatar.isEmpty
                          ? Text(
                              user.avatarText.isNotEmpty ? user.avatarText : 'AB',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),
                Text('Role Type: ${user.isBrand ? "Brand Enterprise" : "AI Creator Specialist"}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (user.companyName.isNotEmpty)
                  Text('Organization: ${user.companyName}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                const Text('Billing Currency: INR (₹)', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                const Text('Automated AI Escrow Protection: Enabled', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                      label: const Text('Switch Demo User'),
                      onPressed: () => UserAccountMenuDialog.show(context),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.redAccent),
                      label: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        appState.logout();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out of workspace.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
