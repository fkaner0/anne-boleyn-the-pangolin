import 'package:flutter/material.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/presentation/pages/connections_page.dart';
import 'package:pangolin_app/features/profile_edit/presentation/pages/edit_profile_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';

//// TODO: pretty sure this needs to be made to work with the gorouter stuff.
class MainTabNavigation {
  MainTabNavigation._();

  static void goToRecommendations(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RecommendationListPage(
          recommendationFetcher: getIt<RecommendationFetcher>(),
          profileFetcher: getIt<ProfileFetcher>(),
        ),
      ),
    );
  }

  static void goToEditProfile(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => EditProfilePage()));
  }

  static void goToFriends(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ConnectionsPage()),
    );
  }
}
