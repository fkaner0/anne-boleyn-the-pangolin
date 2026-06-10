import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_board_chat_dialog.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_element_tile.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class SharedBoardPage extends ConsumerStatefulWidget {
  final int friendUserId;
  final ProfileFetcher? profileFetcher;
  final SharedBoardService? service;
  final ImageFilePicker? imagePicker;
  final ImageUploader? imageUploader;

  const SharedBoardPage({
    super.key,
    required this.friendUserId,
    this.profileFetcher, // we should use a lighter-weight api (don't currently have one)
    this.service,
    this.imagePicker,
    this.imageUploader,
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

  // TODO: this does NOT belong here
  Future<String> userNameFromId(int userId) async =>
      _profileFetcher.fetchProfile(userId).then((profile) => profile.name);

  final ValueNotifier<Map<int, SharedElement>> _elements = ValueNotifier({});
  StreamSubscription<void>? _subscription;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _userId = ref.read(userIdProvider.notifier).currentUserIdThrow();
    _friendName = userNameFromId(widget.friendUserId); // assign once, directly
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

  int _now() => DateTime.now().millisecondsSinceEpoch;

  List<SharedElement> _sorted(Map<int, SharedElement> elements) {
    return elements.values.toList()
      ..sort((a, b) => b.datetime.compareTo(a.datetime));
  }

  Future<void> _uploadImage() async {
    if (_uploading) return;

    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final url = await _imageUploader.uploadImage(picked.bytes);
      await _service.sendImage(
        senderId: _userId,
        receiverId: widget.friendUserId,
        url: url,
        datetime: _now(),
      );
      await _loadBoard();
    } catch (_) {
      if (mounted) _showMessage('Could not send that image.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _grabFromWall() {
    _showMessage('Grabbing from their wall is coming soon.');
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
    try {
      await _service.sendReply(
        sharedElementId: elementId,
        senderId: _userId,
        receiverId: widget.friendUserId,
        text: text,
        datetime: _now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _friendName,
          builder: (context, snapshot) => Text(snapshot.data ?? 'Loading...'),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<Map<int, SharedElement>>(
          valueListenable: _elements,
          builder: (context, elements, _) {
            final items = _sorted(elements);
            if (_loading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (items.isEmpty) {
              return const Center(child: Text('Nothing shared yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 36),
              itemBuilder: (context, index) {
                final element = items[index];
                return SharedElementTile(
                  element: element,
                  onTap: () => _openChat(element.id),
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
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool uploading;
  final VoidCallback onGrab;
  final VoidCallback onUpload;

  const _BottomBar({
    required this.uploading,
    required this.onGrab,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onGrab,
                icon: const AppIcon(AppIconType.wallpaper),
                label: const Text('Grab from their wall'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: uploading ? null : onUpload,
                icon: uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const AppIcon(AppIconType.addImage),
                label: const Text('Upload image'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
