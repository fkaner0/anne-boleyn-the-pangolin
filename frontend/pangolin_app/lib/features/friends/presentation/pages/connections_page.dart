import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/friends/domain/current_friends.dart';
import 'package:pangolin_app/features/friends/presentation/pages/pending_connections_page.dart';
import 'package:pangolin_app/features/friends/presentation/widgets/connection_card.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/router/main_tab_navigation.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';
import 'package:pangolin_app/widgets/splodge.dart';

class ConnectionsPage extends StatefulWidget {
  final int userId;
  final FriendsFetcher? friendsFetcher;
  final ButtonClickLogger? logger;

  const ConnectionsPage({
    super.key,
    required this.userId,
    this.friendsFetcher,
    this.logger,
  });

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  late final FriendsFetcher _friendsFetcher =
      widget.friendsFetcher ?? getIt<FriendsFetcher>();

  bool _loading = true;
  String? _error;
  CurrentFriends? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _friendsFetcher.fetchCurrentFriends(widget.userId);
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
        userId: widget.userId,
        buttonId: buttonId,
      ),
    );
  }

  void _openPending() {
    _log(ButtonIds.connectionsPending);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PendingConnectionsPage(userId: widget.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connections')),
      bottomNavigationBar: IslandNavBar(
        current: IslandNavTab.friends,
        onEditProfile: () =>
            MainTabNavigation.goToEditProfile(context, widget.userId),
        onRecommendations: () =>
            MainTabNavigation.goToRecommendations(context, widget.userId),
        onFriends: () {},
      ),
      body: SafeArea(child: _buildBody()),
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
                        onTap: () => _log(ButtonIds.connectionsList),
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
              Icon(
                Icons.people_alt_outlined,
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
              Icon(Icons.chevron_right, color: colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
