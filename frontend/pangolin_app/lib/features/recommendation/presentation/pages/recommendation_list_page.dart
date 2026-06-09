import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import 'package:pangolin_app/router/main_tab_navigation.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends StatefulWidget {
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
  State<RecommendationListPage> createState() => _RecommendationListPageState();
}

class _RecommendationListPageState extends State<RecommendationListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Recommendation> _recommendations = [];

  late final RecommendationFetcher _recommendationFetcher =
      widget.recommendationFetcher ?? getIt<RecommendationFetcher>();
  late final ProfileFetcher _profileFetcher =
      widget.profileFetcher ?? getIt<ProfileFetcher>();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _log(String buttonId) {
    unawaited(
      (widget.logger ?? getIt<ButtonClickLogger>()).logButtonClick(
        userId: widget.userId,
        buttonId: buttonId,
      ),
    );
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await _recommendationFetcher
          .fetchRecommendations();

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your recommendations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            _log(ButtonIds.recommendationListBack);
            Navigator.of(context).pop();
          },
        ),
      ),
      bottomNavigationBar: IslandNavBar(
        current: IslandNavTab.recommendations,
        onEditProfile: () =>
            MainTabNavigation.goToEditProfile(context, widget.userId),
        onRecommendations: () {},
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null) {
            return Center(child: Text(_errorMessage!));
          }

          if (_recommendations.isEmpty) {
            return const Center(child: Text('No recommendations available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = _recommendations[index];

              return RecommendationListItem(
                recommendation: recommendation,
                onTap: () {
                  _log(ButtonIds.recommendationList);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecommendationProfilePage(
                        profileFetcher: _profileFetcher,
                        userId: recommendation.userId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
