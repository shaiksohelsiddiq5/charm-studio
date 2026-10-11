import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/creator_model.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class ComparisonTable extends StatelessWidget {
  final List<Creator> creators;

  const ComparisonTable({super.key, required this.creators});

  @override
  Widget build(BuildContext context) {
    if (creators.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text('Add creators to shortlist to compare them side-by-side.', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 80,
          dataRowMinHeight: 52,
          dataRowMaxHeight: 80,
          columns: [
            const DataColumn(
              label: Text(
                'Evaluation Factor',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            ...creators.map((c) => DataColumn(
              label: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryLight,
                    child: ClipOval(
                      child: Image.network(
                        c.avatar,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(c.handle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            )),
          ],
          rows: [
            // Row 1: AI Match Score
            DataRow(
              cells: [
                const DataCell(Text('AI Match Score', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.matchScore >= 85 ? AppColors.successBg : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${c.matchScore}% Match',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: c.matchScore >= 85 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                )),
              ],
            ),

            // Row 2: Starting Price
            DataRow(
              cells: [
                const DataCell(Text('Starting Budget', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Text('₹${c.startingPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
                )),
              ],
            ),

            // Row 3: Turnaround Time
            DataRow(
              cells: [
                const DataCell(Text('Turnaround Time', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Text('${c.turnaroundDays} business days'),
                )),
              ],
            ),

            // Row 4: AI Tools Stack
            DataRow(
              cells: [
                const DataCell(Text('AI Tools Stack', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Text(c.aiTools.take(3).join(', '), style: const TextStyle(fontSize: 12)),
                )),
              ],
            ),

            // Row 5: Primary Specialization
            DataRow(
              cells: [
                const DataCell(Text('Specializations', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Text(c.specializations.take(2).join(', '), style: const TextStyle(fontSize: 12)),
                )),
              ],
            ),

            // Row 6: Availability
            DataRow(
              cells: [
                const DataCell(Text('Availability', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Text(c.availability, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
                )),
              ],
            ),

            // Row 7: Actions
            DataRow(
              cells: [
                const DataCell(Text('Actions', style: TextStyle(fontWeight: FontWeight.w600))),
                ...creators.map((c) => DataCell(
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        onPressed: () => appState.navigateTo('portfolio', creator: c),
                        child: const Text('View', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => appState.toggleShortlist(c.id),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
