import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/week_menu.dart';

class MenuService {
  final _db = FirebaseFirestore.instance;

  // We only ever need one week menu document — always the same fixed ID.
  static const _docId = 'current';

  Future<WeekMenu?> getWeekMenu() async {
    final doc = await _db.collection('week_menu').doc(_docId).get();
    if (!doc.exists) return null;
    return WeekMenu.fromMap(doc.data()!);
  }

  Future<void> saveWeekMenu(WeekMenu menu) async {
    await _db.collection('week_menu').doc(_docId).set(menu.toMap());
  }
}