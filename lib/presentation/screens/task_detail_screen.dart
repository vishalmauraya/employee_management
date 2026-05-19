import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  TaskModel? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await context.read<TaskProvider>().getTask(widget.taskId);
    if (mounted) {
      setState(() {
        _task = task;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This action cannot be undone. Delete this task?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<TaskProvider>().deleteTask(widget.taskId);
      if (success && mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (_task != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/tasks/${widget.taskId}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTask,
              color: AppTheme.error,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _task == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Task not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => context.pop(), child: const Text('Go Back')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _task!.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _chip(_task!.priority, AppTheme.warning),
                          const SizedBox(width: 8),
                          _chip(_task!.status, AppTheme.primary),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _detailRow(Icons.calendar_today_outlined, 'Due Date', dateFormat.format(_task!.dueDate)),
                      const SizedBox(height: 16),
                      _detailRow(Icons.notes, 'Description', _task!.description.isEmpty ? 'No description' : _task!.description),
                      if (_task!.createdAt != null) ...[
                        const SizedBox(height: 16),
                        _detailRow(
                          Icons.access_time,
                          'Created',
                          DateFormat('MMM d, yyyy • h:mm a').format(_task!.createdAt!),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/tasks/${widget.taskId}/edit'),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Task'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _deleteTask,
                        icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                        label: const Text('Delete Task', style: TextStyle(color: AppTheme.error)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          side: const BorderSide(color: AppTheme.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
