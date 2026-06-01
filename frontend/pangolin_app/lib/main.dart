import 'package:flutter/material.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'features/recommendation/presentation/pages/recommendation_list_page.dart';

void main() {
  // Configure dependencies from compile-time env flags
  configureDependencies(Env.backend);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final RecommendationFetcher recommendationFetcher = getIt<RecommendationFetcher>();
  final ProfileRejectionDecider profileRejectionDecider = getIt<ProfileRejectionDecider>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pangolin App',
      home: RecommendationListPage(
        recommendationFetcher: recommendationFetcher,
        profileRejectionDecider: profileRejectionDecider,
        profileFetcher: getIt<ProfileFetcher>(),
      ),
    );
  }
}
