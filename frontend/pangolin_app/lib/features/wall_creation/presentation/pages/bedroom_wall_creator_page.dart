import 'package:flutter/material.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import '../../data/gallery_image_file_picker.dart';
import '../controllers/bedroom_wall_creator_controller.dart';
import '../widgets/bedroom_wall_canvas.dart';
import '../widgets/creator_tool_bar.dart';
import '../widgets/sticker_picker.dart';

class BedroomWallCreatorPage extends StatefulWidget {
  final BedroomWallCreatorController? controller;

  const BedroomWallCreatorPage({super.key, this.controller});

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

  Future<void> _addImage() async {
    await _controller.addImage();
    if (mounted) setState(() {});
  }

  void _addTextBox() {
    setState(_controller.addTextBox);
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

  void _openRecommendations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecommendationListPage(
          recommendationFetcher: getIt<RecommendationFetcher>(),
          profileRejectionDecider: getIt<ProfileRejectionDecider>(),
          profileFetcher: getIt<ProfileFetcher>(),
        ),
      ),
    );
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
          TextButton(onPressed: _openRecommendations, child: const Text('Next')),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: BedroomWallCanvas(
                  canvas: _controller.canvas,
                  stickerCatalog: _controller.stickerCatalog,
                  items: _controller.items,
                  onItemTransform: _controller.updateTransform,
                  onTextChanged: _controller.updateText,
                ),
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
