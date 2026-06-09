import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_list_page.dart';
import 'package:pangolin_app/features/recommendation/presentation/pages/recommendation_profile_page.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/recommendation_list_item.dart';
import 'tmp_fake_page.dart';
import '../features/profile_view/profile_viewer_page.dart';
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
  static const String editProfile = '/main/edit-profile';
  static const String profile = '/main/profile';
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
        builder: (context, state) => SignupShell(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        //// TODO: ADD NAVBAR STUFF HERE I THINK????? INSTEAD OF JUST DELEGATING TO CHILD DIRECTLY
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: AppRoutes.editProfile,
            builder: (context, state) =>
                const TmpFakePage(pageName: 'EditProfilePage()'),
          ),
          GoRoute(
            path: AppRoutes.recommendations,
            builder: (context, state) => RecommendationListPage(),
          ),
          GoRoute(
            path: AppRoutes.connections,
            builder: (context, state) =>
                const TmpFakePage(pageName: 'ConnectionsPage()'),
          ),
        ],
      ),

      // Selected user profile
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          return ProfileViewerPage(userId: userIdFromState(state));
        },
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
