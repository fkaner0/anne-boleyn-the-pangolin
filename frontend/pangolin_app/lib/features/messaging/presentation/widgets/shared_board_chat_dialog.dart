import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/loading_network_image.dart';
import '../../domain/shared_element.dart';
import '../../domain/shared_reply.dart';

class SharedBoardChatDialog extends StatefulWidget {
  final ValueListenable<Map<int, SharedElement>> elements;
  final int elementId;
  final int userId;
  final String friendName;
  final ValueChanged<String> onSendReply;

  const SharedBoardChatDialog({
    super.key,
    required this.elements,
    required this.elementId,
    required this.userId,
    required this.friendName,
    required this.onSendReply,
  });

  @override
  State<SharedBoardChatDialog> createState() => _SharedBoardChatDialogState();
}

class _SharedBoardChatDialogState extends State<SharedBoardChatDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendReply(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 640),
        child: ValueListenableBuilder<Map<int, SharedElement>>(
          valueListenable: widget.elements,
          builder: (context, elements, _) {
            final element = elements[widget.elementId];
            if (element == null) {
              return const SizedBox(
                height: 120,
                child: Center(child: Text('Message no longer available')),
              );
            }
            return _buildContent(context, element);
          },
        ),
      ),
    );
  }

  // // duplicated with sharedBoardPage
  // void _markRead(int elementId) {
  //   final element = _elements.value[elementId];
  //   if (element == null || element.read) return;

  //   _elements.value = {
  //     ..._elements.value,
  //     elementId: element.copyWith(read: true),
  //   };

  //   unawaited(
  //     _service
  //         .markRead(sharedElementId: elementId, userId: _userId)
  //         .catchError((_) {}),
  //   );
  // }

  Widget _buildContent(BuildContext context, SharedElement element) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const AppIcon(AppIconType.close),
              tooltip: 'Close',
              onPressed: () => {
                // _markRead    //// TODO: for some reason it doesn't need to mark stuff as read? why
                Navigator.of(context).pop()
              },
            ),
          ),
          _Header(element: element),
          const SizedBox(height: 12),
          Expanded(
            child: element.replies.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: element.replies.length,
                    itemBuilder: (context, index) => _ReplyBubble(
                      reply: element.replies[index],
                      isMine: element.replies[index].senderId == widget.userId,
                      friendName: widget.friendName,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          _Composer(controller: _controller, onSend: _send),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SharedElement element;

  const _Header({required this.element});

  @override
  Widget build(BuildContext context) {
    if (element.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height / 3 - 30,
          width: double.infinity,
          child: LoadingNetworkImage(
            url: element.content,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: AppIcon(AppIconType.brokenImage)),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        element.content,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final SharedReply reply;
  final bool isMine;
  final String friendName;

  const _ReplyBubble({
    required this.reply,
    required this.isMine,
    required this.friendName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final onColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMine ? 'You' : friendName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: onColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 2),
            Text(reply.text, style: TextStyle(color: onColor)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: (_) => onSend(),
            decoration: const InputDecoration(
              hintText: 'Write a message',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          icon: const AppIcon(AppIconType.send),
          tooltip: 'Send',
          onPressed: onSend,
        ),
      ],
    );
  }
}
