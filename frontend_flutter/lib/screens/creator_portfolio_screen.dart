import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/portfolio_gallery.dart';

class CreatorPortfolioScreen extends StatelessWidget {
  const CreatorPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creator = appState.selectedCreator ?? appState.creators.first;
    final isShortlisted = appState.isShortlisted(creator.id);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Wide Cover Banner
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.network(
                creator.coverImage,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.purpleDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.art_track_rounded, color: Colors.white54, size: 48),
                ),
              ),
              // Back Button Overlay
              Positioned(
                top: 20,
                left: 28,
                child: InkWell(
                  onTap: () => appState.navigateTo('discovery'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16, color: AppColors.textPrimary),
                        SizedBox(width: 6),
                        Text('Back to Discovery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),

              // AI Match Badge Overlay
              Positioned(
                top: 20,
                right: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${creator.matchScore}% Match Score',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Avatar Overlapping Cover
              Positioned(
                bottom: -45,
                left: 36,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryLight,
                        child: ClipOval(
                          child: Image.network(
                            creator.avatar,
                            width: 92,
                            height: 92,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 46, color: AppColors.primary),
                          ),
                        ),
                      ),
                      if (creator.verified)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified, color: AppColors.primary, size: 22),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 55),

          // Main Creator Details Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: LayoutBuilder(
              builder: (context, detailsConstraints) {
                final isNarrow = detailsConstraints.maxWidth < 850;

                final bioColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            creator.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (creator.verified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Verified Pro',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(creator.handle, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text(creator.location, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text('${creator.rating} (${creator.completedProjects} projects)',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      creator.bio,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                    ),
                  ],
                );

                final pricingCard = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Starting from', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      Text(
                        '₹${creator.startingPrice} / project',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('Turnaround: ${creator.turnaroundDays} days',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 10, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(creator.availability,
                              style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.mail_outline, size: 16),
                            label: const Text('Contact Creator'),
                            onPressed: () {
                              appState.navigateTo('messages');
                            },
                          ),
                          OutlinedButton.icon(
                            icon: Icon(
                              isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                              size: 16,
                              color: isShortlisted ? AppColors.primary : AppColors.textSecondary,
                            ),
                            label: Text(
                              isShortlisted ? 'Shortlisted' : 'Add to Shortlist',
                              style: TextStyle(
                                color: isShortlisted ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            onPressed: () {
                              appState.toggleShortlist(creator.id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bioColumn,
                      const SizedBox(height: 20),
                      pricingCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: bioColumn),
                    const SizedBox(width: 24),
                    pricingCard,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 24),

          // Tools & Specialization Tags Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: LayoutBuilder(
              builder: (context, tagsConstraints) {
                final isNarrow = tagsConstraints.maxWidth < 700;

                final specializationsBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Content Specializations',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: creator.specializations.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );

                final toolsBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Generative AI Stack & Tools',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: creator.aiTools.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.purpleLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.purpleDark),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      specializationsBlock,
                      const SizedBox(height: 20),
                      toolsBlock,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: specializationsBlock),
                    const SizedBox(width: 24),
                    Expanded(child: toolsBlock),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Portfolio Showcase Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Portfolio Showcase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Verified commercial generative deliverables produced for client brands.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                PortfolioGallery(items: creator.portfolio),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
