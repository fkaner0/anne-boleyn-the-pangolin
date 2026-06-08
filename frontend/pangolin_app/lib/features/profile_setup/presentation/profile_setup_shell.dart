import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import 'pages/about_page.dart';
import 'pages/old___about_me_page.dart';

class SignupShell extends ConsumerStatefulWidget {
  const SignupShell({super.key});

  @override
  ConsumerState<SignupShell> createState() => _SignupShellState();
}

class _SignupShellState extends ConsumerState<SignupShell> {
  static const _steps = ['About', 'Wall', 'Intro'];

  int _step = 0;
  bool _submitting = false;

  late final ProfileBuilder _profileBuilder = ProfileBuilder()..setUserId(0);

  late final BedroomWallCreatorController _wallController =
      BedroomWallCreatorController(
        imagePicker: GalleryImageFilePicker(),
        wallImageUploader: getIt<WallImageUploader>(),
        stickerCatalog: getIt<StickerCatalog>(),
        fontCatalog: getIt<FontCatalog>(),
      );

  late final ProfileUpdater _profileUpdater = getIt<ProfileUpdater>();

  void _goNext() {
    if (_step < _steps.length - 1) {
      setState(() => _step += 1);
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecommendationListPage(
          recommendationFetcher: getIt<RecommendationFetcher>(),
          profileFetcher: getIt<ProfileFetcher>(),
        ),
      ),
    );
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
      0 => AboutPage(onNext: _goNext),
      1 => BedroomWallCreatorPage(
        controller: _wallController,
        profileBuilder: _profileBuilder,
        onSave: _goNext,
      ),
      2 => AboutMePage(
        profileBuilder: _profileBuilder,
        wallController: _wallController,
        onNext: _finish,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _SignupProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const _SignupProgressBar({required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isPast = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                _StepIndicator(
                  label: steps[i],
                  index: i + 1,
                  isActive: isActive,
                  isPast: isPast,
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast
                          ? colorScheme.primary
                          : colorScheme.tertiary,

                      /// TODO: colors? idk
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final String label;
  final int index;
  final bool isActive;
  final bool isPast;

  const _StepIndicator({
    required this.label,
    required this.index,
    required this.isActive,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final color = isActive || isPast
        ? colorScheme.primary
        : colorScheme.tertiary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isPast
                ? colorScheme.primary
                : colorScheme.tertiary,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive || isPast
                    ? colorScheme.surface
                    : colorScheme.tertiary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? colorScheme.primary : colorScheme.tertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
