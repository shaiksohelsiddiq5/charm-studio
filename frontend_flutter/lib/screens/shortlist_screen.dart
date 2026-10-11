import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/creator_card.dart';
import '../widgets/comparison_table.dart';

class ShortlistScreen extends StatefulWidget {
  const ShortlistScreen({super.key});

  @override
  State<ShortlistScreen> createState() => _ShortlistScreenState();
}

class _ShortlistScreenState extends State<ShortlistScreen> {
  bool _showComparisonMatrix = true;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final shortlisted = appState.shortlistedCreators;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 780;

              final titleSection = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      const Text(
                        'Shortlisted Creators',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${shortlisted.length} Selected',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Evaluate candidate creators side-by-side and issue direct creative briefs.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              );

              final actionsSection = Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  // View mode toggle
                  OutlinedButton.icon(
                    icon: Icon(
                      _showComparisonMatrix ? Icons.grid_view_rounded : Icons.table_chart_rounded,
                      size: 16,
                    ),
                    label: Text(_showComparisonMatrix ? 'Show Cards View' : 'Show Comparison Matrix'),
                    onPressed: () {
                      setState(() => _showComparisonMatrix = !_showComparisonMatrix);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send Brief to Shortlist'),
                    onPressed: shortlisted.isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Brief successfully dispatched to ${shortlisted.length} creators!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleSection,
                    const SizedBox(height: 14),
                    actionsSection,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: titleSection),
                  const SizedBox(width: 16),
                  actionsSection,
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          if (shortlisted.isEmpty)
            Container(
              padding: const EdgeInsets.all(60),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.bookmark_border_rounded, size: 54, color: AppColors.textMuted),
                  const SizedBox(height: 14),
                  const Text(
                    'No creators shortlisted yet.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore Creator Discovery and click the bookmark icon to save candidate talent here for side-by-side comparison.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => appState.navigateTo('discovery'),
                    child: const Text('Find Creators Now'),
                  ),
                ],
              ),
            )
          else ...[
            if (_showComparisonMatrix) ...[
              const Text(
                'Side-by-Side Comparison Matrix',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Benchmarks match score, pricing, turnaround velocity, tools, and availability.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              ComparisonTable(creators: shortlisted),
              const SizedBox(height: 32),
            ],

            const Text(
              'Candidate Creator Profiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, gridConstraints) {
                int crossAxisCount;
                double childAspectRatio;

                if (gridConstraints.maxWidth < 650) {
                  crossAxisCount = 1;
                  childAspectRatio = 1.05;
                } else if (gridConstraints.maxWidth < 1050) {
                  crossAxisCount = 2;
                  childAspectRatio = 1.05;
                } else {
                  crossAxisCount = 3;
                  childAspectRatio = 1.05;
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
                  itemCount: shortlisted.length,
                  itemBuilder: (context, index) {
                    return CreatorCard(creator: shortlisted[index]);
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
