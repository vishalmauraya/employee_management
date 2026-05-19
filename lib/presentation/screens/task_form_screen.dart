import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final int? taskId;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'Medium';
  String _status = 'Pending';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoadingTask = false;

  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoadingTask = true);
    final task = await context.read<TaskProvider>().getTask(widget.taskId!);
    if (!mounted) return;

    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _priority = task.priority;
      _status = task.status;
      _dueDate = task.dueDate;
    }
    setState(() => _isLoadingTask = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final task = TaskModel(
      id: widget.taskId ?? 0,
      userId: 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      status: _status,
    );

    final success = await context.read<TaskProvider>().saveTask(
          task,
          taskId: widget.taskId,
        );

    if (!mounted) return;
    if (success) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoadingTask || taskProvider.isLoading,
        child: _isLoadingTask
            ? const SizedBox.shrink()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (taskProvider.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            taskProvider.errorMessage!,
                            style: const TextStyle(color: AppTheme.error),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      CustomTextField(
                        controller: _titleController,
                        label: 'Title',
                        validator: (v) => Validators.requiredField(v, 'Title'),
                        textInputAction: TextInputAction.next,
                        prefixIcon: Icons.title,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        prefixIcon: Icons.notes,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Priority',
                        value: _priority,
                        items: TaskModel.priorities,
                        onChanged: (v) => setState(() => _priority = v!),
                        icon: Icons.flag_outlined,
                      ),
                      const SizedBox(height: 20),
                      _buildDropdown(
                        label: 'Status',
                        value: _status,
                        items: TaskModel.statuses,
                        onChanged: (v) => setState(() => _status = v!),
                        icon: Icons.track_changes_outlined,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Due Date',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                            suffixIcon: const Icon(Icons.chevron_right),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: taskProvider.isLoading ? null : _save,
                        child: Text(isEditing ? 'Update Task' : 'Create Task'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(prefixIcon: Icon(icon, size: 20)),
        ),
      ],
    );
  }
}
