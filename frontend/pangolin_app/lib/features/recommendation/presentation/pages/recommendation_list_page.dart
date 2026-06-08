import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends StatefulWidget {
  final int userId;
  final RecommendationFetcher recommendationFetcher;
  final ProfileFetcher? profileFetcher;
  final ButtonClickLogger? logger;

  const RecommendationListPage({
    super.key,
    required this.userId,
    required this.recommendationFetcher,
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

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations = await widget.recommendationFetcher
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
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  unawaited(
                    (widget.logger ?? getIt<ButtonClickLogger>())
                        .logButtonClick(
                          userId: widget.userId,
                          buttonId: ButtonIds.recommendationList,
                        ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecommendationProfilePage(
                        viewerUserId: widget.userId,
                        profileFetcher:
                            widget.profileFetcher ?? getIt<ProfileFetcher>(),
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
