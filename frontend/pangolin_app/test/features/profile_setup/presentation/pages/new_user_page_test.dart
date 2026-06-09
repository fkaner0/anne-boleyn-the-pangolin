import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/auth/data/authoriser.dart';
import 'package:pangolin_app/features/profile_setup/data/user_creator.dart';
import 'package:pangolin_app/features/profile_setup/presentation/pages/new_user_page.dart';

class _FakeAuthoriser implements Authoriser {
  final int id;
  final bool fail;
  final Completer<void>? gate;
  int callCount = 0;

  _FakeAuthoriser({this.id = 42, this.fail = false, this.gate});

  @override
  Future<int> getNewUserId(String username) async {
    callCount++;
    if (gate != null) await gate!.future;
    if (fail) throw Exception('no user');
    return id;
  }

  @override
  Future<int> getExistingUserId(String username) async {
    if (gate != null) await gate!.future;
    if (fail) throw Exception('no user');
    return 1;
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(WidgetTester tester, Authoriser authoriser) {
    return tester.pumpWidget(
      MaterialApp(home: LoginPage(authoriser: authoriser)),
    );
  }

  testWidgets('creating a user navigates into the signup flow', (tester) async {
    final authoriser = _FakeAuthoriser(id: 7);
    await pumpPage(tester, authoriser);

    await tester.tap(find.widgetWithText(FilledButton, 'Make a new user'));
    await tester.pumpAndSettle();

    expect(authoriser.callCount, 1);
    expect(find.text('About your craft'), findsOneWidget);
  });

  testWidgets('shows a loading spinner while creating', (tester) async {
    final gate = Completer<void>();
    await pumpPage(tester, _FakeAuthoriser(gate: gate));

    await tester.tap(find.widgetWithText(FilledButton, 'Make a new user'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('shows an error and stays on the page when creation fails', (
    tester,
  ) async {
    await pumpPage(tester, _FakeAuthoriser(fail: true));

    await tester.tap(find.widgetWithText(FilledButton, 'Make a new user'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not create'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Make a new user'),
      findsOneWidget,
    );
  });
}
