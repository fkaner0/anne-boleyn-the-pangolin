import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

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

  static const Duration _autoCollapse = Duration(seconds: 7);
  static const Duration _slideDuration = Duration(milliseconds: 420);
  static const Offset _hiddenOffset = Offset(1.3, 0);

  final TextEditingController _textEditingController = TextEditingController();
  final Random _random = Random();
  String _prompt = _prompts[0];

  bool _hasUsedHint = false;
  bool _expanded = true;
  Timer? _autoCollapseTimer;

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

  void _restartAutoCollapse() {
    _autoCollapseTimer?.cancel();
    if (!_hasUsedHint || !_expanded) return;
    _autoCollapseTimer = Timer(_autoCollapse, _collapse);
  }

  void _collapse() {
    _autoCollapseTimer?.cancel();
    if (!_expanded) return;
    setState(() => _expanded = false);
  }

  void _expand() {
    if (_expanded) return;
    setState(() => _expanded = true);
    _refreshPrompt();
    _restartAutoCollapse();
  }

  void _onLightbulbPressed() {
    if (_expanded) {
      _refreshPrompt();
      _restartAutoCollapse();
    } else {
      _expand();
    }
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    widget.onCreate(text);
    _refreshPrompt();
    _hasUsedHint = true;
    _collapse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ClipRect(
              child: AnimatedSlide(
                offset: _expanded ? Offset.zero : _hiddenOffset,
                duration: _slideDuration,
                curve: Curves.easeOutBack,
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: _submit,
                  onChanged: (_) => _restartAutoCollapse(),
                  decoration: InputDecoration(
                    hintText: _prompt,
                    fillColor: colorScheme.secondaryContainer,
                    filled: true,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: _onLightbulbPressed,
            tooltip: _expanded ? 'New prompt' : 'Show hint',
            icon: AppIcon(
              _expanded ? AppIconType.refresh : AppIconType.lightbulb,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _autoCollapseTimer?.cancel();
    _textEditingController.dispose();
    super.dispose();
  }
}
