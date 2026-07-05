class DayMenu {
  String lunch;
  String dinner;

  DayMenu({this.lunch = '', this.dinner = ''});

  DayMenu copy() => DayMenu(lunch: lunch, dinner: dinner);

  Map<String, dynamic> toMap() => {'lunch': lunch, 'dinner': dinner};

  factory DayMenu.fromMap(Map<String, dynamic> map) {
    return DayMenu(
      lunch: map['lunch'] ?? '',
      dinner: map['dinner'] ?? '',
    );
  }
}

class WeekMenu {
  Map<int, DayMenu> days;

  WeekMenu({required this.days});

  factory WeekMenu.empty() {
    return WeekMenu(
      days: {
        for (int i = 1; i <= 7; i++) i: DayMenu(),
      },
    );
  }

  DayMenu get today {
    final weekday = DateTime.now().weekday;
    return days[weekday] ?? DayMenu();
  }

  WeekMenu copy() {
    return WeekMenu(
      days: days.map((key, value) => MapEntry(key, value.copy())),
    );
  }

  Map<String, dynamic> toMap() {
    return days.map((key, value) => MapEntry(key.toString(), value.toMap()));
  }

  factory WeekMenu.fromMap(Map<String, dynamic> map) {
    final days = <int, DayMenu>{};
    for (int i = 1; i <= 7; i++) {
      final dayData = map[i.toString()];
      days[i] = dayData != null ? DayMenu.fromMap(Map<String, dynamic>.from(dayData)) : DayMenu();
    }
    return WeekMenu(days: days);
  }

  static String weekdayName(int weekday) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return names[weekday - 1];
  }
}