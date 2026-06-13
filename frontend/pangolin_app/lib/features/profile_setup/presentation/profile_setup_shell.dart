import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import 'pages/about_page.dart';
import 'pages/intro_page.dart';
import '../widgets/profile_setup_header.dart';

class SignupShell extends ConsumerStatefulWidget {
  // final int userId;

  const SignupShell({super.key});

  @override
  ConsumerState<SignupShell> createState() => _SignupShellState();
}

class _SignupShellState extends ConsumerState<SignupShell> {
  static const _steps = ['About', 'Wall', 'Details'];

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
        imagePicker: getIt<ImageFilePicker>(),
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
            ProfileSetupHeader(currentStep: _step, steps: _steps),
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
        primaryActionAsNext: true,
      ),
      2 => IntroPage(
        profileBuilder: _profileBuilder,
        wallController: _wallController,
        onNext: _finish,
        onBack: _goBack,
        primaryActionAsSave: true,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
