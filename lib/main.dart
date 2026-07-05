import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'models/task_item.dart';
import 'models/daily_board.dart';
import 'models/week_menu.dart';
import 'screens/edit_screen.dart';
import 'screens/edit_menu_screen.dart';
import 'screens/login_gate_screen.dart';
import 'screens/manage_templates_screen.dart';
import 'services/board_service.dart';
import 'services/local_user_service.dart';
import 'services/template_service.dart';
import 'services/menu_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  runApp(const ShiftBoardApp());
}

class ShiftBoardApp extends StatelessWidget {
  const ShiftBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftBoard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  final _localUserService = LocalUserService();
  bool _checking = true;
  String? _savedName;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  Future<void> _checkSavedUser() async {
    final name = await _localUserService.getSavedName();
    final isAdmin = await _localUserService.getSavedIsAdmin();
    setState(() {
      _savedName = name;
      _isAdmin = isAdmin;
      _checking = false;
    });
  }

  void _onLoginSuccess(String name, bool isAdmin) async {
    await _localUserService.saveUser(name, isAdmin);
    setState(() {
      _savedName = name;
      _isAdmin = isAdmin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_savedName == null) {
      return LoginGateScreen(onSuccess: _onLoginSuccess);
    }
    return HomeScreen(staffName: _savedName!, isAdmin: _isAdmin);
  }
}

class HomeScreen extends StatefulWidget {
  final String staffName;
  final bool isAdmin;

  const HomeScreen({super.key, required this.staffName, required this.isAdmin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BoardService _boardService = BoardService();
  final TemplateService _templateService = TemplateService();
  final MenuService _menuService = MenuService();
  final _localUserService = LocalUserService();

  WeekMenu weekMenu = WeekMenu.empty();
  bool _isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _ensureTodayBoardExists();
    _loadWeekMenu();
  }

  // Makes sure today's Firestore document exists (with recurring tasks
  // seeded in) before the live stream below starts watching it.
  Future<void> _ensureTodayBoardExists() async {
    final loaded = await _boardService.getTodayBoard();
    if (loaded == null) {
      final recurring = await _templateService.getRecurringTemplates();
      final newBoard = DailyBoard(
        announcements: 'No announcements yet.',
        tasks: recurring
            .map((t) => TaskItem(id: 'daily_${t.id}', text: t.text))
            .toList(),
      );
      await _boardService.saveTodayBoard(newBoard, updateTimestamp: true);
    }
  }

  Future<void> _loadWeekMenu() async {
    final loaded = await _menuService.getWeekMenu();
    if (loaded != null) {
      setState(() {
        weekMenu = loaded;
        _isLoadingMenu = false;
      });
    } else {
      final defaultMenu = WeekMenu(
        days: {
          1: DayMenu(lunch: 'Pasta with marinara', dinner: 'Grilled chicken, rice'),
          2: DayMenu(lunch: 'Turkey sandwiches', dinner: 'Beef stew'),
          3: DayMenu(lunch: 'Vegetable soup', dinner: 'Baked salmon, potatoes'),
          4: DayMenu(lunch: 'Grilled cheese', dinner: 'Chicken stir-fry'),
          5: DayMenu(lunch: 'Chicken salad', dinner: 'Pizza night'),
          6: DayMenu(lunch: 'Leftovers', dinner: 'Tacos'),
          7: DayMenu(lunch: 'Pancakes', dinner: 'Roast chicken'),
        },
      );
      await _menuService.saveWeekMenu(defaultMenu);
      setState(() {
        weekMenu = defaultMenu;
        _isLoadingMenu = false;
      });
    }
  }

  void _toggleTask(DailyBoard board, TaskItem task) {
    if (task.done && task.completedBy != widget.staffName && !widget.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only ${task.completedBy} can uncheck this task.')),
      );
      return;
    }

    task.done = !task.done;
    task.completedBy = task.done ? widget.staffName : null;
    _boardService.saveTodayBoard(board);
  }

  void _acknowledgeAnnouncement(DailyBoard board) {
    if (board.seenBy.contains(widget.staffName)) return;
    board.seenBy.add(widget.staffName);
    _boardService.saveTodayBoard(board);
  }

  Future<void> _openEditScreen(DailyBoard board) async {
    final oldAnnouncement = board.announcements;
    final result = await Navigator.push<DailyBoard>(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(initialData: board.copy())),
    );
    if (result != null) {
      result.seenBy = (result.announcements == oldAnnouncement) ? board.seenBy : [];
      await _boardService.saveTodayBoard(result, updateTimestamp: true);
    }
  }

  Future<void> _openEditMenuScreen() async {
    final result = await Navigator.push<WeekMenu>(
      context,
      MaterialPageRoute(builder: (context) => EditMenuScreen(initialMenu: weekMenu)),
    );
    if (result != null) {
      setState(() {
        weekMenu = result;
      });
      await _menuService.saveWeekMenu(result);
    }
  }

  Future<void> _openManageTemplates() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageTemplatesScreen()),
    );
  }

  Future<void> _switchUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch User'),
        content: const Text('This will sign you out on this phone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await _localUserService.clearUser();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppEntryPoint()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMenu) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return StreamBuilder<DailyBoard>(
      stream: _boardService.watchTodayBoard(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final board = snapshot.data!;
        final hasAcknowledged = board.seenBy.contains(widget.staffName);
        final hasRealAnnouncement = board.announcements.trim().isNotEmpty &&
            board.announcements != 'No announcements yet.';

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.isAdmin ? 'Today\'s Board (Admin)' : 'Today\'s Board'),
            actions: [
              if (widget.isAdmin) ...[
                IconButton(
                  icon: const Icon(Icons.checklist),
                  onPressed: _openManageTemplates,
                  tooltip: 'Manage Task List',
                ),
                IconButton(
                  icon: const Icon(Icons.restaurant_menu),
                  onPressed: _openEditMenuScreen,
                  tooltip: 'Edit Menu',
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openEditScreen(board),
                  tooltip: 'Edit',
                ),
              ],
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _switchUser,
                tooltip: 'Switch User',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Signed in as ${widget.staffName}${widget.isAdmin ? " (Admin)" : ""}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              _SectionCard(
                title: 'Menu',
                child: Text(
                  'Lunch: ${weekMenu.today.lunch}\nDinner: ${weekMenu.today.dinner}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Announcements',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(board.announcements, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    if (hasRealAnnouncement) ...[
                      if (hasAcknowledged)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.teal, size: 18),
                            SizedBox(width: 6),
                            Text('You marked this as seen', style: TextStyle(color: Colors.teal)),
                          ],
                        )
                      else
                        OutlinedButton(
                          onPressed: () => _acknowledgeAnnouncement(board),
                          child: const Text('I saw this'),
                        ),
                    ],
                    if (widget.isAdmin && board.seenBy.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Seen by: ${board.seenBy.join(', ')}',
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Tasks',
                child: board.tasks.isEmpty
                    ? const Text('No tasks yet.', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: board.tasks.map((task) {
                          final canUncheck = !task.done ||
                              task.completedBy == widget.staffName ||
                              widget.isAdmin;
                          return CheckboxListTile(
                            value: task.done,
                            onChanged: (_) => _toggleTask(board, task),
                            title: Text(
                              task.text,
                              style: TextStyle(
                                decoration: task.done ? TextDecoration.lineThrough : null,
                                color: task.done && !canUncheck ? Colors.grey.shade400 : null,
                              ),
                            ),
                            subtitle: (widget.isAdmin && task.done && task.completedBy != null)
                                ? Text('Completed by ${task.completedBy}',
                                    style: const TextStyle(fontSize: 12))
                                : null,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}