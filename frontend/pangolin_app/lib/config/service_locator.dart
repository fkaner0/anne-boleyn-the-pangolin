import 'package:get_it/get_it.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/features/friends/data/friends_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/user_creator.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/compressing_wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/data/compressor/default_image_compressor.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

import 'package:pangolin_app/features/friends/data/mock_friends_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/mock_profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/mock_user_creator.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';

import 'package:pangolin_app/features/friends/data/render_friends_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/render_profile_updater.dart';
import 'package:pangolin_app/features/profile_setup/data/render_user_creator.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/render_wall_image_uploader.dart';

import 'package:pangolin_app/features/logging/data/button_click_logger.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/logging/data/render_button_click_logger.dart';

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
      getIt.registerLazySingleton<ImageUploader>(() => MockImageUploader());
      getIt.registerLazySingleton<ProfileUpdater>(() => MockProfileUpdater());
      getIt.registerLazySingleton<UserCreator>(() => MockUserCreator());
      getIt.registerLazySingleton<ButtonClickLogger>(
        () => MockButtonClickLogger(),
      );
      getIt.registerLazySingleton<FriendsFetcher>(() => MockFriendsFetcher());
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
      getIt.registerLazySingleton<ImageUploader>(
        () => CompressingImageUploader(
          RenderImageUploader(
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
      getIt.registerLazySingleton<ButtonClickLogger>(
        () => RenderButtonClickLogger(
          host: hostLocal,
          port: portLocal,
          useHttps: false,
        ),
      );
      getIt.registerLazySingleton<FriendsFetcher>(
        () => RenderFriendsFetcher(
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
      getIt.registerLazySingleton<ImageUploader>(
        () => CompressingImageUploader(
          RenderImageUploader(host: host),
          const DefaultImageCompressor(),
        ),
      );
      getIt.registerLazySingleton<ProfileUpdater>(
        () => RenderProfileUpdater(host: host),
      );
      getIt.registerLazySingleton<UserCreator>(
        () => RenderUserCreator(host: host),
      );
      getIt.registerLazySingleton<ButtonClickLogger>(
        () => RenderButtonClickLogger(host: host),
      );
      getIt.registerLazySingleton<FriendsFetcher>(
        () => RenderFriendsFetcher(host: host),
      );
      break;
  }
}
