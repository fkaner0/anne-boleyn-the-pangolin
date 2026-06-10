import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/pending_friend.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class PendingConnectionsDialog extends StatefulWidget {
  final int userId;
  final FriendsFetcher friendsFetcher;
  final ButtonClickLogger? logger;

  const PendingConnectionsDialog({
    super.key,
    required this.userId,
    required this.friendsFetcher,
    this.logger,
  });

  @override
  State<PendingConnectionsDialog> createState() =>
      _PendingConnectionsDialogState();
}

class _PendingConnectionsDialogState extends State<PendingConnectionsDialog> {
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
        return _PendingCard(friend: friend, onTap: () => _select(friend));
      },
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingFriend friend;
  final VoidCallback onTap;

  const _PendingCard({required this.friend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(url: friend.mainImage),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AppIcon(
                AppIconType.chevronRight,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
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
