import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/data/authoriser.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/router/app_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  final Authoriser? authoriser;

  const LoginPage({super.key, this.authoriser});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final Authoriser _authoriser = widget.authoriser ?? getIt<Authoriser>();
  final TextEditingController _usernameController = TextEditingController();

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool get _canSubmit => !_busy && _usernameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final username = _usernameController.text.trim();
    setState(() => _busy = true);

    final int userId;
    try {
      userId = await _authoriser.getNewUserId(username);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _logInExistingUser(username);
      return;
    }

    if (!mounted) return;
    setState(() => _busy = false);

    // Set the current logged in user id & move to setup page
    ref.read(userIdProvider.notifier).login(userId);
    context.push(AppRoutes.signup);
  }

  void _logInExistingUser(String username) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Logging in as an existing user is coming soon. '
            'Pick a new username for now.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome to PangoPal',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a username to get started',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  enabled: !_busy,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'Your username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
