class TaskTemplate {
  final String id;
  String text;
  bool isRecurring; // if true, auto-added to every new day's board

  TaskTemplate({
    required this.id,
    required this.text,
    this.isRecurring = false,
  });
}