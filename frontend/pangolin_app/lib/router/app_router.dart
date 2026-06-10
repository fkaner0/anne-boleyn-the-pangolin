import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/features/friends/presentation/pages/connections_page.dart';
import 'package:pangolin_app/features/messaging/presentation/pages/shared_board_page.dart';
import 'package:pangolin_app/features/profile_edit/presentation/pages/edit_profile_page.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import 'tmp_fake_page.dart';
import '../features/profile_setup/presentation/profile_setup_shell.dart';
import '../features/profile_setup/presentation/pages/login_page.dart';

/// Named route constants — use these everywhere instead of raw strings.
class AppRoutes {
  AppRoutes._();
  static const String login = '/';
  static const String signup = '/signup';
  static const String mainShell = '/main';
  static const String recommendations = '/main/recommendations';
  static const String connections = '/main/connections';
  static const String editProfile = '/profile/edit-profile';
  static const String editWall = '/profile/edit-wall';
  static const String viewProfile = '/main/profile';
  static const String sharedBoard = '/chat/board';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  userIdFromState(GoRouterState state) => (state.extra as int);

  return GoRouter(
    // initialLocation: AppRoutes.login,
    initialLocation: AppRoutes.login,
    routes: [
      // Login page
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Profile Setup section (manages its own internal step state)
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupShell(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        //// TODO: ADD NAVBAR STUFF HERE I THINK????? INSTEAD OF JUST DELEGATING TO CHILD DIRECTLY
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: AppRoutes.editProfile,
            pageBuilder: (context, state) => _fadeRoute(EditProfilePage()),

            // builder: (context, state) => const EditProfilePage(),
          ),
          GoRoute(
            path: AppRoutes.recommendations,
            pageBuilder: (context, state) =>
                _fadeRoute(RecommendationListPage()),
          ),
          GoRoute(
            path: AppRoutes.connections,
            pageBuilder: (context, state) => _fadeRoute(ConnectionsPage()),
          ),
        ],
      ),

      // edit current user's own wall
      GoRoute(
        path: AppRoutes.editWall,
        builder: (context, state) =>
            const TmpFakePage(pageName: "edit your bedroom wall <3"),
        // BedroomWallCreatorPage( /////// TODO?),
      ),

      // Selected user profile
      GoRoute(
        path: AppRoutes.viewProfile,
        builder: (context, state) {
          return RecommendationProfilePage(userId: userIdFromState(state));
        },
      ),

      // Selected shared board (for chatting)
      GoRoute(
        path: AppRoutes.sharedBoard,
        builder: (context, state) =>
            SharedBoardPage(friendUserId: userIdFromState(state)),
      ),
    ],

    // Redirect /main to /main/recommendations by default
    redirect: (context, state) {
      if (state.matchedLocation == '/main') {
        return AppRoutes.recommendations;
      }
      return null;
    },
  );
});

Page _fadeRoute(Widget widget) => CustomTransitionPage(
  child: widget,
  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child),
  transitionDuration: const Duration(milliseconds: 200),
);
