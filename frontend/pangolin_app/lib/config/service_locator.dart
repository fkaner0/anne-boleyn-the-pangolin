import 'package:get_it/get_it.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_rejection_decider.dart';
import 'package:pangolin_app/features/wall_creation/data/wall_image_uploader.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import 'package:pangolin_app/features/recommendation/data/mock_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_rejection_decider.dart';
import 'package:pangolin_app/features/wall_creation/data/mock_wall_image_uploader.dart';

import 'package:pangolin_app/features/recommendation/data/render_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_rejection_decider.dart';
import 'package:pangolin_app/features/wall_creation/data/render_wall_image_uploader.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies(BackendMode backend) {
  // Clear previous registrations when reconfiguring in tests
  if (getIt.isRegistered<RecommendationFetcher>()) {
    getIt.reset();
  }

  // Register StickerCatalog with a default empty instance
  if (!getIt.isRegistered<StickerCatalog>()) {
    getIt.registerLazySingleton<StickerCatalog>(
      () => StickerCatalog.fromAssetKeys(const <String>[]),
    );
  }

  switch (backend) {
    case BackendMode.mock:
      getIt.registerLazySingleton<RecommendationFetcher>(
        () => MockRecommendationFetcher(),
      );
      getIt.registerLazySingleton<ProfileFetcher>(() => MockProfileFetcher());
      getIt.registerLazySingleton<ProfileRejectionDecider>(
        () => MockProfileRejectionDecider(),
      );
      getIt.registerLazySingleton<WallImageUploader>(
        () => MockWallImageUploader(),
      );
      break;
    case BackendMode.local:
      final hostLocal = Env.apiHost;
      final portLocal = Env.apiPort;
      getIt.registerLazySingleton<RecommendationFetcher>(
        () => RenderRecommendationFetcher(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      getIt.registerLazySingleton<ProfileFetcher>(
        () => RenderProfileFetcher(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      getIt.registerLazySingleton<ProfileRejectionDecider>(
        () => RenderProfileRejectionDecider(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      getIt.registerLazySingleton<WallImageUploader>(
        () => RenderWallImageUploader(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      break;
    case BackendMode.render:
      final host = Env.apiHost;
      getIt.registerLazySingleton<RecommendationFetcher>(
        () => RenderRecommendationFetcher(host: host),
      );
      getIt.registerLazySingleton<ProfileFetcher>(
        () => RenderProfileFetcher(host: host),
      );
      getIt.registerLazySingleton<ProfileRejectionDecider>(
        () => RenderProfileRejectionDecider(host: host),
      );
      getIt.registerLazySingleton<WallImageUploader>(
        () => RenderWallImageUploader(host: host),
      );
      break;
  }
}
