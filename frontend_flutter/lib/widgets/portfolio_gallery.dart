import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/creator_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import 'media_lightbox_dialog.dart';

class PortfolioGallery extends StatefulWidget {
  final List<PortfolioItem> items;

  const PortfolioGallery({super.key, required this.items});

  @override
  State<PortfolioGallery> createState() => _PortfolioGalleryState();
}

class _PortfolioGalleryState extends State<PortfolioGallery> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 768 ? 1 : 2;
    final childAspectRatio = screenWidth < 768 ? 0.92 : 0.86;

    final filtered = widget.items.where((item) {
      if (_selectedCategory == 'all') return true;
      return item.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _tab('All Projects (${widget.items.length})', 'all'),
              const SizedBox(width: 8),
              _tab('Videos (${widget.items.where((i) => i.category == 'video').length})', 'video'),
              const SizedBox(width: 8),
              _tab('Images & Stills (${widget.items.where((i) => i.category == 'image').length})', 'image'),
              const SizedBox(width: 8),
              _tab('3D / Animations (${widget.items.where((i) => i.category == 'animation').length})', 'animation'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Portfolio Grid
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('No projects found in this category.', style: TextStyle(color: AppColors.textMuted)),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final project = filtered[index];
              return _projectCard(context, project, appState.selectedCreator);
            },
          ),
      ],
    );
  }

  Widget _tab(String label, String key) {
    final isSelected = _selectedCategory == key;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _projectCard(BuildContext context, PortfolioItem project, Creator? creator) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => MediaLightboxDialog.show(context, item: project, creator: creator),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Framed Container honoring actual aspect ratio
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFF0F172A), // Dark slate matte backdrop
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Centered aspect-ratio preserved preview
                      Center(
                        child: AspectRatio(
                          aspectRatio: project.aspectRatioValue,
                          child: project.thumbnail.isNotEmpty
                              ? Image.network(
                                  project.thumbnail,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildDeliberateFallback(project),
                                )
                              : _buildDeliberateFallback(project),
                        ),
                      ),

                      // Gradient overlay for readability of badges
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // Top-Left: Category + Aspect Ratio Tag
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                project.isVertical
                                    ? Icons.stay_current_portrait_rounded
                                    : (project.isLandscape
                                        ? Icons.stay_current_landscape_rounded
                                        : Icons.crop_square_rounded),
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.aspectRatio} ${project.isVertical ? "Reel" : (project.isLandscape ? "Landscape" : "Square")}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top-Right: Zoom / Inspect prompt
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                      // Bottom-Right: Views pill
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility_outlined, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                project.views,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center Play icon if video
                      if (project.category == 'video')
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Info & Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          project.contentType,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        Text(
                          project.clientType,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: project.tools.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purpleLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            t,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.purpleDark),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliberateFallback(PortfolioItem project) {
    IconData icon = Icons.auto_awesome;
    if (project.category == 'video') {
      icon = Icons.play_circle_outline_rounded;
    } else if (project.category == 'animation') {
      icon = Icons.motion_photos_on_outlined;
    } else {
      icon = Icons.image_outlined;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              project.contentType,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

