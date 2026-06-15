import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';

class ExampleBoardsDialog extends StatefulWidget {
  const ExampleBoardsDialog({super.key});

  static const List<String> imagePaths = [
    'assets/example_boards/example_board_1.png',
    'assets/example_boards/example_board_2.png',
    'assets/example_boards/example_board_3.png',
  ];

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const ExampleBoardsDialog(),
    );
  }

  @override
  State<ExampleBoardsDialog> createState() => _ExampleBoardsDialogState();
}

class _ExampleBoardsDialogState extends State<ExampleBoardsDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<String> get _images => ExampleBoardsDialog.imagePaths;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page.clamp(0, _images.length - 1),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 740),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 10,
              child: _Carousel(
                images: _images,
                controller: _pageController,
                currentPage: _currentPage,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onPrevious: _currentPage > 0
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                onNext: _currentPage < _images.length - 1
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          'Need some inspiration? Here are a few example walls '
                          'from other Pangopals. Swipe through for ideas, then '
                          'make the space your own.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _Carousel({
    required this.images,
    required this.controller,
    required this.currentPage,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: controller,
          itemCount: images.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) => Image.asset(
            images[index],
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: colorScheme.surfaceContainerHighest),
          ),
        ),
        if (onPrevious != null)
          Positioned(
            left: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ArrowButton(
                icon: AppIconType.chevronLeft,
                onTap: onPrevious!,
              ),
            ),
          ),
        if (onNext != null)
          Positioned(
            right: 4,
            top: 0,
            bottom: 0,
            child: Center(
              child: _ArrowButton(
                icon: AppIconType.chevronRight,
                onTap: onNext!,
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: _PageDots(count: images.length, current: currentPage),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final AppIconType icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AppIcon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  static const double _activeSize = 10;
  static const double _inactiveSize = 7;

  final int count;
  final int current;

  const _PageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? _activeSize : _inactiveSize,
            height: i == current ? _activeSize : _inactiveSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == current
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}
