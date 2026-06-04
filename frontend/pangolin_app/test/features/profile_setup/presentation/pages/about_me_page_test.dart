import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_setup/presentation/pages/about_me_page.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/wall_creation/data/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/mock_wall_image_uploader.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeImageFilePicker implements ImageFilePicker {
  final PickedImage? result;

  const _FakeImageFilePicker(this.result);

  @override
  Future<PickedImage?> pickImage() async => result;
}

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  ProfileBuilder seededBuilder() => ProfileBuilder()..setUserId(0);

  Future<void> pumpPage(
    WidgetTester tester, {
    required ProfileBuilder builder,
    ImageFilePicker? imagePicker,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: AboutMePage(
          profileBuilder: builder,
          imagePicker: imagePicker ?? const _FakeImageFilePicker(null),
          wallImageUploader: MockWallImageUploader(),
        ),
      ),
    );
  }

  testWidgets('entering fields builds them into the profile builder', (
    tester,
  ) async {
    final builder = seededBuilder();
    await pumpPage(tester, builder: builder);

    await tester.enterText(find.widgetWithText(TextField, 'Your name'), 'Anne');
    await tester.enterText(find.widgetWithText(TextField, 'Your age'), '29');
    await tester.enterText(
      find.widgetWithText(TextField, 'Where you are based'),
      'London',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'A little about you'),
      'painter and falconer',
    );

    final profile = builder.build();
    expect(profile.name, 'Anne');
    expect(profile.age, 29);
    expect(profile.location, 'London');
    expect(profile.bio, 'painter and falconer');
  });

  testWidgets('picking a main image uploads it and stores the url', (
    tester,
  ) async {
    final builder = seededBuilder()..setName('Anne').setLocation('London');
    await pumpPage(
      tester,
      builder: builder,
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(builder.build().profileImageUrl, isNotEmpty);
  });

  Future<void> fillAllFields(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Your name'), 'Anne');
    await tester.enterText(find.widgetWithText(TextField, 'Your age'), '29');
    await tester.enterText(
      find.widgetWithText(TextField, 'Where you are based'),
      'London',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'A little about you'),
      'painter',
    );
    await tester.ensureVisible(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
  }

  testWidgets('Next is disabled until every field is filled', (tester) async {
    final builder = seededBuilder();
    await pumpPage(
      tester,
      builder: builder,
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
    );

    final nextButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Next'),
    );
    expect(nextButton.onPressed, isNull);

    await fillAllFields(tester);

    final enabledNext = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Next'),
    );
    expect(enabledNext.onPressed, isNotNull);
  });

  testWidgets('Next passes the builder to the canvas editor', (tester) async {
    final builder = seededBuilder();
    await pumpPage(
      tester,
      builder: builder,
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
    );

    await fillAllFields(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Create your wall'), findsOneWidget);
  });
}
