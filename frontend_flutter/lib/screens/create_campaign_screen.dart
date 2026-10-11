import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController(text: 'Summer Cold-Drink Campaign');
  final _descriptionController = TextEditingController(
    text: 'Launch campaign for artisanal sparkling beverage. Needs high-energy, mouth-watering cinematic footage featuring chilled glass, condensation water droplets, floating ice cubes, and dramatic citrus slice splash in dramatic studio lighting.',
  );
  final _budgetController = TextEditingController(text: '50000');
  final _deadlineController = TextEditingController(text: '2026-10-28');

  String _contentType = 'AI Video';
  String _platform = 'Instagram Reels & TikTok';
  String _visualStyle = 'Cinematic';
  String _aspectRatio = '9:16';
  String _commercialUsage = 'Full Commercial Buyout';
  final List<String> _selectedTools = ['Runway Gen-3', 'Midjourney v6'];

  bool _isGeneratingBrief = false;
  bool _isPublishing = false;
  Map<String, dynamic>? _generatedBrief;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            LayoutBuilder(
              builder: (context, headerConstraints) {
                final isNarrow = headerConstraints.maxWidth < 650;
                final titleColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create AI Creator Campaign',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Define your campaign goals and let our matching engine connect you with vetted AI talent.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ],
                );

                final backBtn = OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back to Dashboard'),
                  onPressed: () => appState.navigateTo('dashboard'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleColumn,
                      const SizedBox(height: 12),
                      backBtn,
                    ],
                  );
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: titleColumn),
                    const SizedBox(width: 16),
                    backBtn,
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Responsive Layout for Form and Preview Column
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 950;

                final formCard = _buildFormCard();
                final previewColumn = _buildPreviewColumn();

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: formCard),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: previewColumn),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    formCard,
                    const SizedBox(height: 24),
                    previewColumn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Campaign Overview',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Campaign Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Campaign Name *',
              hintText: 'e.g. Summer Cold-Drink Campaign',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Campaign name is required' : null,
          ),
          const SizedBox(height: 16),

          // Brand & Product Description
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Product / Creative Vision Description *',
              hintText: 'Describe visual tone, hero elements (e.g. chilled glass, condensation, ice)...',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
          ),

          const SizedBox(height: 24),
          const Text(
            '2. Format, Platform & Visual Direction',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, fieldConstraints) {
              final isNarrow = fieldConstraints.maxWidth < 500;
              final col1 = _dropdownField(
                label: 'Content Type',
                value: _contentType,
                items: ['AI Video', 'Product Photography', '3D Animation', 'Fashion Editorial'],
                onChanged: (v) => setState(() => _contentType = v),
              );
              final col2 = _dropdownField(
                label: 'Primary Platform',
                value: _platform,
                items: ['Instagram Reels & TikTok', 'Meta Feed Ads', 'YouTube Shorts', 'Website Banner'],
                onChanged: (v) => setState(() => _platform = v),
              );

              if (isNarrow) {
                return Column(
                  children: [col1, const SizedBox(height: 14), col2],
                );
              }
              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 16),
                  Expanded(child: col2),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, fieldConstraints) {
              final isNarrow = fieldConstraints.maxWidth < 500;
              final col1 = _dropdownField(
                label: 'Visual Style',
                value: _visualStyle,
                items: ['Cinematic', 'Photorealistic', 'Luxury', 'Minimal', 'Vibrant'],
                onChanged: (v) => setState(() => _visualStyle = v),
              );
              final col2 = _dropdownField(
                label: 'Aspect Ratio',
                value: _aspectRatio,
                items: ['9:16', '16:9', '1:1', '4:5'],
                onChanged: (v) => setState(() => _aspectRatio = v),
              );

              if (isNarrow) {
                return Column(
                  children: [col1, const SizedBox(height: 14), col2],
                );
              }
              return Row(
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 16),
                  Expanded(child: col2),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Text(
            '3. Commercials & Budget',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, fieldConstraints) {
              final isNarrow = fieldConstraints.maxWidth < 500;
              final budgetField = TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Campaign Budget (₹) *',
                  prefixText: '₹ ',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Budget required' : null,
              );
              final deadlineField = TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(
                  labelText: 'Delivery Deadline *',
                  hintText: 'YYYY-MM-DD',
                ),
              );

              if (isNarrow) {
                return Column(
                  children: [budgetField, const SizedBox(height: 14), deadlineField],
                );
              }
              return Row(
                children: [
                  Expanded(child: budgetField),
                  const SizedBox(width: 16),
                  Expanded(child: deadlineField),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          _dropdownField(
            label: 'Commercial Usage Rights',
            value: _commercialUsage,
            items: ['Full Commercial Buyout', '1-Year Digital License', 'Organic Social Only'],
            onChanged: (v) => setState(() => _commercialUsage = v),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 20),

          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // AI Generate Brief Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purpleDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                icon: _isGeneratingBrief
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_isGeneratingBrief ? 'Synthesizing with AI...' : 'AI Generate Brief'),
                onPressed: _isGeneratingBrief ? null : _handleGenerateBrief,
              ),

              // Publish Campaign Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                icon: _isPublishing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.rocket_launch_rounded, size: 18),
                label: Text(_isPublishing ? 'Publishing...' : 'Publish Campaign & Match Creators'),
                onPressed: _isPublishing ? null : _handlePublishCampaign,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reference Visual Preview
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moodboard & Visual Reference',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.purpleDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.movie_creation_outlined, color: Colors.white, size: 36),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sample reference: Cold-drink studio shot with condensation macro beads and ice refraction.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Generated Brief Container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _generatedBrief != null ? AppColors.purple.withValues(alpha: 0.4) : AppColors.border,
              width: _generatedBrief != null ? 1.5 : 1,
            ),
          ),
          child: _generatedBrief == null
              ? Column(
                  children: [
                    const Icon(Icons.description_outlined, size: 36, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    const Text('No brief generated yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      'Click "AI Generate Brief" to synthesize production deliverables, visual style directives, and prompt requirements with Gemini AI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4),
                    ),
                  ],
                )
              : _buildBriefDetails(),
        ),
      ],
    );
  }

  Widget _buildBriefDetails() {
    final brief = _generatedBrief!;
    final metadata = brief['metadata'] as Map<String, dynamic>?;
    final source = metadata?['source']?.toString() ?? 'gemini';
    final isGemini = source == 'gemini';

    final title = brief['campaignTitle']?.toString() ?? 'Campaign Production Brief';
    final summary = brief['executiveSummary']?.toString() ?? brief['productDescription']?.toString() ?? '';
    final reqs = brief['contentRequirements']?.toString() ?? '';
    final styles = (brief['suggestedVisualStyles'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final deliverables = (brief['suggestedDeliverables'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final tools = (brief['preferredAITools'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final timeline = brief['suggestedTimeline']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Engine Source Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.purpleDark, size: 16),
                SizedBox(width: 6),
                Text(
                  'AI Production Brief',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.purpleDark),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isGemini ? AppColors.successBg : Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isGemini ? AppColors.success : Colors.amber.shade700,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGemini ? Icons.check_circle_outline_rounded : Icons.shield_outlined,
                    size: 11,
                    color: isGemini ? AppColors.success : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGemini ? 'Gemini AI Live' : 'Template Fallback',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isGemini ? AppColors.success : Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),

        if (summary.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],

        if (reqs.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Content Requirements:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(reqs, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3)),
        ],

        if (styles.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Suggested Visual Styles:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: styles.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(s, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
            )).toList(),
          ),
        ],

        if (deliverables.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Suggested Deliverables:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...deliverables.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Expanded(child: Text(d, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
              ],
            ),
          )),
        ],

        if (tools.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Recommended AI Stack:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tools.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.purpleLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.purpleDark)),
            )).toList(),
          ),
        ],

        if (timeline != null && timeline.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('Estimated Turnaround: $timeline', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            ],
          ),
        ],

        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.borderLight),
        const SizedBox(height: 12),

        // Apply suggestions to form button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.auto_fix_high_rounded, size: 14),
            label: const Text('Apply AI Suggestions to Form', style: TextStyle(fontSize: 11)),
            onPressed: () {
              setState(() {
                if (title.isNotEmpty && title != 'Campaign Production Brief') {
                  _nameController.text = title;
                }
                if (summary.isNotEmpty) {
                  _descriptionController.text = summary;
                }
                if (styles.isNotEmpty) {
                  final matched = ['Cinematic', 'Photorealistic', 'Luxury', 'Minimal', 'Vibrant']
                      .firstWhere((s) => styles.any((st) => st.toLowerCase().contains(s.toLowerCase())), orElse: () => _visualStyle);
                  _visualStyle = matched;
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI brief parameters applied to your campaign form!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            underline: const SizedBox(),
            items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  void _handleGenerateBrief() async {
    setState(() => _isGeneratingBrief = true);

    final brief = await ApiService.generateBrief({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'contentType': _contentType,
      'platform': _platform,
      'visualStyle': _visualStyle,
      'aspectRatio': _aspectRatio,
      'budget': int.tryParse(_budgetController.text) ?? 50000,
      'deadline': _deadlineController.text,
      'commercialUsage': _commercialUsage,
    });

    if (mounted) {
      setState(() {
        _isGeneratingBrief = false;
        _generatedBrief = brief;
      });
    }
  }

  void _handlePublishCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);
    final appState = Provider.of<AppState>(context, listen: false);

    final budgetVal = int.tryParse(_budgetController.text) ?? 50000;
    final payload = {
      'title': _nameController.text.trim(),
      'productName': 'Beverage / Commercial Asset',
      'campaignDescription': _descriptionController.text.trim(),
      'contentTypes': [_contentType],
      'requiredSkills': ['AI Video Generation', 'Liquid VFX', 'Color Grading'],
      'preferredAITools': _selectedTools,
      'desiredStyle': _visualStyle,
      'targetPlatforms': [_platform.contains('Reels') ? 'Instagram' : _platform],
      'targetAudience': 'Social Media & Consumers',
      'budgetMin': (budgetVal * 0.7).round(),
      'budgetMax': budgetVal,
      'deadline': _deadlineController.text.trim(),
      'deliverables': _generatedBrief?['suggestedDeliverables'] is List
          ? List<String>.from(_generatedBrief!['suggestedDeliverables'])
          : ['15s Hero Video (9:16)', '4x 4K Social Stills'],
      'commercialUsageRequirements': _commercialUsage,
      'status': 'published',
    };

    final newCampaign = await ApiService.createCampaign(payload);

    if (mounted) {
      setState(() => _isPublishing = false);
      appState.addCampaign(newCampaign);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Campaign "${newCampaign.title}" published! AI Match rankings updated.'),
          backgroundColor: AppColors.success,
        ),
      );
      appState.navigateTo('discovery');
    }
  }
}
