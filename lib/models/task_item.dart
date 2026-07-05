class TaskItem {
  final String id;
  String text;
  bool done;
  String? completedBy;

  TaskItem({
    required this.id,
    required this.text,
    this.done = false,
    this.completedBy,
  });
}