import 'package:flutter/material.dart';
import '../models/daily_board.dart';
import '../models/task_item.dart';
import 'task_picker_screen.dart';

class EditScreen extends StatefulWidget {
  final DailyBoard initialData;

  const EditScreen({super.key, required this.initialData});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _announcementsController;
  late List<TaskItem> _tasks;
  int _nextId = 100;

  @override
  void initState() {
    super.initState();
    _announcementsController = TextEditingController(text: widget.initialData.announcements);
    _tasks = widget.initialData.tasks
        .map((t) => TaskItem(id: t.id, text: t.text, done: t.done, completedBy: t.completedBy))
        .toList();
  }

  @override
  void dispose() {
    _announcementsController.dispose();
    super.dispose();
  }

  void _addTask() {
    setState(() {
      _tasks.add(TaskItem(id: 'new_${_nextId++}', text: ''));
    });
  }

  Future<void> _addFromList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskPickerScreen()),
    );
    if (result != null && result is List) {
      setState(() {
        for (final template in result) {
          _tasks.add(TaskItem(id: 'tpl_${template.id}_${_nextId++}', text: template.text));
        }
      });
    }
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _save() {
    final updated = DailyBoard(
      announcements: _announcementsController.text,
      tasks: _tasks.where((t) => t.text.trim().isNotEmpty).toList(),
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Today\'s Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Announcements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _announcementsController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Fire drill at 2pm, new client Monday',
            ),
          ),
          const SizedBox(height: 24),
          const Text('Tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: task.text)
                        ..selection = TextSelection.collapsed(offset: task.text.length),
                      onChanged: (value) => task.text = value,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () => _removeTask(index),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('New Task'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addFromList,
                  icon: const Icon(Icons.list),
                  label: const Text('From List'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}