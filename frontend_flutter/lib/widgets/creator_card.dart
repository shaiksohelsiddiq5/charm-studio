import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/creator_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'media_lightbox_dialog.dart';

class CreatorCard extends StatelessWidget {
  final Creator creator;
  final bool isCompact;

  const CreatorCard({
    super.key,
    required this.creator,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isShortlisted = appState.isShortlisted(creator.id);
    final matchScore = creator.matchScore;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: matchScore >= 90 ? AppColors.primary.withValues(alpha: 0.35) : AppColors.border,
          width: matchScore >= 90 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.hasBoundedHeight;

          final cardContent = [
            // 1. Header: Avatar, Name, Handle, Rating, Location, Match Score Pill
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Circular Uniform Avatar with Fallback & Verified Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border, width: 1.5),
                        ),
                        child: ClipOval(
                          child: creator.avatar.isNotEmpty
                              ? Image.network(
                                  creator.avatar,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                                )
                              : _buildAvatarFallback(),
                        ),
                      ),
                      if (creator.verified)
                        Positioned(
                          bottom: -1,
                          right: -1,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 10),

                  // Name, Handle, Rating & Location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          creator.handle,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              creator.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            const SizedBox(width: 4),
                            const Icon(Icons.location_on_outlined, size: 11, color: AppColors.textMuted),
                            const SizedBox(width: 1),
                            Flexible(
                              child: Text(
                                creator.location,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Match Score Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: matchScore >= 85 ? AppColors.successBg : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: matchScore >= 85
                            ? AppColors.success.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: matchScore >= 85 ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$matchScore%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: matchScore >= 85 ? AppColors.success : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Short Bio (Clamped to 2 lines)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 32,
                child: Text(
                  creator.bio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 3. Specialties & AI Tools Tags
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SizedBox(
                height: 22,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    ...creator.specializations.take(2).map((s) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: _tag(s, isSpecialty: true),
                        )),
                    ...creator.aiTools.take(1).map((t) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: _tag(t, isTool: true),
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // 4. Dynamic Match Explanation / Verification Highlight
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Icon(
                    creator.matchExplanations.isNotEmpty ? Icons.insights : Icons.verified_outlined,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      creator.matchExplanations.isNotEmpty
                          ? creator.matchExplanations.first
                          : 'Verified AI Creator • Available for bookings',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 5. Portfolio Thumbnails Strip with Aspect Ratios (68px Height)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: creator.portfolio.isNotEmpty
                  ? Row(
                      children: creator.portfolio.take(3).map((item) {
                        return Expanded(
                          child: Container(
                            height: 68,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => MediaLightboxDialog.show(context, item: item, creator: creator),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      item.thumbnail.isNotEmpty
                                          ? Image.network(
                                              item.thumbnail,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => _buildDeliberateThumbnailFallback(item),
                                            )
                                          : _buildDeliberateThumbnailFallback(item),

                                      // Subtle gradient scrim at bottom
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          height: 22,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Aspect ratio badge
                                      Positioned(
                                        bottom: 3,
                                        left: 3,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.65),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(
                                            item.aspectRatio,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 8.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Video play indicator
                                      if (item.category == 'video')
                                        const Center(
                                          child: Icon(
                                            Icons.play_circle_fill_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.collections_outlined, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Text('Portfolio showcase pending', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
            ),

            if (hasBoundedHeight) const Spacer() else const SizedBox(height: 8),

            const Divider(height: 1, color: AppColors.borderLight),

            // 6. Footer: Price, Turnaround, Shortlist & View Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Starting from', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                        Text(
                          '₹${creator.startingPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Shortlist Bookmark Button
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                        icon: Icon(
                          isShortlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isShortlisted ? AppColors.primary : AppColors.textMuted,
                          size: 20,
                        ),
                        tooltip: isShortlisted ? 'Remove from Shortlist' : 'Add to Shortlist',
                        onPressed: () => appState.toggleShortlist(creator.id),
                      ),

                      const SizedBox(width: 4),

                      // View Portfolio Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          minimumSize: const Size(0, 30),
                        ),
                        onPressed: () {
                          appState.navigateTo('portfolio', creator: creator);
                        },
                        child: const Text('View', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
            children: cardContent,
          );
        },
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.primaryLight,
      child: Center(
        child: Text(
          creator.name.isNotEmpty ? creator.name.substring(0, 1).toUpperCase() : 'C',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildDeliberateThumbnailFallback(PortfolioItem item) {
    IconData iconData = Icons.auto_awesome;
    if (item.category == 'video' || item.isVertical) {
      iconData = Icons.play_circle_outline_rounded;
    } else if (item.category == 'animation') {
      iconData = Icons.motion_photos_on_outlined;
    } else {
      iconData = Icons.image_outlined;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDE9FE), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(height: 2),
            Text(
              item.aspectRatio,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, {bool isSpecialty = false, bool isTool = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isTool ? AppColors.purpleLight : AppColors.background,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isTool ? AppColors.purple.withValues(alpha: 0.2) : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isTool ? AppColors.purpleDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}
