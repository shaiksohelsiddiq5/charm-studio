import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/creator_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class MediaLightboxDialog extends StatelessWidget {
  final PortfolioItem item;
  final Creator? creator;

  const MediaLightboxDialog({
    super.key,
    required this.item,
    this.creator,
  });

  static void show(BuildContext context, {required PortfolioItem item, Creator? creator}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => MediaLightboxDialog(item: item, creator: creator),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 16,
        vertical: isDesktop ? 36 : 24,
      ),
      child: Container(
        width: isDesktop ? 1080 : double.infinity,
        height: isDesktop ? 720 : size.height * 0.85,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark slate theme for media contrast
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                ),
                child: Row(
                  children: [
                    if (creator != null) ...[
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(creator!.avatar),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'By ${creator!.name} • ${item.clientType}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],

                    // Aspect ratio badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.isVertical
                                ? Icons.stay_current_portrait_rounded
                                : (item.isLandscape ? Icons.stay_current_landscape_rounded : Icons.crop_square_rounded),
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.aspectRatio} ${item.isVertical ? "Reel" : (item.isLandscape ? "Widescreen" : "Square")}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'Close Preview',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Main Viewer & Details
              Expanded(
                child: isDesktop
                    ? Row(
                        children: [
                          // Interactive Media Viewport
                          Expanded(
                            flex: 3,
                            child: _buildMediaViewport(),
                          ),

                          const VerticalDivider(width: 1, color: Colors.white12),

                          // Details Sidebar
                          Container(
                            width: 320,
                            padding: const EdgeInsets.all(24),
                            color: const Color(0xFF1E293B),
                            child: _buildDetailsPanel(context),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _buildMediaViewport(),
                          ),
                          Container(
                            height: 180,
                            padding: const EdgeInsets.all(16),
                            color: const Color(0xFF1E293B),
                            child: SingleChildScrollView(
                              child: _buildDetailsPanel(context),
                            ),
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

  Widget _buildMediaViewport() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            panAxis: PanAxis.free,
            minScale: 0.6,
            maxScale: 3.5,
            child: Center(
              child: AspectRatio(
                aspectRatio: item.aspectRatioValue,
                child: item.thumbnail.isNotEmpty
                    ? Image.network(
                        item.thumbnail,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : _buildFallback(),
              ),
            ),
          ),

          // Zoom hint overlay
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pinch_outlined, size: 13, color: Colors.white70),
                  SizedBox(width: 4),
                  Text(
                    'Pinch or scroll to zoom / pan master asset',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
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
            Icon(
              item.category == 'video'
                  ? Icons.play_circle_outline_rounded
                  : (item.category == 'animation' ? Icons.motion_photos_on_outlined : Icons.image_outlined),
              size: 56,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.category.toUpperCase()} • ${item.aspectRatio}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.contentType,
                style: const TextStyle(color: AppColors.purpleDark, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  item.views,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Creative Directive',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          item.description,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 16),
        const Text(
          'AI Pipeline & Generation Tools',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: item.tools.map((tool) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(
                tool,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
        const Spacer(),
        if (creator != null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
              label: const Text('Inquire About This Style'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                final appState = Provider.of<AppState>(context, listen: false);
                appState.selectConversationByCreator(creator!);
              },
            ),
          ),
        ],
      ],
    );
  }
}
