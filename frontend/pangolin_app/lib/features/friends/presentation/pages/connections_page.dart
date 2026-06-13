import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/connection_card.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/pending_connections_dialog.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/presentation/board_notifications_listener.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/router/main_tab_navigation.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';
import 'package:pangolin_app/widgets/pangolin_mascot.dart';
import 'package:pangolin_app/widgets/splodge.dart';

class ConnectionsPage extends ConsumerStatefulWidget {
  final FriendsFetcher? friendsFetcher;
  final SharedBoardService? boardService;
  final ButtonClickLogger? logger;

  const ConnectionsPage({
    super.key,
    this.friendsFetcher,
    this.boardService,
    this.logger,
  });

  @override
  ConsumerState<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends ConsumerState<ConnectionsPage>
    with BoardNotificationsListener<ConnectionsPage> {
  late final FriendsFetcher _friendsFetcher =
      widget.friendsFetcher ?? getIt<FriendsFetcher>();
  late final SharedBoardService _boardService =
      widget.boardService ?? getIt<SharedBoardService>();
  late final int _userId;

  bool _loading = true;
  String? _error;
  CurrentFriends? _data;

  final PangolinMascotController _mascot = PangolinMascotController();

  @override
  void initState() {
    super.initState();
    _userId = ref.read(userIdProvider.notifier).currentUserIdThrow();
    _load();
    listenToBoardNotifications(_boardService, _userId, _load);
  }

  @override
  void dispose() {
    _mascot.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _friendsFetcher.fetchCurrentFriends(_userId);
      if (!mounted) return;
      setState(() {
        _data = data;
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
        userId: _userId,
        buttonId: buttonId,
      ),
    );
  }

  Future<void> _openPending() async {
    _log(ButtonIds.connectionsPending);

    final selected = await showDialog<PendingSelection>(
      context: context,
      builder: (_) => PendingConnectionsDialog(
        userId: _userId,
        friendsFetcher: _friendsFetcher,
        boardService: _boardService,
        logger: widget.logger,
      ),
    );

    if (selected == null || !mounted) return;

    switch (selected.kind) {
      case PendingActionKind.reply:
        _openBoard(selected.friend.friendUserId, selected.friend.name);
      case PendingActionKind.viewProfile:
        context.push(
          AppRoutes.viewProfile,
          extra: selected.friend.friendUserId,
        );
    }
  }

  Future<void> _openBoard(int friendUserId, String friendName) async {
    await context.push(AppRoutes.sharedBoard, extra: friendUserId);
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: PangolinNavBar(
        mascotController: _mascot,
        current: IslandNavTab.friends,
        onEditProfile: () {
          _log(ButtonIds.connectionsEditProfile);
          MainTabNavigation.goToEditProfile(context);
        },
        onRecommendations: () {
          _log(ButtonIds.connectionsRecommendations);
          MainTabNavigation.goToRecommendations(context);
        },
        onFriends: () {
          _log(ButtonIds.connectionsFriends);
        },
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _mascot.handleScrollNotification,
        child: SafeArea(child: _buildBody()),
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

    final data = _data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _PendingConnectionsButton(
            count: data.pendingCount,
            onTap: _openPending,
          ),
        ),
        Expanded(
          child: data.friends.isEmpty
              ? const Center(child: Text('No connections yet'))
              : GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    for (final (index, friend) in data.friends.indexed)
                      ConnectionCard(
                        friend: friend,
                        variant: index % SplodgeClipper.variantCount,
                        onTap: () {
                          _log(ButtonIds.connectionsList);
                          _openBoard(friend.friendUserId, friend.name);
                        },
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _PendingConnectionsButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _PendingConnectionsButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = count == 1
        ? '1 pending connection'
        : '$count pending connections';

    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              AppIcon(
                AppIconType.peopleAlt,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppIcon(
                AppIconType.chevronRight,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
