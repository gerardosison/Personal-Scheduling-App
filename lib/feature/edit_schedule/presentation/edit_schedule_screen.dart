import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_provider.dart';

class EditScheduleScreen extends ConsumerStatefulWidget {
  final int taskId;
  const EditScheduleScreen({super.key, required this.taskId});

  @override
  ConsumerState<EditScheduleScreen> createState() =>
      _EditScheduleScreenState();
}

class _EditScheduleScreenState extends ConsumerState<EditScheduleScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = 'normal';
  bool _loaded = false;
  Task? _originalTask;
  String _repeatType = 'none';

  Future<void> _loadTask() async {
    final db = ref.read(databaseProvider);
    final tasks = await db.getAllTasks();
    final task = tasks.firstWhere((t) => t.id == widget.taskId);

    setState(() {
      _originalTask = task;
      _titleController.text = task.title;
      _messageController.text = task.message;
      _selectedDate = task.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(task.scheduledAt);
      _priority = task.priority;
      _repeatType = task.repeatType;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _updateTask() async {
    if (_titleController.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _originalTask == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title, date, and time')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final db = ref.read(databaseProvider);

    await db.updateTask(
      TasksCompanion(
        id: drift.Value(_originalTask!.id),
        title: drift.Value(_titleController.text.trim()),
        message: drift.Value(_messageController.text.trim()),
        scheduledAt: drift.Value(scheduledAt),
        priority: drift.Value(_priority),
        repeatType: drift.Value(_repeatType),
        status: drift.Value(_originalTask!.status),
        createdAt: drift.Value(_originalTask!.createdAt),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );

    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelNotification(_originalTask!.id);
    await notificationService.scheduleRecurringNotification(
      id: _originalTask!.id,
      title: _titleController.text.trim(),
      body: _messageController.text.trim().isEmpty
          ? 'Reminder: ${_titleController.text.trim()}'
          : _messageController.text.trim(),
      scheduledDate: scheduledAt,
      repeatType: _repeatType,
    );

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      _loadTask();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text('Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            ListTile(
              title: Text('Time: ${_selectedTime!.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
                        const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _repeatType,
              decoration: const InputDecoration(labelText: 'Repeat'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Does not repeat')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _repeatType = value);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _updateTask,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Update Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}