import 'package:flutter/material.dart';
import 'package:pangolin_app/features/recommendation/data/api_recommendation_fecter.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'features/recommendation/presentation/pages/recommendation_list_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final RecommendationFetcher recommendationFetcher =
      ApiRecommendationFetcher(port: 8080);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangolin App',
      home: RecommendationListPage(
        recommendationFetcher: recommendationFetcher,
      ),
    );
  }
}
