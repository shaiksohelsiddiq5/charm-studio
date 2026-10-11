import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../models/campaign_model.dart';
import '../widgets/creator_card.dart';

class CreatorDiscoveryScreen extends StatelessWidget {
  const CreatorDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final creators = appState.creators;
    final campaigns = appState.campaigns;
    final activeCamp = appState.activeCampaign;

    // Deduplicate campaign list by unique ID preserving order
    final uniqueCampaigns = <Campaign>[];
    final seenCampaignIds = <String>{};
    for (final c in campaigns) {
      if (c.id.isNotEmpty && seenCampaignIds.add(c.id)) {
        uniqueCampaigns.add(c);
      }
    }

    // Ensure selected ID exists in the available dropdown items
    final selectedCampaignId = (activeCamp != null && seenCampaignIds.contains(activeCamp.id))
        ? activeCamp.id
        : (uniqueCampaigns.isNotEmpty ? uniqueCampaigns.first.id : null);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Campaign Match Target Selector
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 850;

              final titleWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Creator Discovery & AI Match',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discover and benchmark AI creators using multi-factor profile compatibility algorithms.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              );

              final dropdownWidget = Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    if (!isNarrow) ...[
                      const Text('Matching for: ', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                    ],
                    if (uniqueCampaigns.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (appState.isLoading) ...[
                              const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Loading campaigns...',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                              ),
                            ] else ...[
                              const Text(
                                'No campaigns available',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: DropdownButton<String>(
                          value: selectedCampaignId,
                          isDense: true,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          items: uniqueCampaigns.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: isNarrow ? 150 : 220),
                                child: Text(
                                  c.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (campaignId) {
                            if (campaignId != null) {
                              appState.setActiveCampaignById(campaignId);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    const SizedBox(height: 16),
                    dropdownWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: titleWidget),
                  const SizedBox(width: 16),
                  dropdownWidget,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Search + View Toggle + Sort
                LayoutBuilder(
                  builder: (context, searchConstraints) {
                    final isNarrow = searchConstraints.maxWidth < 680;

                    final searchInput = TextField(
                      controller: TextEditingController(text: appState.searchQuery)
                        ..selection = TextSelection.collapsed(offset: appState.searchQuery.length),
                      onChanged: (val) => appState.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Search by creator name, skills (e.g. AI Video, Food), or tools...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                        suffixIcon: appState.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => appState.setSearchQuery(''),
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.background,
                      ),
                    );

                    final controlsRow = Row(
                      mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        Expanded(
                          flex: isNarrow ? 1 : 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButton<String>(
                              value: appState.sortBy,
                              isExpanded: isNarrow,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'relevance', child: Text('Sort by AI Match Score')),
                                DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                                DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                                DropdownMenuItem(value: 'experience', child: Text('Most Experienced')),
                              ],
                              onChanged: (val) {
                                if (val != null) appState.setSortBy(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            appState.isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
                            color: AppColors.primary,
                          ),
                          tooltip: appState.isGridView ? 'Switch to List View' : 'Switch to Grid View',
                          onPressed: () => appState.toggleViewMode(),
                        ),
                      ],
                    );

                    if (isNarrow) {
                      return Column(
                        children: [
                          searchInput,
                          const SizedBox(height: 12),
                          controlsRow,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchInput),
                        const SizedBox(width: 16),
                        controlsRow,
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),

                // Filter Selectors Row
                LayoutBuilder(
                  builder: (context, filterConstraints) {
                    final f1 = _filterDropdown(
                      label: 'Specialization',
                      value: appState.filterSpecialization,
                      items: ['All', 'AI Video', 'Food & Beverage', 'Product Photography', 'Animation', 'Fashion', 'Graphic Design'],
                      onChanged: (val) => appState.setFilterSpecialization(val),
                    );
                    final f2 = _filterDropdown(
                      label: 'AI Tool',
                      value: appState.filterTool,
                      items: ['All', 'Runway Gen-3', 'Midjourney v6', 'Adobe Firefly', 'Stable Diffusion XL', 'Flux.1'],
                      onChanged: (val) => appState.setFilterTool(val),
                    );
                    final f3 = _filterDropdown(
                      label: 'Visual Style',
                      value: appState.filterStyle,
                      items: ['All', 'Cinematic', 'Photorealistic', 'Luxury', 'Minimal', 'Vibrant'],
                      onChanged: (val) => appState.setFilterStyle(val),
                    );
                    final f4 = _filterDropdown(
                      label: 'Format',
                      value: appState.filterFormat,
                      items: ['All', 'Reels (9:16)', 'Video Ad (16:9)', 'Feed Stills (1:1)'],
                      onChanged: (val) => appState.setFilterFormat(val),
                    );

                    if (filterConstraints.maxWidth < 750) {
                      return Column(
                        children: [
                          Row(children: [Expanded(child: f1), const SizedBox(width: 12), Expanded(child: f2)]),
                          const SizedBox(height: 12),
                          Row(children: [Expanded(child: f3), const SizedBox(width: 12), Expanded(child: f4)]),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: f1),
                        const SizedBox(width: 12),
                        Expanded(child: f2),
                        const SizedBox(width: 12),
                        Expanded(child: f3),
                        const SizedBox(width: 12),
                        Expanded(child: f4),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Results Counter & Active Match Explanations Notice
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                'Showing ${creators.length} matching AI creators',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (activeCamp != null)
                Text(
                  'Scored against: ${activeCamp.title} (Budget: ₹${activeCamp.budget})',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Creators Grid
          if (creators.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.person_search_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('No creators match the selected filters.', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () {
                      appState.setSearchQuery('');
                      appState.setFilterSpecialization('All');
                      appState.setFilterTool('All');
                      appState.setFilterStyle('All');
                      appState.setFilterFormat('All');
                    },
                    child: const Text('Reset All Filters'),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, gridConstraints) {
                int crossAxisCount;
                double childAspectRatio;

                if (gridConstraints.maxWidth < 650) {
                  crossAxisCount = 1;
                  childAspectRatio = 1.05;
                } else if (gridConstraints.maxWidth < 1050) {
                  crossAxisCount = appState.isGridView ? 2 : 1;
                  childAspectRatio = appState.isGridView ? 1.05 : 2.1;
                } else {
                  crossAxisCount = appState.isGridView ? 3 : 1;
                  childAspectRatio = appState.isGridView ? 1.05 : 2.8;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: creators.length,
                  itemBuilder: (context, index) {
                    return CreatorCard(creator: creators[index]);
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
          ),
        ),
      ],
    );
  }
}
