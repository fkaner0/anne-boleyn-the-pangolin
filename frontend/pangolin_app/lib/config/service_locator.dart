import 'package:get_it/get_it.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/user_creator.dart';
import 'package:pangolin_app/features/wall_creation/data/compressing_wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/data/default_image_compressor.dart';
import 'package:pangolin_app/features/wall_creation/data/wall_image_uploader.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import 'package:pangolin_app/features/recommendation/data/mock_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/mock_user_creator.dart';
import 'package:pangolin_app/features/wall_creation/data/mock_wall_image_uploader.dart';

import 'package:pangolin_app/features/recommendation/data/render_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/render_user_creator.dart';
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

  if (!getIt.isRegistered<FontCatalog>()) {
    getIt.registerLazySingleton<FontCatalog>(() => FontCatalog());
  }

  switch (backend) {
    case BackendMode.mock:
      getIt.registerLazySingleton<RecommendationFetcher>(
        () => MockRecommendationFetcher(),
      );
      getIt.registerLazySingleton<ProfileFetcher>(() => MockProfileFetcher());
      getIt.registerLazySingleton<WallImageUploader>(
        () => MockWallImageUploader(),
      );
      getIt.registerLazySingleton<ProfileUpdater>(() => MockProfileUpdater());
      getIt.registerLazySingleton<UserCreator>(() => MockUserCreator());
      break;
    case BackendMode.local:
      final hostLocal = Env.localHost;
      final portLocal = Env.localPort;
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
      getIt.registerLazySingleton<WallImageUploader>(
        () => CompressingWallImageUploader(
          RenderWallImageUploader(
            host: hostLocal,
            port: portLocal,
            useHttps: false,
          ),
          const DefaultImageCompressor(),
        ),
      );
      getIt.registerLazySingleton<ProfileUpdater>(
        () => RenderProfileUpdater(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      getIt.registerLazySingleton<UserCreator>(
        () => RenderUserCreator(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      break;
    case BackendMode.render:
      final host = Env.renderHost;
      getIt.registerLazySingleton<RecommendationFetcher>(
        () => RenderRecommendationFetcher(host: host),
      );
      getIt.registerLazySingleton<ProfileFetcher>(
        () => RenderProfileFetcher(host: host),
      );
      getIt.registerLazySingleton<WallImageUploader>(
        () => CompressingWallImageUploader(
          RenderWallImageUploader(host: host),
          const DefaultImageCompressor(),
        ),
      );
      getIt.registerLazySingleton<ProfileUpdater>(
        () => RenderProfileUpdater(host: host),
      );
      getIt.registerLazySingleton<UserCreator>(
        () => RenderUserCreator(host: host),
      );
      break;
  }
}
