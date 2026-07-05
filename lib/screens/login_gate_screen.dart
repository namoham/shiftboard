import 'package:flutter/material.dart';

const String kStaffPin = '2468';   // regular staff PIN
const String kAdminPin = '9137';   // your supervisor PIN — change this to something only you know

class LoginGateScreen extends StatefulWidget {
  final void Function(String staffName, bool isAdmin) onSuccess;

  const LoginGateScreen({super.key, required this.onSuccess});

  @override
  State<LoginGateScreen> createState() => _LoginGateScreenState();
}

class _LoginGateScreenState extends State<LoginGateScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  String? _error;

  void _submit() {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }

    if (pin == kAdminPin) {
      widget.onSuccess(name, true);
    } else if (pin == kStaffPin) {
      widget.onSuccess(name, false);
    } else {
      setState(() => _error = 'Incorrect PIN. Try again.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.checklist_rtl, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'ShiftBoard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pinController,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _submit(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: const Text('Enter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}