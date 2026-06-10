import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pangolin_app/router/app_router.dart';

//// TODO: pretty sure this needs to be made to work with the gorouter stuff.
class MainTabNavigation {
  MainTabNavigation._();

  static void goToRecommendations(BuildContext context) {
    context.pushReplacement(AppRoutes.recommendations);
  }

  static void goToEditProfile(BuildContext context) {
    context.pushReplacement(AppRoutes.editProfile);
  }

  static void goToFriends(BuildContext context) {
    context.pushReplacement(AppRoutes.connections);
  }
}
