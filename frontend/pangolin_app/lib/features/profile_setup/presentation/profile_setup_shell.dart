import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';

import 'pages/about_page.dart';
import 'pages/old___about_me_page.dart';

class SignupShell extends ConsumerStatefulWidget {
  // final int userId;

  const SignupShell({super.key});

  @override
  ConsumerState<SignupShell> createState() => _SignupShellState();
}

class _SignupShellState extends ConsumerState<SignupShell> {
  static const _steps = ['About', 'Wall', 'Intro'];

  int _step = 0;
  bool _submitting = false;

  late ProfileBuilder _profileBuilder = ProfileBuilder();

  @override
  void initState() {
    super.initState();
    final int? userId = ref.read(userIdProvider.notifier).currentUserId();
    assert(userId != null, 'Profile setup up requires a valid logged-in user');
    _profileBuilder = ProfileBuilder()..setUserId(userId!);
  }

  late final BedroomWallCreatorController _wallController =
      BedroomWallCreatorController(
        imagePicker: GalleryImageFilePicker(),
        imageUploader: getIt<ImageUploader>(),
        stickerCatalog: getIt<StickerCatalog>(),
        fontCatalog: getIt<FontCatalog>(),
      );

  late final ProfileUpdater _profileUpdater = getIt<ProfileUpdater>();

  void _goNext() {
    if (_step < _steps.length - 1) {
      setState(() => _step += 1);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step -= 1);
    }
  }

  Future<void> _finish() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final builder = _profileBuilder.copy();
    _wallController.exportInto(builder);
    final profile = builder.build();

    try {
      await _profileUpdater.updateProfile(profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Could not save your profile.')),
        );
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    context.push(AppRoutes.recommendations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _SignupProgressBar(currentStep: _step, steps: _steps),
            const Divider(height: 1),
            Expanded(child: _buildStep()),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => AboutPage(onNext: _goNext, profileBuilder: _profileBuilder),
      1 => BedroomWallCreatorPage(
        controller: _wallController,
        profileBuilder: _profileBuilder,
        onSave: _goNext,
        onBack: _goBack,
      ),
      2 => AboutMePage(
        profileBuilder: _profileBuilder,
        wallController: _wallController,
        onNext: _finish,
        onBack: _goBack,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SignupProgressBar extends StatelessWidget {
  static const double _connectorWidth = 40;
  static const double _ballSize = 28;

  final int currentStep;
  final List<String> steps;

  const _SignupProgressBar({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completedColor = colorScheme.primary;
    final currentColor = context.paletteColors.pangolin;
    final uncompletedColor = colorScheme.outline;

    Color colorFor(int i) {
      if (i < currentStep) return completedColor;
      if (i == currentStep) return currentColor;
      return uncompletedColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            _StepIndicator(
              label: steps[i],
              index: i + 1,
              color: colorFor(i),
              isActive: i == currentStep,
              ballSize: _ballSize,
            ),
            if (i < steps.length - 1)
              Container(
                width: _connectorWidth,
                height: 2,
                margin: const EdgeInsets.only(top: _ballSize / 2 - 1),
                color: i < currentStep ? completedColor : uncompletedColor,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final int index;
  final Color color;
  final bool isActive;
  final double ballSize;

  const _StepIndicator({
    required this.label,
    required this.index,
    required this.color,
    required this.isActive,
    required this.ballSize,
  });

  @override
  Widget build(BuildContext context) {
    final numberColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ballSize,
          height: ballSize,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: numberColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
