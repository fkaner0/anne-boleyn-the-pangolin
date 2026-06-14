import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/features/auth/auth_provider.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/router/main_tab_navigation.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';
import 'package:pangolin_app/widgets/pangolin_banner.dart';
import 'package:pangolin_app/widgets/pangolin_header.dart';
import 'package:pangolin_app/widgets/pangolin_mascot.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends ConsumerStatefulWidget {
  final RecommendationFetcher? recommendationFetcher;
  final ProfileFetcher? profileFetcher;
  final ButtonClickLogger? logger;

  const RecommendationListPage({
    super.key,
    this.recommendationFetcher,
    this.profileFetcher,
    this.logger,
  });

  @override
  ConsumerState<RecommendationListPage> createState() =>
      _RecommendationListPageState();
}

class _RecommendationListPageState
    extends ConsumerState<RecommendationListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Recommendation> _recommendations = [];

  late final RecommendationFetcher _recommendationFetcher =
      widget.recommendationFetcher ?? getIt<RecommendationFetcher>();

  final PangolinMascotController _mascot = PangolinMascotController();
  late final List<String> _pangolinAssets = PangolinBanner.randomTrio();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _mascot.dispose();
    super.dispose();
  }

  void _log(String buttonId) {
    unawaited(
      (widget.logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: ref.read(userIdProvider.notifier).currentUserIdThrow(),
        buttonId: buttonId,
      ),
    );
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _recommendationFetcher.fetchRecommendations(
        ref.read(userIdProvider.notifier).currentUserIdThrow(),
      );

      if (!mounted) return;
      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PangolinNavBar(
        mascotController: _mascot,
        current: IslandNavTab.recommendations,
        onEditProfile: () {
          _log(ButtonIds.recommendationListEditProfile);
          MainTabNavigation.goToEditProfile(context);
        },
        onRecommendations: () {
          _log(ButtonIds.recommendationListRecommendations);
        },
        onFriends: () {
          _log(ButtonIds.recommendationListFriends);
          MainTabNavigation.goToFriends(context);
        },
      ),
      body: SafeArea(
        child: PangolinHeader(
          title: 'Your recommendations',
          bodyBuilder: (context, topInset) =>
              NotificationListener<ScrollNotification>(
                onNotification: _mascot.handleScrollNotification,
                child: Builder(
                  builder: (context) {
                    if (_isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_errorMessage != null) {
                      return Center(child: Text(_errorMessage!));
                    }

                    if (_recommendations.isEmpty) {
                      return const Center(
                        child: Text('No recommendations available'),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 16),
                      itemCount: _recommendations.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _recommendations.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: PangolinBanner(assets: _pangolinAssets),
                          );
                        }

                        final recommendation = _recommendations[index];

                        return RecommendationListItem(
                          recommendation: recommendation,
                          onTap: () {
                            _log(ButtonIds.recommendationList);
                            context.push(
                              AppRoutes.viewProfile,
                              extra: recommendation.userId,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}
