import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/stat_card.dart';
import '../widgets/campaign_card.dart';
import '../widgets/creator_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final campaigns = appState.campaigns;
    final topCreators = appState.creators.take(3).toList();
    final activeCamp = appState.activeCampaign;

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPad = screenWidth < 650 ? 16.0 : 32.0;
    final verticalPad = screenWidth < 650 ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: verticalPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Banner (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 650;
              final textBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, Aura Beverages 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Manage your active generative video campaigns and discover verified AI talent.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              );

              final actionBtn = ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create New Campaign'),
                onPressed: () => appState.navigateTo('create_campaign'),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textBlock,
                    const SizedBox(height: 14),
                    actionBtn,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: textBlock),
                  const SizedBox(width: 16),
                  actionBtn,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // 4 KPI Stat Cards (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              final isMedium = constraints.maxWidth >= 600;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Active Campaigns',
                        value: '${campaigns.length}',
                        icon: Icons.campaign_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primaryLight,
                        trend: '+1 new this week',
                        isPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Shortlisted Creators',
                        value: '${appState.shortlistCount}',
                        icon: Icons.bookmark_added_rounded,
                        iconColor: AppColors.purple,
                        iconBg: AppColors.purpleLight,
                        trend: 'Ready for contract',
                        isPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Total AI Creators',
                        value: '${appState.creators.length} verified',
                        icon: Icons.people_alt_rounded,
                        iconColor: AppColors.info,
                        iconBg: AppColors.infoBg,
                        trend: 'Active dataset',
                        isPositive: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'Completed Projects',
                        value: '${appState.creators.fold<int>(0, (sum, c) => sum + c.completedProjects)}',
                        icon: Icons.verified_rounded,
                        iconColor: AppColors.success,
                        iconBg: AppColors.successBg,
                        trend: 'Delivered commercial works',
                        isPositive: true,
                      ),
                    ),
                  ],
                );
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isMedium ? 2 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMedium ? 2.2 : 2.0,
                children: [
                  StatCard(
                    title: 'Active Campaigns',
                    value: '${campaigns.length}',
                    icon: Icons.campaign_rounded,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryLight,
                    trend: '+1 new this week',
                    isPositive: true,
                  ),
                  StatCard(
                    title: 'Shortlisted Creators',
                    value: '${appState.shortlistCount}',
                    icon: Icons.bookmark_added_rounded,
                    iconColor: AppColors.purple,
                    iconBg: AppColors.purpleLight,
                    trend: 'Ready for contract',
                    isPositive: true,
                  ),
                  StatCard(
                    title: 'Total AI Creators',
                    value: '${appState.creators.length} verified',
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.info,
                    iconBg: AppColors.infoBg,
                    trend: 'Active dataset',
                    isPositive: true,
                  ),
                  StatCard(
                    title: 'Completed Projects',
                    value: '${appState.creators.fold<int>(0, (sum, c) => sum + c.completedProjects)}',
                    icon: Icons.verified_rounded,
                    iconColor: AppColors.success,
                    iconBg: AppColors.successBg,
                    trend: 'Delivered commercial works',
                    isPositive: true,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Prominent "Find My Perfect Creator" AI Matching Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: LayoutBuilder(
              builder: (context, bannerConstraints) {
                final isNarrow = bannerConstraints.maxWidth < 800;

                final textBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'AI SMART MATCH ENGINE 2.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Find My Perfect Creator for Summer Cold-Drink Campaign',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Automatically evaluates 1,200+ creators across portfolio relevance (30%), visual styles (20%), and required AI tools (Runway Gen-3, Midjourney v6). Top match Aarav Sharma scored 99% relevance.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                );

                final actionBtn = ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text(
                    'Explore AI Recommendations',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onPressed: () {
                    appState.navigateTo('discovery');
                  },
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textBlock,
                      const SizedBox(height: 20),
                      actionBtn,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: textBlock),
                    const SizedBox(width: 24),
                    actionBtn,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Recent Campaigns Section
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 650;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Brand Campaigns',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select any campaign to immediately re-rank creators using its specific requirements.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              );
              final linkBtn = TextButton(
                onPressed: () => appState.navigateTo('my_campaigns'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All Campaigns', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 8), linkBtn],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Expanded(child: titleBlock), linkBtn],
              );
            },
          ),

          const SizedBox(height: 16),

          // Campaign Cards Grid (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth < 800 ? 1 : 2;
              final ratio = constraints.maxWidth < 650 ? 1.05 : (constraints.maxWidth < 800 ? 1.25 : 1.25);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: ratio,
                ),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  return CampaignCard(campaign: campaigns[index]);
                },
              );
            },
          ),

          const SizedBox(height: 36),

          // Top Recommended Creators
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 650;
              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      const Text(
                        'Top Recommended AI Creators',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (activeCamp != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Target: ${activeCamp.title}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ranked by transparent 6-factor matching with real explanation bullets.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              );

              final linkBtn = TextButton(
                onPressed: () => appState.navigateTo('discovery'),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All Creators', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [titleBlock, const SizedBox(height: 8), linkBtn],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Expanded(child: titleBlock), linkBtn],
              );
            },
          ),

          const SizedBox(height: 16),

          // Top Creators Grid (Responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth < 650
                  ? 1
                  : (constraints.maxWidth < 1050 ? 2 : 3);
              final ratio = 1.05;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: ratio,
                ),
                itemCount: topCreators.length,
                itemBuilder: (context, index) {
                  return CreatorCard(creator: topCreators[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
