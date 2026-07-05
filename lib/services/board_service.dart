import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_board.dart';
import '../models/task_item.dart';

class BoardService {
  final _db = FirebaseFirestore.instance;

  String _todayId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<DailyBoard?> getTodayBoard() async {
    final doc = await _db.collection('daily_posts').doc(_todayId()).get();
    if (!doc.exists) return null;
    return _boardFromDoc(doc.data()!);
  }

  // Real-time listener — fires immediately with current data, then again
  // every time the document changes (from any device).
  Stream<DailyBoard> watchTodayBoard() {
    return _db.collection('daily_posts').doc(_todayId()).snapshots().map((doc) {
      if (!doc.exists) {
        return DailyBoard(announcements: 'No announcements yet.', tasks: []);
      }
      return _boardFromDoc(doc.data()!);
    });
  }

  DailyBoard _boardFromDoc(Map<String, dynamic> data) {
    final tasksData = (data['tasks'] as List<dynamic>? ?? []);
    final seenByData = (data['seenBy'] as List<dynamic>? ?? []);
    return DailyBoard(
      announcements: data['announcements'] ?? '',
      tasks: tasksData.map((t) => TaskItem(
        id: t['id'],
        text: t['text'],
        done: t['done'] ?? false,
        completedBy: t['completedBy'],
      )).toList(),
      seenBy: seenByData.map((s) => s.toString()).toList(),
    );
  }

  Future<void> saveTodayBoard(DailyBoard board, {bool updateTimestamp = false}) async {
    final data = <String, dynamic>{
      'announcements': board.announcements,
      'tasks': board.tasks.map((t) => {
        'id': t.id,
        'text': t.text,
        'done': t.done,
        'completedBy': t.completedBy,
      }).toList(),
      'seenBy': board.seenBy,
    };

    if (updateTimestamp) {
      data['postedAt'] = FieldValue.serverTimestamp();
    }

    await _db.collection('daily_posts').doc(_todayId()).set(
      data,
      SetOptions(merge: true),
    );
  }
}