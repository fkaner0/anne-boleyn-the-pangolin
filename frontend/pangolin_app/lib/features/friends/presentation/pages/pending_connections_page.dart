import 'package:flutter/material.dart';

class PendingConnectionsPage extends StatelessWidget {
  final int userId;

  const PendingConnectionsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending connections')),
      body: const Center(child: Text('Coming soon')),
    );
  }
}
