import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TmpFakePage extends StatelessWidget {
  final String pageName;
  const TmpFakePage({super.key, this.pageName="Untitled Page"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '(Placeholder — $pageName)',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }
}
