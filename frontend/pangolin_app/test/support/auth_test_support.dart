import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';

class _LoggedInUserIdNotifier extends UserIdNotifier {
  final int id;

  _LoggedInUserIdNotifier(this.id);

  @override
  int? build() => id;
}

Override loggedInUserId(int id) =>
    userIdProvider.overrideWith(() => _LoggedInUserIdNotifier(id));
