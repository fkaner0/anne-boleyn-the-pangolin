import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/friends/presentation/pages/connections_page.dart';
import 'package:pangolin_app/features/profile_edit/presentation/pages/edit_profile_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/recommendation_fetcher.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/router/app_router.dart';

//// TODO: pretty sure this needs to be made to work with the gorouter stuff.
class MainTabNavigation {
  MainTabNavigation._();

  static Route<void> _fadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static void goToRecommendations(BuildContext context) {
    context.pushReplacement(AppRoutes.recommendations);
  }

  static void goToEditProfile(BuildContext context) {
    Navigator.of(context).pushReplacement(_fadeRoute(const EditProfilePage()));
  }

  static void goToFriends(BuildContext context) {
    Navigator.of(context).pushReplacement(_fadeRoute(const ConnectionsPage()));
  }
}
