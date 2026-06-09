import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_board_chat_dialog.dart';
import 'package:pangolin_app/features/messaging/presentation/widgets/shared_element_tile.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';

class SharedBoardPage extends StatefulWidget {
  final int userId;
  final int friendUserId;
  final String friendName;
  final SharedBoardService? service;
  final ImageFilePicker? imagePicker;
  final ImageUploader? imageUploader;

  const SharedBoardPage({
    super.key,
    required this.userId,
    required this.friendUserId,
    required this.friendName,
    this.service,
    this.imagePicker,
    this.imageUploader,
  });

  @override
  State<SharedBoardPage> createState() => _SharedBoardPageState();
}

class _SharedBoardPageState extends State<SharedBoardPage> {
  late final SharedBoardService _service =
      widget.service ?? getIt<SharedBoardService>();
  late final ImageFilePicker _imagePicker =
      widget.imagePicker ?? GalleryImageFilePicker();
  late final ImageUploader _imageUploader =
      widget.imageUploader ?? getIt<ImageUploader>();

  final ValueNotifier<Map<int, SharedElement>> _elements = ValueNotifier({});
  StreamSubscription<SharedElement>? _subscription;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _subscription = _service
        .listen(widget.userId)
        .listen(_onElement, onError: _onStreamError);
  }

  void _onStreamError(Object error) {
    if (mounted) _showMessage('Connection lost. Trying to reconnect…');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _elements.dispose();
    super.dispose();
  }

  void _onElement(SharedElement element) {
    if (!element.involves(widget.userId, widget.friendUserId)) return;
    _elements.value = {..._elements.value, element.id: element};
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  List<SharedElement> _sorted(Map<int, SharedElement> elements) {
    final list = elements.values.toList()
      ..sort((a, b) => b.datetime.compareTo(a.datetime));
    return list;
  }

  Future<void> _uploadImage() async {
    if (_uploading) return;

    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final url = await _imageUploader.uploadImage(picked.bytes);
      await _service.sendImage(
        senderId: widget.userId,
        receiverId: widget.friendUserId,
        url: url,
        datetime: _now(),
      );
    } catch (_) {
      if (mounted) _showMessage('Could not send that image.');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _grabFromWall() {
    _showMessage('Grabbing from their wall is coming soon.');
  }

  void _openChat(int elementId) {
    showDialog(
      context: context,
      builder: (_) => SharedBoardChatDialog(
        elements: _elements,
        elementId: elementId,
        userId: widget.userId,
        friendName: widget.friendName,
        onSendReply: (text) => _sendReply(elementId, text),
      ),
    );
  }

  Future<void> _sendReply(int elementId, String text) async {
    try {
      await _service.sendReply(
        sharedElementId: elementId,
        senderId: widget.userId,
        receiverId: widget.friendUserId,
        text: text,
        datetime: _now(),
      );
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
      appBar: AppBar(title: Text(widget.friendName)),
      body: SafeArea(
        child: ValueListenableBuilder<Map<int, SharedElement>>(
          valueListenable: _elements,
          builder: (context, elements, _) {
            final items = _sorted(elements);
            if (items.isEmpty) {
              return const Center(child: Text('Nothing shared yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 20),
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
                icon: const Icon(Icons.wallpaper),
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
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Upload image'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
