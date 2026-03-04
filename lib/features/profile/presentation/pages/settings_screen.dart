import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/app/theme/theme_provider.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:trip_wise_nepal/features/auth/presentation/view_model/auth_view_model.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Light/Dark Mode'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangePasswordScreenWithValidation(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreenWithValidation extends ConsumerStatefulWidget {
  const ChangePasswordScreenWithValidation({super.key});

  @override
  ConsumerState<ChangePasswordScreenWithValidation> createState() => _ChangePasswordScreenWithValidationState();
}

class _ChangePasswordScreenWithValidationState extends ConsumerState<ChangePasswordScreenWithValidation> {
  final TextEditingController _oldPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _changePassword() async {
    setState(() { _isLoading = true; _error = null; });
    final userSession = ref.read(userSessionServiceProvider);
    final email = userSession.getCurrentUserEmail();

    if (email == null || email.isEmpty) {
      setState(() {
        _error = 'No logged-in user email found.';
        _isLoading = false;
      });
      return;
    }

    // Validate old password by attempting login
    final authVm = ref.read(authViewModelProvider.notifier);
    await authVm.login(email: email, password: _oldPasswordController.text);
    final authState = ref.read(authViewModelProvider);

    if (authState.status == AuthStatus.error) {
      setState(() {
        _error = 'Old password is incorrect.';
        _isLoading = false;
      });
      return;
    }

    // No direct change-password endpoint, so fall back to reset flow
    await authVm.requestPasswordReset(email: email);

    setState(() { _isLoading = false; });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset link sent to $email')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Enter your current password. If it is correct, we will send a password reset link to your email.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _oldPasswordController,
              decoration: const InputDecoration(labelText: 'Old Password'),
              obscureText: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF136767)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
