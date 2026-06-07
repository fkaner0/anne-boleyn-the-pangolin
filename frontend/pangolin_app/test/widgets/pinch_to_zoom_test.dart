import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/widgets/pinch_to_zoom.dart';

void main() {
  double currentScale(WidgetTester tester) {
    final transform = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PinchToZoom),
            matching: find.byType(Transform),
          ),
        )
        .first;
    return transform.transform.getMaxScaleOnAxis();
  }

  Future<void> pumpPinch(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PinchToZoom(child: SizedBox(width: 200, height: 200)),
          ),
        ),
      ),
    );
  }

  testWidgets('a two-finger pinch zooms the content in', (tester) async {
    await pumpPinch(tester);
    expect(currentScale(tester), closeTo(1.0, 0.001));

    final center = tester.getCenter(find.byType(PinchToZoom));
    final finger1 = await tester.startGesture(center - const Offset(10, 0));
    final finger2 = await tester.startGesture(center + const Offset(10, 0));
    await finger1.moveBy(const Offset(-60, 0));
    await finger2.moveBy(const Offset(60, 0));
    await tester.pump();

    expect(currentScale(tester), greaterThan(1.0));

    await finger1.up();
    await finger2.up();
    await tester.pumpAndSettle();

    expect(currentScale(tester), closeTo(1.0, 0.001));
  });

  testWidgets('a single-finger drag does not zoom', (tester) async {
    await pumpPinch(tester);

    final center = tester.getCenter(find.byType(PinchToZoom));
    await tester.dragFrom(center, const Offset(80, 0));
    await tester.pump();

    expect(currentScale(tester), closeTo(1.0, 0.001));
  });
}
