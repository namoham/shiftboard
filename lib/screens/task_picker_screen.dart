import 'package:flutter/material.dart';
import '../models/task_template.dart';
import '../services/template_service.dart';

class TaskPickerScreen extends StatefulWidget {
  const TaskPickerScreen({super.key});

  @override
  State<TaskPickerScreen> createState() => _TaskPickerScreenState();
}

class _TaskPickerScreenState extends State<TaskPickerScreen> {
  final _service = TemplateService();
  List<TaskTemplate> _templates = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final templates = await _service.getAllTemplates();
    setState(() {
      _templates = templates;
      _loading = false;
    });
  }

  void _confirm() {
    final selected = _templates.where((t) => _selectedIds.contains(t.id)).toList();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Tasks from List'),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty ? null : _confirm,
            child: Text(
              'Add',
              style: TextStyle(
                color: _selectedIds.isEmpty ? Colors.grey : Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No saved tasks yet. Go to "Manage Task List" to add some first.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  children: _templates.map((t) {
                    return CheckboxListTile(
                      title: Text(t.text),
                      subtitle: t.isRecurring ? const Text('Daily task') : null,
                      value: _selectedIds.contains(t.id),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedIds.add(t.id);
                          } else {
                            _selectedIds.remove(t.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
    );
  }
}