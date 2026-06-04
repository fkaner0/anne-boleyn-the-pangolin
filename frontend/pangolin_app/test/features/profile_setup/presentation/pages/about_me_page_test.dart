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
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

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
    BedroomWallCreatorController? wallController,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: AboutMePage(
          profileBuilder: builder,
          imagePicker: imagePicker ?? const _FakeImageFilePicker(null),
          wallImageUploader: MockWallImageUploader(),
          wallController: wallController,
        ),
      ),
    );
  }

  BedroomWallCreatorController makeController() => BedroomWallCreatorController(
    imagePicker: const _FakeImageFilePicker(null),
    wallImageUploader: MockWallImageUploader(),
    stickerCatalog: getIt<StickerCatalog>(),
  );

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
      find.widgetWithText(TextField, 'Summarise your vibe!'),
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

    await tester.ensureVisible(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(2));
    expect(builder.build().profileImageUrl, isNotEmpty);
  });

  testWidgets('shows a live preview reflecting entered details', (
    tester,
  ) async {
    await pumpPage(tester, builder: seededBuilder());

    expect(find.text('Preview'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Your name'),
      'Zaphod',
    );
    await tester.pump();

    expect(find.text('Zaphod'), findsNWidgets(2));
  });

  testWidgets('preview shows age in brackets next to the name', (tester) async {
    await pumpPage(tester, builder: seededBuilder());

    await tester.enterText(find.widgetWithText(TextField, 'Your name'), 'Anne');
    await tester.enterText(find.widgetWithText(TextField, 'Your age'), '29');
    await tester.pump();

    expect(find.text('Anne (29)'), findsOneWidget);
  });

  testWidgets('short bio is limited to 100 characters', (tester) async {
    final builder = seededBuilder()
      ..setName('Anne')
      ..setLocation('London');
    await pumpPage(tester, builder: builder);

    final long = 'a' * 150;
    await tester.enterText(
      find.widgetWithText(TextField, 'Summarise your vibe!'),
      long,
    );
    await tester.pump();

    expect(builder.build().bio.length, 100);
  });

  Future<void> fillAllFields(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Your name'), 'Anne');
    await tester.enterText(find.widgetWithText(TextField, 'Your age'), '29');
    await tester.enterText(
      find.widgetWithText(TextField, 'Where you are based'),
      'London',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Summarise your vibe!'),
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

  testWidgets('back from the canvas returns to About me with data intact', (
    tester,
  ) async {
    await pumpPage(
      tester,
      builder: seededBuilder(),
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
    );

    await fillAllFields(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Create your wall'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('About me'), findsOneWidget);
    expect(find.text('Anne'), findsWidgets);
  });

  testWidgets('canvas keeps its items across back and forward', (tester) async {
    final controller = makeController()..addTextBox();
    await pumpPage(
      tester,
      builder: seededBuilder(),
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
      wallController: controller,
    );

    await fillAllFields(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your text', skipOffstage: false), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Your text', skipOffstage: false), findsOneWidget);
  });
}
