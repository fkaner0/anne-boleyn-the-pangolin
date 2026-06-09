import 'package:flutter_riverpod/flutter_riverpod.dart';

final userIdProvider = NotifierProvider<UserIdNotifier, int?>(() {
  return UserIdNotifier();
});

class UserIdNotifier extends Notifier<int?> {
  @override
  int? build() => null; // not logged in by default

  void login(int userId) => state = userId;

  int? currentUserId() => state;

  int currentUserIdThrow() {
    assert(state != null, 'No logged-in user found');
    return state!;
  }
}
