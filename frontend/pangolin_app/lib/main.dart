import 'package:flutter/material.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';

void main() {
  // Configure dependencies from compile-time env flags
  configureDependencies(Env.backend);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pangolin App',
      home: BedroomWallCreatorPage(),
    );
  }
}
