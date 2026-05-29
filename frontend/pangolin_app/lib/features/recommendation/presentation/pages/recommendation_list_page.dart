import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import '../../data/recommendation_fetcher.dart';
import '../../domain/recommendation.dart';
import '../widgets/recommendation_list_item.dart';

class RecommendationListPage extends StatefulWidget {
  final RecommendationFetcher recommendationFetcher;
  final ProfileRejectionDecider profileRejectionDecider;

  const RecommendationListPage({
    super.key,
    required this.recommendationFetcher,
    required this.profileRejectionDecider,
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

  Future<void> _handleDecision({
    required Recommendation recommendation,
    required bool rejected,
  }) async {
    try {
      await widget.profileRejectionDecider.putProfileRejection(
        userId: recommendation.userId,
        rejected: rejected,
      );

      setState(() {
        _recommendations.removeWhere(
          (item) => item.userId == recommendation.userId,
        );
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile decision: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your recommendations')),
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
                onAccept: () {
                  _handleDecision(
                    recommendation: recommendation,
                    rejected: true,
                  );
                },
                onReject: () {
                  _handleDecision(
                    recommendation: recommendation,
                    rejected: true,
                  );
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RecommendationProfilePage(
                        profileFetcher: RenderProfileFetcher(),
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
