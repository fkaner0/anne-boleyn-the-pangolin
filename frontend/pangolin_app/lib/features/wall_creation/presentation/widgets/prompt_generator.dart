import 'dart:math';

import 'package:flutter/material.dart';

class PromptGenerator extends StatefulWidget {
  final Function(String) onCreate;

  const PromptGenerator({super.key, required this.onCreate});

  @override
  State<StatefulWidget> createState() => _PromptGeneratorState();
}

class _PromptGeneratorState extends State<PromptGenerator> {
  final List<String> prompts = [
    "I got into ... by ...",
    "I keep doing this because ...",
    "I really want to make ...",
    "I want to learn to ...",
    "I spend the rest of my time doing ...",
  ];
  final Random _random = Random();

  late String prompt = prompts[0];

  void _refreshPrompt() {
    setState(() => prompt = prompts[_random.nextInt(prompts.length)]);
  }

  void _submit(String text) {
    widget.onCreate(text);
    _refreshPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: TextField(
        readOnly: true,
        onSubmitted: _submit,
        decoration: InputDecoration(
          hintText: prompt,
          fillColor: colorScheme.secondaryContainer,
          filled: true,
          suffixIcon: IconButton(
            onPressed: _refreshPrompt,
            icon: Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }
}
