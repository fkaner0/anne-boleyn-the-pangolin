import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pangolin_app/features/profile_setup/widgets/profile_setup_header.dart';

void main() {
  testWidgets('renders a numbered, labelled bubble for each step', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSetupHeader(
            currentStep: 0,
            steps: ['About', 'Wall', 'Details'],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Wall'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
  });
}
