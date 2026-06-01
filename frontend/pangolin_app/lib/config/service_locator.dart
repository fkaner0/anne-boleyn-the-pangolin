import 'package:get_it/get_it.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';

import 'package:pangolin_app/features/recommendation/data/mock_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_rejection_decider.dart';

import 'package:pangolin_app/features/recommendation/data/render_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_rejection_decider.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies(BackendMode backend) {
  // Clear previous registrations when reconfiguring in tests
  if (getIt.isRegistered<RecommendationFetcher>()) {
    getIt.reset();
  }

  switch (backend) {
    case BackendMode.mock:
      getIt.registerLazySingleton<RecommendationFetcher>(() => MockRecommendationFetcher());
      getIt.registerLazySingleton<ProfileFetcher>(() => MockProfileFetcher());
      getIt.registerLazySingleton<ProfileRejectionDecider>(() => MockProfileRejectionDecider());
      break;
    case BackendMode.local:
      // Default to render for now; local implementations can be added later
      final hostLocal = Env.apiHost;
      getIt.registerLazySingleton<RecommendationFetcher>(() => RenderRecommendationFetcher(host: hostLocal));
      getIt.registerLazySingleton<ProfileFetcher>(() => RenderProfileFetcher(host: hostLocal));
      getIt.registerLazySingleton<ProfileRejectionDecider>(() => RenderProfileRejectionDecider(host: hostLocal));
      break;
    case BackendMode.render:
      final host = Env.apiHost;
      getIt.registerLazySingleton<RecommendationFetcher>(() => RenderRecommendationFetcher(host: host));
      getIt.registerLazySingleton<ProfileFetcher>(() => RenderProfileFetcher(host: host));
      getIt.registerLazySingleton<ProfileRejectionDecider>(() => RenderProfileRejectionDecider(host: host));
      break;
  }
}
