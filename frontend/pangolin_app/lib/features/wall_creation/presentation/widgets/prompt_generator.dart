import 'dart:math';
import 'package:flutter/material.dart';

class PromptGenerator extends StatefulWidget {
  final Function(String) onCreate;

  const PromptGenerator({super.key, required this.onCreate});

  @override
  State<StatefulWidget> createState() => _PromptGeneratorState();
}

class _PromptGeneratorState extends State<PromptGenerator> {
  static const List<String> _prompts = [
    "I got into ... by ...",
    "I keep doing this because ...",
    "I really want to make ...",
    "I want to learn to ...",
    "I spend the rest of my time doing ...",
  ];

  final TextEditingController _textEditingController = TextEditingController();
  final Random _random = Random();
  String _prompt = _prompts[0];

  void _refreshPrompt() {
    setState(() {
      _textEditingController.clear();
      String newPrompt;
      do {
        newPrompt = _prompts[_random.nextInt(_prompts.length)];
      } while (newPrompt == _prompt && _prompts.length > 1);
      _prompt = newPrompt;
    });
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    widget.onCreate(text);
    _refreshPrompt();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: TextField(
        controller: _textEditingController,
        onSubmitted: _submit,
        decoration: InputDecoration(
          hintText: _prompt,
          fillColor: colorScheme.secondaryContainer,
          filled: true,
          suffixIcon: IconButton(
            onPressed: _refreshPrompt,
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
