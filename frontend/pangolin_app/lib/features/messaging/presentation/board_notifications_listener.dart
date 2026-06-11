import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';

mixin BoardNotificationsListener<T extends StatefulWidget> on State<T> {
  StreamSubscription<void>? _boardNotificationsSub;

  void listenToBoardNotifications(
    SharedBoardService service,
    int userId,
    void Function() onNotification, {
    void Function(Object error)? onError,
  }) {
    _boardNotificationsSub = service
        .notifications(userId)
        .listen((_) => onNotification(), onError: onError);
  }

  @override
  void dispose() {
    _boardNotificationsSub?.cancel();
    super.dispose();
  }
}
