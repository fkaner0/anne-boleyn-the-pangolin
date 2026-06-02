import 'package:flutter/material.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import '../controllers/bedroom_wall_creator_controller.dart';
import '../widgets/bedroom_wall_canvas.dart';
import '../widgets/creator_tool_bar.dart';


class BedroomWallCreatorPage extends StatefulWidget {
  const BedroomWallCreatorPage({super.key});

  @override
  State<BedroomWallCreatorPage> createState() => _BedroomWallCreatorPageState();
}

class _BedroomWallCreatorPageState extends State<BedroomWallCreatorPage> {
  final BedroomWallCreatorController _controller =
      BedroomWallCreatorController();

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
          // Intentionally does nothing for now.
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
            // The canvas fills the screen and scrolls vertically when its
            // height exceeds the viewport.
            Positioned.fill(
              child: SingleChildScrollView(
                child: BedroomWallCanvas(canvas: _controller.canvas),
              ),
            ),
            // The creation tools float over the canvas, pinned to the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: CreatorToolBar(
                onAddTextBox: _controller.addTextBox,
                onAddImage: _controller.addImage,
                onAddSticker: _controller.addSticker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
