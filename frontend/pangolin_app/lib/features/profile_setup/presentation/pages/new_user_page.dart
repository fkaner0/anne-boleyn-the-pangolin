import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/auth/data/authoriser.dart';
import 'package:pangolin_app/router/app_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  final Authoriser? authoriser;

  const LoginPage({super.key, this.authoriser});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final Authoriser _authoriser = widget.authoriser ?? getIt<Authoriser>();

  bool _creating = false;

  Future<void> _makeNewUser() async {
    if (_creating) return;
    setState(() => _creating = true);

    final int userId;

    /// TMP: for before we have a login/signup sorted out
    final username = "newuser::${Random().nextDouble()}";
    try {
      userId = await _authoriser.getNewUserId(username);
    } catch (e) {
      if (!mounted) return;
      setState(() => _creating = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        // ..showSnackBar(
        //   const SnackBar(content: Text('Could not create a new user.')),
        // );
        ..showSnackBar(SnackBar(content: Text(e.toString())));
      return;
    }

    if (!mounted) return;
    setState(() => _creating = false);

    ref.read(userIdProvider.notifier).login(userId);
    context.push(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _creating
            ? const CircularProgressIndicator()
            : FilledButton(
                onPressed: _makeNewUser,
                child: const Text('Sign up'),
              ),
      ),
    );
  }
}
