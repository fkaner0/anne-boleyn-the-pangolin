import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/info_box.dart';

const _longBio =
    'Avid potter and watercolourist who loves long countryside walks, '
    'vintage cameras, and very strong coffee here.';

Future<void> _pump(WidgetTester tester, {required double width}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: const InfoBox(
              name: 'Marcus',
              location: 'London',
              bio: _longBio,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('wraps the bio onto multiple lines', (tester) async {
    await _pump(tester, width: 300);

    final location = tester.getSize(find.text('London')).height;
    final bio = tester.getSize(find.text(_longBio)).height;
    expect(bio, greaterThan(location * 1.5));
  });

  testWidgets('all cards are the same height regardless of bio length', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              InfoBox(name: 'Short', location: 'London', bio: 'Hi'),
              InfoBox(name: 'Long', location: 'London', bio: _longBio),
            ],
          ),
        ),
      ),
    );

    final heights = tester
        .widgetList<SizedBox>(find.byType(SizedBox))
        .map((s) => s.height)
        .whereType<double>()
        .toSet();
    expect(heights, contains(170.0));
  });
}
