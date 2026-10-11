import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'user_account_menu_dialog.dart';

class TopNav extends StatelessWidget {
  const TopNav({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeCamp = appState.activeCampaign;

    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Mobile/Tablet Menu Button
          if (!isDesktop) ...[
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                tooltip: 'Open Navigation',
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Global Search Bar
          Expanded(
            child: Container(
              height: 42,
              constraints: const BoxConstraints(maxWidth: 460),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (val) {
                  appState.setSearchQuery(val);
                  if (appState.currentRoute != 'discovery' && val.isNotEmpty) {
                    appState.navigateTo('discovery');
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Search AI creators by skill, tool, style, or name...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search, size: 19, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Active Campaign AI Matching Context Pill
          if (activeCamp != null)
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => appState.navigateTo('discovery'),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Target: ${activeCamp.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.primaryDark),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No new notifications. All creator proposals are up to date.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(width: 8),

          // Dynamic User Avatar with Account Menu Trigger
          Tooltip(
            message: 'Account: ${appState.currentUser.name} (Click to switch)',
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => UserAccountMenuDialog.show(context),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: appState.currentUser.isBrand ? AppColors.primary : AppColors.purple,
                  backgroundImage: appState.currentUser.avatar.isNotEmpty
                      ? NetworkImage(appState.currentUser.avatar)
                      : null,
                  child: appState.currentUser.avatar.isEmpty
                      ? Text(
                          appState.currentUser.avatarText.isNotEmpty
                              ? appState.currentUser.avatarText
                              : 'AB',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
