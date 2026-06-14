import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/friends/data/friend_action_sender.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/domain/shared_reply.dart';
import 'package:pangolin_app/features/messaging/presentation/board_notifications_listener.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_board_chat_dialog.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_element_tile.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/widgets/loading_network_image.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/pangolin_banner.dart';
import 'package:pangolin_app/widgets/pangolin_header.dart';
import 'package:pangolin_app/widgets/rolling_spinner.dart';

enum _ConnectionAction { remove, reportAndBlock, cancel }

class SharedBoardPage extends ConsumerStatefulWidget {
  final int friendUserId;
  final ProfileFetcher? profileFetcher;
  final SharedBoardService? service;
  final ImageFilePicker? imagePicker;
  final ImageUploader? imageUploader;
  final FriendActionSender? friendActionSender;
  final ButtonClickLogger? logger;

  const SharedBoardPage({
    super.key,
    required this.friendUserId,
    this.profileFetcher,
    this.service,
    this.imagePicker,
    this.imageUploader,
    this.friendActionSender,
    this.logger,
  });

  @override
  ConsumerState<SharedBoardPage> createState() => _SharedBoardPageState();
}

class _SharedBoardPageState extends ConsumerState<SharedBoardPage>
    with BoardNotificationsListener<SharedBoardPage> {
  late final SharedBoardService _service =
      widget.service ?? getIt<SharedBoardService>();
  late final ImageFilePicker _imagePicker =
      widget.imagePicker ?? getIt<ImageFilePicker>();
  late final ImageUploader _imageUploader =
      widget.imageUploader ?? getIt<ImageUploader>();
  late final ProfileFetcher _profileFetcher =
      widget.profileFetcher ?? getIt<ProfileFetcher>();
  late final FriendActionSender _friendActionSender =
      widget.friendActionSender ?? getIt<FriendActionSender>();
  late final int _userId;
  late final Future<String> _friendName;
  String _friendDisplayName = 'Them';

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
  bool _loading = true;
  bool _uploading = false;
  late final List<String> _pangolinAssets = PangolinBanner.randomTrio();
  Uint8List? _pendingImageBytes;

  @override
  void initState() {
    super.initState();
    _userId = ref.read(userIdProvider.notifier).currentUserIdThrow();
    _friendName = userNameFromId(widget.friendUserId);
    _friendName.then((name) {
      if (mounted) setState(() => _friendDisplayName = name);
    }, onError: (_) {});
    _loadInitialBoard();
    listenToBoardNotifications(
      _service,
      _userId,
      _loadBoard,
      onError: (_) {
        if (mounted) _showMessage('Connection lost. Trying to reconnect…');
      },
    );
  }

  @override
  void dispose() {
    _elements.dispose();
    super.dispose();
  }

  Future<void> _loadInitialBoard() async {
    const maxBackoff = Duration(seconds: 8);
    var backoff = const Duration(seconds: 1);
    while (mounted) {
      try {
        final board = await _service.fetchBoard(_userId, widget.friendUserId);
        if (!mounted) return;
        _elements.value = {for (final element in board) element.id: element};
        setState(() => _loading = false);
        return;
      } catch (_) {
        if (!mounted) return;
        await Future<void>.delayed(backoff);
        final next = backoff * 2;
        backoff = next > maxBackoff ? maxBackoff : next;
      }
    }
  }

  Future<void> _loadBoard() async {
    try {
      final board = await _service.fetchBoard(_userId, widget.friendUserId);
      if (!mounted) return;
      _elements.value = {for (final element in board) element.id: element};
    } catch (_) {}
  }

  void _navigateToProfile() {
    _log(ButtonIds.sharedBoardViewProfile);
    context.push(AppRoutes.viewProfile, extra: widget.friendUserId);
  }

  Future<void> _uploadImage() async {
    if (_uploading) return;

    _log(ButtonIds.sharedBoardUploadImage);

    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    final message = await _promptForInitialMessage(picked);
    if (message == null || !mounted) return;

    setState(() {
      _uploading = true;
      _pendingImageBytes = picked.bytes;
    });
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
      if (mounted) {
        setState(() {
          _uploading = false;
          _pendingImageBytes = null;
        });
      }
    }
  }

  Future<void> _addText() async {
    _log(ButtonIds.sharedBoardAddText);
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
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
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

    if (result == null || !mounted) return;
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

    final element = _elements.value[elementId];
    if (element == null) return;

    final reply = SharedReply(
      senderId: _userId,
      text: text,
      datetime: DateTime.now().millisecondsSinceEpoch,
    );
    _elements.value = {..._elements.value, elementId: element.withReply(reply)};

    try {
      await _service.sendReply(
        sharedElementId: elementId,
        senderId: _userId,
        receiverId: widget.friendUserId,
        text: text,
      );
      await _loadBoard();
    } catch (_) {
      _elements.value = {..._elements.value, elementId: element};
      if (mounted) _showMessage('Could not send that message.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _removeConnection() async {
    _log(ButtonIds.sharedBoardRemoveConnection);
    final choice = await showDialog<_ConnectionAction>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final dangerStyle = FilledButton.styleFrom(
          foregroundColor: colorScheme.error,
        );
        return AlertDialog(
          title: const Text('Manage connection'),
          content: Text('What would you like to do with $_friendDisplayName?'),
          actions: [
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).pop(_ConnectionAction.remove),
              style: dangerStyle,
              child: const Text('Remove'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).pop(_ConnectionAction.reportAndBlock),
              style: dangerStyle,
              child: const Text('Report and Block'),
            ),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.of(context).pop(_ConnectionAction.cancel),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    switch (choice) {
      case _ConnectionAction.remove:
        await _leaveConnection(
          () => _friendActionSender.remove(
            currentUserId: _userId,
            targetUserId: widget.friendUserId,
          ),
        );
        break;
      case _ConnectionAction.reportAndBlock:
        await _leaveConnection(
          () => _friendActionSender.report(
            currentUserId: _userId,
            targetUserId: widget.friendUserId,
          ),
          confirmReport: true,
        );
        break;
      case _ConnectionAction.cancel:
      case null:
        return;
    }
  }

  Future<void> _leaveConnection(
    Future<void> Function() action, {
    bool confirmReport = false,
  }) async {
    try {
      await action();
    } catch (_) {
      if (mounted) _showMessage('Could not complete that action.');
      return;
    }

    if (!mounted) return;
    if (confirmReport) {
      await _showReportConfirmation(_friendDisplayName);
      if (!mounted) return;
    }
    context.go(AppRoutes.connections);
  }

  Future<void> _showReportConfirmation(String name) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "$name has been sent to our moderation team for review, "
          "if they've broken our Code of Conduct, they'll be banned. "
          "We've blocked them for you.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
      body: SafeArea(
        child: PangolinHeader(
          title: _friendDisplayName,
          onTap: _navigateToProfile,
          onBack: () => Navigator.of(context).maybePop(),
          actions: [
            IconButton.filledTonal(
              icon: const AppIcon(AppIconType.moreHoriz),
              tooltip: 'Remove connection',
              onPressed: _removeConnection,
            ),
          ],
          bodyBuilder: (context, topInset) => _buildBoard(topInset),
        ),
      ),
      bottomNavigationBar: _BottomBar(
        onGrab: _grabFromWall,
        onUpload: _uploadImage,
        onAddText: _addText,
      ),
    );
  }

  Widget _buildBoard(double topInset) {
    return ValueListenableBuilder<Map<int, SharedElement>>(
      valueListenable: _elements,
      builder: (context, elements, _) {
        final items = elements.values.toList();
        final pendingBytes = _pendingImageBytes;

        if (_loading && items.isEmpty) {
          return const Center(child: RollingSpinner());
        }

        if (items.isEmpty && pendingBytes == null) {
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(32, topInset + 28, 32, 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Nothing shared yet'),
                      const SizedBox(height: 24),
                      PangolinBanner(assets: _pangolinAssets),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final footerIndex = items.length + (pendingBytes != null ? 1 : 0);

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(32, topInset + 28, 32, 28),
          itemCount: footerIndex + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 36),
          itemBuilder: (context, index) {
            if (index == footerIndex) {
              return PangolinBanner(assets: _pangolinAssets);
            }

            if (pendingBytes != null && index == items.length) {
              return _UploadingImageTile(bytes: pendingBytes);
            }

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
    );
  }
}

class _UploadingImageTile extends StatelessWidget {
  final Uint8List bytes;

  const _UploadingImageTile({required this.bytes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height / 5,
          child: UploadingImagePlaceholder(bytes: bytes),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onGrab;
  final VoidCallback onUpload;
  final VoidCallback onAddText;

  const _BottomBar({
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
