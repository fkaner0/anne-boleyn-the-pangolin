import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/data/friend_action_sender.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

enum _PendingAction { ignore, reportAndIgnore }

class PendingConnectionsDialog extends StatefulWidget {
  final int userId;
  final FriendsFetcher friendsFetcher;
  final FriendActionSender? friendActionSender;
  final ButtonClickLogger? logger;

  const PendingConnectionsDialog({
    super.key,
    required this.userId,
    required this.friendsFetcher,
    this.friendActionSender,
    this.logger,
  });

  @override
  State<PendingConnectionsDialog> createState() =>
      _PendingConnectionsDialogState();
}

class _PendingConnectionsDialogState extends State<PendingConnectionsDialog> {
  late final FriendActionSender _sender =
      widget.friendActionSender ?? getIt<FriendActionSender>();

  bool _loading = true;
  String? _error;
  List<PendingFriend> _pending = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final pending = await widget.friendsFetcher.fetchPendingFriends(
        widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _pending = pending;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $error';
        _loading = false;
      });
    }
  }

  void _log(String buttonId) {
    unawaited(
      (widget.logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: widget.userId,
        buttonId: buttonId,
      ),
    );
  }

  void _close() {
    _log(ButtonIds.pendingConnectionsClose);
    Navigator.of(context).pop();
  }

  void _select(PendingFriend friend) {
    _log(ButtonIds.pendingConnection);
    Navigator.of(context).pop(friend);
  }

  Future<void> _ignore(PendingFriend friend) {
    return _runAction(
      () => _sender.reject(
        currentUserId: widget.userId,
        targetUserId: friend.friendUserId,
      ),
    );
  }

  Future<void> _reportAndIgnore(PendingFriend friend) async {
    final reported = await _runAction(() async {
      await _sender.report(
        currentUserId: widget.userId,
        targetUserId: friend.friendUserId,
      );
      await _sender.reject(
        currentUserId: widget.userId,
        targetUserId: friend.friendUserId,
      );
    });

    if (reported && mounted) {
      await _showReportConfirmation(friend.name);
    }
  }

  Future<void> _showReportConfirmation(String name) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          "$name's request has been sent to our moderation team for review, "
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

  Future<bool> _runAction(Future<void> Function() action) async {
    try {
      await action();
      if (!mounted) return false;
      await _load();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Could not complete that action.')),
          );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pending connections',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const AppIcon(AppIconType.close),
                    tooltip: 'Close',
                    onPressed: _close,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_pending.isEmpty) {
      return const Center(child: Text('No pending connections'));
    }

    return ListView.separated(
      itemCount: _pending.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final friend = _pending[index];
        return _PendingCard(
          friend: friend,
          onMessage: () => _select(friend),
          onIgnore: () => _ignore(friend),
          onReportAndIgnore: () => _reportAndIgnore(friend),
        );
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingFriend friend;
  final VoidCallback onMessage;
  final VoidCallback onIgnore;
  final VoidCallback onReportAndIgnore;

  const _PendingCard({
    required this.friend,
    required this.onMessage,
    required this.onIgnore,
    required this.onReportAndIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = friend.age == null
        ? friend.name
        : '${friend.name} (${friend.age})';

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: friend.mainImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<_PendingAction>(
                  icon: AppIcon(
                    AppIconType.moreVert,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'More',
                  onSelected: (action) {
                    switch (action) {
                      case _PendingAction.ignore:
                        onIgnore();
                      case _PendingAction.reportAndIgnore:
                        onReportAndIgnore();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _PendingAction.ignore,
                      child: Text('Ignore'),
                    ),
                    PopupMenuItem(
                      value: _PendingAction.reportAndIgnore,
                      child: Text('Report and ignore'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onMessage,
              icon: const AppIcon(AppIconType.message, size: 20),
              label: Text('Message ${friend.name}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  static const double _size = 56;

  final String url;

  const _Avatar({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: _size,
        height: _size,
        child: url.isEmpty
            ? _placeholder(colorScheme)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(colorScheme),
              ),
      ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return ColoredBox(
      color: colorScheme.surface,
      child: AppIcon(AppIconType.person, color: colorScheme.onSurfaceVariant),
    );
  }
}
