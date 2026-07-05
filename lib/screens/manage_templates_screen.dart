import 'package:flutter/material.dart';
import '../models/task_template.dart';
import '../services/template_service.dart';

class ManageTemplatesScreen extends StatefulWidget {
  const ManageTemplatesScreen({super.key});

  @override
  State<ManageTemplatesScreen> createState() => _ManageTemplatesScreenState();
}

class _ManageTemplatesScreenState extends State<ManageTemplatesScreen> {
  final _service = TemplateService();
  final _newTaskController = TextEditingController();
  List<TaskTemplate> _templates = [];
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

  Future<void> _addNew() async {
    final text = _newTaskController.text.trim();
    if (text.isEmpty) return;
    await _service.addTemplate(text, false);
    _newTaskController.clear();
    await _load();
  }

  Future<void> _toggleRecurring(TaskTemplate template) async {
    template.isRecurring = !template.isRecurring;
    await _service.updateTemplate(template);
    await _load();
  }

  Future<void> _delete(TaskTemplate template) async {
    await _service.deleteTemplate(template.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Task List')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newTaskController,
                          decoration: const InputDecoration(
                            hintText: 'Add a new task to your list',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _addNew(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _addNew, child: const Text('Add')),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Toggle "Daily" to have a task auto-added every day.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ),
                const Divider(height: 24),
                Expanded(
                  child: _templates.isEmpty
                      ? const Center(child: Text('No saved tasks yet.'))
                      : ListView.builder(
                          itemCount: _templates.length,
                          itemBuilder: (context, index) {
                            final t = _templates[index];
                            return ListTile(
                              title: Text(t.text),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FilterChip(
                                    label: const Text('Daily'),
                                    selected: t.isRecurring,
                                    onSelected: (_) => _toggleRecurring(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _delete(t),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}