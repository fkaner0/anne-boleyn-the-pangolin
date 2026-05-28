import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/render_recommendation_fetcher.dart';
import 'features/recommendation/presentation/pages/recommendation_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final RecommendationFetcher recommendationFetcher =
      RenderRecommendationFetcher();
  final ProfileRejectionDecider profileRejectionDecider =
      RenderProfileRejectionDecider();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangolin App',
      home: RecommendationListPage(
        recommendationFetcher: recommendationFetcher,
        profileRejectionDecider: profileRejectionDecider,
      ),
    );
  }
}
