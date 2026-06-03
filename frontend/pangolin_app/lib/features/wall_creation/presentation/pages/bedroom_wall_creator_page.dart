import 'package:flutter/material.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import '../../data/gallery_image_file_picker.dart';
import '../controllers/bedroom_wall_creator_controller.dart';
import '../widgets/bedroom_wall_canvas.dart';
import '../widgets/creator_tool_bar.dart';

class BedroomWallCreatorPage extends StatefulWidget {
  final BedroomWallCreatorController? controller;

  const BedroomWallCreatorPage({super.key, this.controller});

  @override
  State<BedroomWallCreatorPage> createState() => _BedroomWallCreatorPageState();
}

class _BedroomWallCreatorPageState extends State<BedroomWallCreatorPage> {
  late final BedroomWallCreatorController _controller =
      widget.controller ??
      BedroomWallCreatorController(imagePicker: GalleryImageFilePicker());

  Future<void> _addImage() async {
    await _controller.addImage();
    if (mounted) setState(() {});
  }

  void _addTextBox() {
    setState(_controller.addTextBox);
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
      appBar: AppBar(
        title: const Text('Create your wall'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {},
        ),
        actions: [
          TextButton(
            onPressed: _openRecommendations,
            child: const Text('Next'),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: BedroomWallCanvas(
                  canvas: _controller.canvas,
                  imageItems: _controller.imageItems,
                  textItems: _controller.textItems,
                  onImageTransform: _controller.updateImageTransform,
                  onTextTransform: _controller.updateTextTransform,
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
                onAddSticker: _controller.addSticker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
