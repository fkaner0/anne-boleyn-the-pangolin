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

  bool _isStickerMenuOpen = false;
  bool _isStickerLoading = false;
  StickerCatalog? _loadedCatalog;

  Future<void> _addImage() async {
    await _controller.addImage();
    if (mounted) setState(() {});
  }

  void _addTextBox() {
    setState(_controller.addTextBox);
  }

  void _addSticker() async {
    if (_isStickerMenuOpen) {
      setState(() {
        _isStickerMenuOpen = false;
      });
      return;
    }

    setState(() {
      _isStickerMenuOpen = true;
      _isStickerLoading = true;
    });

    try {
      final catalog = await StickerCatalog.loadFresh();
      if (mounted) {
        setState(() {
          _loadedCatalog = catalog;
          _isStickerLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadedCatalog = StickerCatalog.fromAssetKeys(const <String>[]);
          _isStickerLoading = false;
        });
      }
    }
  }

  void _closeStickerMenu() {
    setState(() {
      _isStickerMenuOpen = false;
    });
  }

  Future<void> _selectSticker(String stickerName) async {
    final assetPath = _controller.stickerCatalog.assetForName(stickerName);
    if (assetPath != null) {
      setState(() {
        _isStickerLoading = true;
      });
      await precacheImage(AssetImage(assetPath), context);
      if (!mounted) return;
    }

    setState(() {
      _controller.addSticker(stickerName);
      _isStickerMenuOpen = false;
      _isStickerLoading = false;
    });
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

  Widget _buildStickerGrid() {
    final catalog = _loadedCatalog ?? _controller.stickerCatalog;

    if (catalog.names.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [Text('No stickers available'), SizedBox(height: 16)],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: catalog.names.length,
      itemBuilder: (context, index) {
        final stickerName = catalog.names.elementAt(index);
        final assetPath = catalog.assetForName(stickerName);
        return InkWell(
          onTap: () => _selectSticker(stickerName),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: assetPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(assetPath, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      stickerName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
          ),
        );
      },
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
                  stickerCatalog: _controller.stickerCatalog,
                  imageItems: _controller.imageItems,
                  stickerItems: _controller.stickerItems,
                  textItems: _controller.textItems,
                  onImageTransform: _controller.updateImageTransform,
                  onStickerTransform: _controller.updateStickerTransform,
                  onTextTransform: _controller.updateTextTransform,
                  onTextChanged: _controller.updateText,
                ),
              ),
            ),
            if (_isStickerMenuOpen || _isStickerLoading)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeStickerMenu,
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 104,
                          height: 340,
                          child: GestureDetector(
                            onTap: () {},
                            child: Material(
                              elevation: 12,
                              borderRadius: BorderRadius.circular(20),
                              clipBehavior: Clip.hardEdge,
                              color: Theme.of(context).colorScheme.surface,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Choose a sticker',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: _closeStickerMenu,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  Expanded(
                                    child: _isStickerLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : _buildStickerGrid(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
