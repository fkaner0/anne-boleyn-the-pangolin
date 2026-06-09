import 'package:flutter/material.dart';

import 'package:pangolin_app/features/friends/domain/pending_friend.dart';

class SharedBoardPage extends StatelessWidget {
  final int userId;
  final PendingFriend friend;

  const SharedBoardPage({
    super.key,
    required this.userId,
    required this.friend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared board with ${friend.name}')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
