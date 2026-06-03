import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import '../../data/gallery_image_file_picker.dart';
import '../controllers/bedroom_wall_creator_controller.dart';
import '../widgets/bedroom_wall_canvas.dart';
import '../widgets/creator_tool_bar.dart';
import '../widgets/sticker_picker.dart';

class BedroomWallCreatorPage extends StatefulWidget {
  final BedroomWallCreatorController? controller;
  final ProfileBuilder? profileBuilder;

  const BedroomWallCreatorPage({
    super.key,
    this.controller,
    this.profileBuilder,
  });

  @override
  State<BedroomWallCreatorPage> createState() => _BedroomWallCreatorPageState();
}

class _BedroomWallCreatorPageState extends State<BedroomWallCreatorPage> {
  late final BedroomWallCreatorController _controller =
      widget.controller ??
      BedroomWallCreatorController(
        imagePicker: GalleryImageFilePicker(),
        stickerCatalog: getIt<StickerCatalog>(),
      );

  late final ProfileBuilder _profileBuilder =
      widget.profileBuilder ??
      (ProfileBuilder()
        ..setUserId(0)
        ..setName('Unknown')
        ..setLocation('Unknown'));

  Future<void> _addImage() async {
    await _controller.addImage();
    if (mounted) setState(() {});
  }

  void _addTextBox() {
    setState(_controller.addTextBox);
  }

  Future<void> _addImageFromPrompt(int promptId) async {
    await _controller.addImageFromPrompt(promptId);
    if (mounted) setState(() {});
  }

  void _addTextBoxFromPrompt(int promptId) {
    setState(() => _controller.addTextBoxFromPrompt(promptId));
  }

  Future<void> _addSticker() async {
    final stickerName = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => StickerPicker(catalog: _controller.stickerCatalog),
    );

    if (stickerName == null || !mounted) return;
    setState(() => _controller.addSticker(stickerName));
  }

  void _save() {
    _controller.exportInto(_profileBuilder);
    final profile = _profileBuilder.build();
    debugPrint('Saved profile: ${profile.toJson()}');

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: const Text('Profile saved'),
        leading: const Icon(Icons.check_circle_outline),
        actions: [
          TextButton(
            onPressed: messenger.clearMaterialBanners,
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 2), messenger.clearMaterialBanners);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create your wall'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: BedroomWallCanvas(
                canvas: _controller.canvas,
                stickerCatalog: _controller.stickerCatalog,
                items: _controller.items,
                prompts: _controller.prompts,
                onItemTransform: _controller.updateTransform,
                onTextChanged: _controller.updateText,
                onPromptAddImage: _addImageFromPrompt,
                onPromptAddTextBox: _addTextBoxFromPrompt,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: CreatorToolBar(
                onAddTextBox: _addTextBox,
                onAddImage: _addImage,
                onAddSticker: _addSticker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
