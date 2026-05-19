import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';

class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final String? selectedStatus;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <String?>[null, ...TaskModel.statuses];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = options[index];
          final isSelected = selectedStatus == status;
          final label = status ?? 'All';

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onChanged(status),
            selectedColor: AppTheme.primary.withValues(alpha: 0.15),
            checkmarkColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }
}
