import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_board_chat_dialog.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_element_tile.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class SharedBoardPage extends ConsumerStatefulWidget {
  final int friendUserId;
  final ProfileFetcher? profileFetcher;
  final SharedBoardService? service;
  final ImageFilePicker? imagePicker;
  final ImageUploader? imageUploader;
  final ButtonClickLogger? logger;

  const SharedBoardPage({
    super.key,
    required this.friendUserId,
    this.profileFetcher, // we should use a lighter-weight api (don't currently have one)
    this.service,
    this.imagePicker,
    this.imageUploader,
    this.logger,
  });

  @override
  ConsumerState<SharedBoardPage> createState() => _SharedBoardPageState();
}

class _SharedBoardPageState extends ConsumerState<SharedBoardPage> {
  late final SharedBoardService _service =
      widget.service ?? getIt<SharedBoardService>();
  late final ImageFilePicker _imagePicker =
      widget.imagePicker ?? getIt<ImageFilePicker>();
  late final ImageUploader _imageUploader =
      widget.imageUploader ?? getIt<ImageUploader>();
  late final ProfileFetcher _profileFetcher =
      widget.profileFetcher ?? getIt<ProfileFetcher>();
  late final int _userId;
  late final Future<String> _friendName;
  String _friendDisplayName = 'Them';

  // TODO: this does NOT belong here
  Future<String> userNameFromId(int userId) async =>
      _profileFetcher.fetchProfile(userId).then((profile) => profile.name);

  void _log(String buttonId) {
    unawaited(
      (widget.logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: ref.read(userIdProvider.notifier).currentUserIdThrow(),
        buttonId: buttonId,
      ),
    );
  }

  final ValueNotifier<Map<int, SharedElement>> _elements = ValueNotifier({});
  StreamSubscription<void>? _subscription;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _userId = ref.read(userIdProvider.notifier).currentUserIdThrow();
    _friendName = userNameFromId(widget.friendUserId); // assign once, directly
    _friendName.then((name) {
      if (mounted) setState(() => _friendDisplayName = name);
    }, onError: (_) {});
    _loadBoard();
    _subscription = _service
        .notifications(_userId)
        .listen(
          (_) => _loadBoard(),
          onError: (_) {
            if (mounted) _showMessage('Connection lost. Trying to reconnect…');
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _elements.dispose();
    super.dispose();
  }

  Future<void> _loadBoard() async {
    try {
      final board = await _service.fetchBoard(_userId, widget.friendUserId);
      if (!mounted) return;
      _elements.value = {for (final element in board) element.id: element};
    } catch (_) {
      if (mounted && _loading) _showMessage('Could not load the board.');
    } finally {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  Future<void> _uploadImage() async {
    if (_uploading) return;

    _log(ButtonIds.sharedBoardUploadImage);

    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    final message = await _promptForInitialMessage(picked);
    if (message == null || !mounted) return; // cancelled

    setState(() => _uploading = true);
    try {
      final url = await _imageUploader.uploadImage(picked.bytes);
      await _service.sendImage(
        senderId: _userId,
        receiverId: widget.friendUserId,
        url: url,
        message: message,
      );
      await _loadBoard();
    } catch (_) {
      if (mounted) _showMessage('Could not send that image.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _addText() async {
    final topicController = TextEditingController();
    final messageController = TextEditingController();

    final result = await showModalBottomSheet<TextPostResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add text post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    TextPostResult(
                      topic: topicController.text.trim(),
                      message: messageController.text.trim(),
                    ),
                  );
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      },
    );

    if (result == null || !mounted) return; // cancelled
    if (result.topic.isEmpty && result.message.isEmpty) return;

    try {
      await _service.sendText(
        senderId: _userId,
        receiverId: widget.friendUserId,
        text: result.topic,
        message: result.message,
      );
      await _loadBoard();
    } catch (_) {
      if (mounted) _showMessage('Could not send that text.');
    }
  }

  void _grabFromWall() {
    _log(ButtonIds.sharedBoardGrabFromWall);
    context.push(AppRoutes.viewProfile, extra: widget.friendUserId);
  }

  void _openChat(int elementId) async {
    final name = await _friendName;
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => SharedBoardChatDialog(
        elements: _elements,
        elementId: elementId,
        userId: _userId,
        friendName: name,
        onSendReply: (text) => _sendReply(elementId, text),
      ),
    );
  }

  Future<void> _sendReply(int elementId, String text) async {
    _log(ButtonIds.sharedBoardSendReply);

    try {
      await _service.sendReply(
        sharedElementId: elementId,
        senderId: _userId,
        receiverId: widget.friendUserId,
        text: text,
      );
      await _loadBoard();
    } catch (_) {
      if (mounted) _showMessage('Could not send that message.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _promptForInitialMessage(PickedImage picked) async {
    final controller = TextEditingController();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add a message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  picked.bytes,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Say something about this image...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text.trim());
                },
                child: const Text('Send'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _friendName,
          builder: (context, snapshot) => Text(snapshot.data ?? 'Loading...'),
        ),
        actions: [
          IconButton(
            icon: AppIcon(AppIconType.person),
            onPressed: () =>
                context.push(AppRoutes.viewProfile, extra: widget.friendUserId),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Map<int, SharedElement>>(
          valueListenable: _elements,
          builder: (context, elements, _) {
            final items = elements.values.toList();
            if (_loading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return const Center(child: Text('Nothing shared yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 36),
              itemBuilder: (context, index) {
                final element = items[index];
                return SharedElementTile(
                  element: element,
                  userId: _userId,
                  friendName: _friendDisplayName,
                  onTap: () {
                    _log(ButtonIds.sharedBoardElement);
                    _openChat(element.id);
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _BottomBar(
        uploading: _uploading,
        onGrab: _grabFromWall,
        onUpload: _uploadImage,
        onAddText: _addText,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool uploading;
  final VoidCallback onGrab;
  final VoidCallback onUpload;
  final VoidCallback onAddText;

  const _BottomBar({
    required this.uploading,
    required this.onGrab,
    required this.onUpload,
    required this.onAddText,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.5,
                  child: _GrabButton(onPressed: onGrab),
                ),
                _IconToolButton(
                  icon: AppIconType.addText,
                  onPressed: onAddText,
                ),
                _IconToolButton(
                  icon: AppIconType.addImage,
                  onPressed: onUpload,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GrabButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GrabButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: 64,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Grab from their wall',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconToolButton extends StatelessWidget {
  final AppIconType icon;
  final VoidCallback onPressed;

  const _IconToolButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: AppIcon(
              icon,
              size: 36,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class TextPostResult {
  final String topic;
  final String message;

  TextPostResult({required this.topic, required this.message});
}
