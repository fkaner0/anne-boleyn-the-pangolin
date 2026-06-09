import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_edit/presentation/pages/edit_profile_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';

class MainTabNavigation {
  MainTabNavigation._();

  static void goToRecommendations(BuildContext context, int userId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecommendationListPage(
          userId: userId,
          recommendationFetcher: getIt<RecommendationFetcher>(),
          profileFetcher: getIt<ProfileFetcher>(),
        ),
      ),
    );
  }

  static void goToEditProfile(BuildContext context, int userId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => EditProfilePage(userId: userId)),
    );
  }
}
