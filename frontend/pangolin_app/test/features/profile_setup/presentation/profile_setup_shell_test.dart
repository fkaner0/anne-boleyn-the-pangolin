// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:pangolin_app/config/env.dart';
// import 'package:pangolin_app/config/service_locator.dart';
// import 'package:pangolin_app/features/auth/auth_provider.dart';
// import 'package:pangolin_app/features/auth/data/authoriser.dart';
// import 'package:pangolin_app/features/profile_setup/presentation/profile_setup_shell.dart';

// void main() {
//   setUp(() async {
//     await getIt.reset();
//     configureDependencies(BackendMode.mock);
//   });

//   Future<void> pumpShell(WidgetTester tester) async {
//     await tester.binding.setSurfaceSize(const Size(500, 1000));
//     addTearDown(() => tester.binding.setSurfaceSize(null));

//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           userIdProvider.overrideWith(() => UserIdNotifier()..login(42)),
//         ],
//         child: const MaterialApp(home: SignupShell()),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }

//   Future<void> completeAboutStep(WidgetTester tester) async {
//     await tester.tap(find.byType(DropdownButtonFormField<String>));
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Painting').last);
//     await tester.pumpAndSettle();
//     await tester.tap(find.byTooltip('Save'));
//     await tester.pumpAndSettle();
//   }

//   testWidgets('starts on the About step', (tester) async {
//     await pumpShell(tester);

//     expect(find.text('About'), findsOneWidget);
//     expect(find.text('Select a hobby'), findsOneWidget);
//   });

//   testWidgets('About advances to the wall editor', (tester) async {
//     await pumpShell(tester);
//     await completeAboutStep(tester);

//     expect(find.text('Create your wall'), findsOneWidget);
//   });

//   testWidgets('the wall save button leads to the About Me step', (
//     tester,
//   ) async {
//     await pumpShell(tester);
//     await completeAboutStep(tester);

//     expect(find.text('Create your wall'), findsOneWidget);

//     await tester.tap(find.byTooltip('Save'));
//     await tester.pumpAndSettle();

//     expect(find.text('About me'), findsOneWidget);
//   });

//   testWidgets('the wall back button returns to the About step and keeps the '
//       'selected hobby', (tester) async {
//     await pumpShell(tester);
//     await completeAboutStep(tester);

//     expect(find.text('Create your wall'), findsOneWidget);

//     await tester.tap(find.byTooltip('Back'));
//     await tester.pumpAndSettle();

//     expect(find.text('Hobby'), findsOneWidget);
//     expect(find.text('Painting'), findsOneWidget);
//   });

//   testWidgets('the About Me back button returns to the wall step', (
//     tester,
//   ) async {
//     await pumpShell(tester);
//     await completeAboutStep(tester);
//     await tester.tap(find.byTooltip('Save'));
//     await tester.pumpAndSettle();

//     expect(find.text('About me'), findsOneWidget);

//     await tester.tap(find.byTooltip('Back'));
//     await tester.pumpAndSettle();

//     expect(find.text('Create your wall'), findsOneWidget);
//   });
// }

void main() {}
