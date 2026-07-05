import 'package:flutter/material.dart';
import '../models/week_menu.dart';

class EditMenuScreen extends StatefulWidget {
  final WeekMenu initialMenu;

  const EditMenuScreen({super.key, required this.initialMenu});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  late WeekMenu _menu;
  final Map<int, TextEditingController> _lunchControllers = {};
  final Map<int, TextEditingController> _dinnerControllers = {};

  @override
  void initState() {
    super.initState();
    _menu = widget.initialMenu.copy();
    for (int i = 1; i <= 7; i++) {
      _lunchControllers[i] = TextEditingController(text: _menu.days[i]?.lunch ?? '');
      _dinnerControllers[i] = TextEditingController(text: _menu.days[i]?.dinner ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _lunchControllers.values) {
      c.dispose();
    }
    for (final c in _dinnerControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    for (int i = 1; i <= 7; i++) {
      _menu.days[i] = DayMenu(
        lunch: _lunchControllers[i]!.text,
        dinner: _dinnerControllers[i]!.text,
      );
    }
    Navigator.pop(context, _menu);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Week\'s Menu'),
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
          for (int i = 1; i <= 7; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    WeekMenu.weekdayName(i),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lunchControllers[i],
                    decoration: const InputDecoration(
                      labelText: 'Lunch',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dinnerControllers[i],
                    decoration: const InputDecoration(
                      labelText: 'Dinner',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}