import 'task_item.dart';

class DailyBoard {
  String announcements;
  List<TaskItem> tasks;
  List<String> seenBy;

  DailyBoard({
    required this.announcements,
    required this.tasks,
    List<String>? seenBy,
  }) : seenBy = seenBy ?? [];

  DailyBoard copy() {
    return DailyBoard(
      announcements: announcements,
      tasks: tasks.map((t) => TaskItem(
        id: t.id, text: t.text, done: t.done, completedBy: t.completedBy,
      )).toList(),
      seenBy: List<String>.from(seenBy),
    );
  }
}