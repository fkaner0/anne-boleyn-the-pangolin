import 'package:flutter/material.dart';
import 'package:pangolin_app/features/wall_creation/presentation/widgets/prompt_generator.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import '../../data/picker/gallery_image_file_picker.dart';
import '../../data/uploader/wall_image_uploader.dart';
import '../controllers/bedroom_wall_creator_controller.dart';
import '../widgets/bedroom_wall_canvas.dart';
import '../widgets/creator_tool_bar.dart';
import '../widgets/sticker_picker.dart';

class BedroomWallCreatorPage extends StatefulWidget {
  final BedroomWallCreatorController? controller;
  final ProfileBuilder? profileBuilder;
  final ProfileUpdater? profileUpdater;
  final VoidCallback? onSave;
  final VoidCallback? onSaved;
  final VoidCallback? onBack;

  const BedroomWallCreatorPage({
    super.key,
    this.controller,
    this.profileBuilder,
    this.profileUpdater,
    this.onSave,
    this.onSaved,
    this.onBack,
  });

  @override
  State<BedroomWallCreatorPage> createState() => _BedroomWallCreatorPageState();
}

class _BedroomWallCreatorPageState extends State<BedroomWallCreatorPage> {
  late final BedroomWallCreatorController _controller =
      widget.controller ??
      BedroomWallCreatorController(
        imagePicker: GalleryImageFilePicker(),
        imageUploader: getIt<ImageUploader>(),
        stickerCatalog: getIt<StickerCatalog>(),
        fontCatalog: getIt<FontCatalog>(),
      );

  late final ProfileBuilder _profileBuilder =
      widget.profileBuilder ??
      (ProfileBuilder()
        ..setUserId(0)
        ..setName('Unknown')
        ..setLocation('Unknown'));

  late final ProfileUpdater _profileUpdater =
      widget.profileUpdater ?? getIt<ProfileUpdater>();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();

  bool _saving = false;
  bool _interacting = false;
  bool _dragOverBin = false;
  int? _draggingItemId;
  bool _preview = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// The center of the currently visible canvas area, in logical canvas
  /// coordinates, so newly added items land on screen rather than off-screen
  /// at the center of the (taller-than-viewport) canvas.
  Offset _visibleCanvasCenter() {
    final canvas = _controller.canvas;
    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        renderObject.size.width == 0) {
      return Offset(canvas.width / 2, canvas.height / 2);
    }

    final size = renderObject.size;
    final scrollOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;
    final renderScale = size.width / canvas.width;
    final centerY = (size.height / 2 + scrollOffset) / renderScale;

    return Offset(canvas.width / 2, centerY.clamp(0.0, canvas.height));
  }

  Future<void> _addImage() async {
    await _controller.addImage(center: _visibleCanvasCenter());
    if (mounted) setState(() {});
  }

  void _addTextBoxWithText(String text) {
    setState(
      () =>
          _controller.addTextBoxWithText(text, center: _visibleCanvasCenter()),
    );
  }

  void _addTextBox() {
    setState(() => _controller.addTextBox(center: _visibleCanvasCenter()));
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
    setState(
      () => _controller.addSticker(stickerName, center: _visibleCanvasCenter()),
    );
  }

  void _onItemInteractionChanged(int id, bool active) {
    if (active) {
      setState(() {
        _interacting = true;
        _draggingItemId = id;
      });
      return;
    }

    final deletedId = _dragOverBin ? _draggingItemId : null;
    setState(() {
      if (deletedId != null) _controller.removeItem(deletedId);
      _interacting = false;
      _dragOverBin = false;
      _draggingItemId = null;
    });
  }

  void _onItemDragUpdate(Offset globalPosition) {
    final overBin = globalPosition.dy <= _binZoneBottom();
    if (overBin != _dragOverBin) {
      setState(() => _dragOverBin = overBin);
    }
  }

  double _binZoneBottom() {
    final renderObject = _viewportKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject.localToGlobal(Offset.zero).dy;
    }
    return MediaQuery.of(context).padding.top + kToolbarHeight;
  }

  void _onSavePressed() {
    final onSave = widget.onSave;
    if (onSave != null) {
      onSave();
      return;
    }
    _save();
  }

  Future<void> _save() async {
    if (_saving) return;

    final builder = _profileBuilder.copy();
    _controller.exportInto(builder);
    final profile = builder.build();

    setState(() => _saving = true);

    try {
      await _profileUpdater.updateProfile(profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Could not save your profile. Please try again.');
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    _showMessage('Profile saved');

    final onSaved = widget.onSaved;
    if (onSaved != null) {
      onSaved();
      return;
    }
    _openRecommendations();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openRecommendations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecommendationListPage(
          recommendationFetcher: getIt<RecommendationFetcher>(),
          profileFetcher: getIt<ProfileFetcher>(),
        ),
      ),
    );
  }

  void _togglePreview() {
    setState(() => _preview = !_preview);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _dragOverBin
            ? Theme.of(context).colorScheme.errorContainer
            : null,
        title: _interacting
            ? AppIcon(
                AppIconType.delete,
                size: _dragOverBin ? 32 : 26,
                color: _dragOverBin
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : const Text('Create your wall'),
        centerTitle: true,
        leading: IconButton(
          icon: const AppIcon(AppIconType.back),
          tooltip: 'Back',
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const AppIcon(AppIconType.preview),
            tooltip: _preview ? 'Hide Preview' : 'Preview',
            onPressed: _togglePreview,
          ),
          IconButton(
            icon: const AppIcon(AppIconType.save),
            tooltip: 'Save',
            onPressed: _saving ? null : _onSavePressed,
          ),
        ],
        bottom: _saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(minHeight: 4),
              )
            : null,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                key: _viewportKey,
                controller: _scrollController,
                child: BedroomWallCanvas(
                  canvas: _controller.canvas,
                  stickerCatalog: _controller.stickerCatalog,
                  fontCatalog: _controller.fontCatalog,
                  items: _controller.items,
                  prompts: _preview ? const [] : _controller.prompts,
                  onItemTransform: (id, transform) {
                    setState(() => _controller.updateTransform(id, transform));
                  },
                  onTextChanged: _controller.updateText,
                  onFontChanged: (id, font) {
                    setState(() => _controller.updateTextFont(id, font));
                  },
                  onTextColorChanged: (id, color) {
                    setState(
                      () => _controller.updateTextboxTextColor(id, color),
                    );
                  },
                  onTextBackgroundColorChanged: (id, color) {
                    setState(
                      () => _controller.updateTextboxBackgroundColor(id, color),
                    );
                  },
                  onPromptAddImage: _addImageFromPrompt,
                  onPromptAddTextBox: _addTextBoxFromPrompt,
                  onItemInteractionChanged: _onItemInteractionChanged,
                  onItemDragUpdate: _onItemDragUpdate,
                  editable: !_preview,
                ),
              ),
            ),
            if (!_preview)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: IgnorePointer(
                  ignoring: _interacting,
                  child: AnimatedOpacity(
                    opacity: _interacting ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        PromptGenerator(onCreate: _addTextBoxWithText),
                        CreatorToolBar(
                          onAddTextBox: _addTextBox,
                          onAddImage: _addImage,
                          onAddSticker: _addSticker,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
