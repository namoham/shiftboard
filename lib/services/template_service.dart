import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_template.dart';

class TemplateService {
  final _db = FirebaseFirestore.instance;

  Future<List<TaskTemplate>> getAllTemplates() async {
    final snapshot = await _db.collection('task_templates').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TaskTemplate(
        id: doc.id,
        text: data['text'] ?? '',
        isRecurring: data['isRecurring'] ?? false,
      );
    }).toList();
  }

  Future<List<TaskTemplate>> getRecurringTemplates() async {
    final all = await getAllTemplates();
    return all.where((t) => t.isRecurring).toList();
  }

  Future<void> addTemplate(String text, bool isRecurring) async {
    await _db.collection('task_templates').add({
      'text': text,
      'isRecurring': isRecurring,
    });
  }

  Future<void> updateTemplate(TaskTemplate template) async {
    await _db.collection('task_templates').doc(template.id).set({
      'text': template.text,
      'isRecurring': template.isRecurring,
    });
  }

  Future<void> deleteTemplate(String id) async {
    await _db.collection('task_templates').doc(id).delete();
  }
}