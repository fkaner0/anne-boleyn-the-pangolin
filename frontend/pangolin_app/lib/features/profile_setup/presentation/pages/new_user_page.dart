import 'package:flutter/material.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_setup/data/user_creator.dart';

import '../profile_setup_shell.dart';

class NewUserPage extends StatefulWidget {
  final UserCreator? userCreator;

  const NewUserPage({super.key, this.userCreator});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  late final UserCreator _userCreator =
      widget.userCreator ?? getIt<UserCreator>();

  bool _creating = false;

  Future<void> _makeNewUser() async {
    if (_creating) return;
    setState(() => _creating = true);

    final int userId;
    try {
      userId = await _userCreator.createUser();
    } catch (_) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Could not create a new user.')),
        );
      return;
    }

    if (!mounted) return;
    setState(() => _creating = false);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SignupShell(userId: userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _creating
            ? const CircularProgressIndicator()
            : FilledButton(
                onPressed: _makeNewUser,
                child: const Text('Make a new user'),
              ),
      ),
    );
  }
}
