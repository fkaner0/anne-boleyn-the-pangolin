import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/wall_creation/data/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/mock_wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
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

  Future<void> pumpPage(
    WidgetTester tester, {
    BedroomWallCreatorController? controller,
  }) {
    return tester.pumpWidget(
      MaterialApp(home: BedroomWallCreatorPage(controller: controller)),
    );
  }

  BedroomWallCreatorController controllerWith(PickedImage? picked) {
    return BedroomWallCreatorController(
      imagePicker: _FakeImageFilePicker(picked),
      wallImageUploader: MockWallImageUploader(),
      stickerCatalog: getIt<StickerCatalog>(),
    );
  }

  test('updateTransform persists rotation', () {
    final controller = controllerWith(null);
    controller.addTextBox();
    final item = controller.textItems.single;

    controller.updateTransform(item.id, item.transform.copyWith(rotation: 0.5));

    expect(controller.textItems.single.transform.rotation, 0.5);
  });

  test('exportInto maps canvas items onto the profile builder', () {
    final controller = BedroomWallCreatorController(
      imagePicker: const _FakeImageFilePicker(null),
      wallImageUploader: MockWallImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
    );
    controller.addTextBox();
    controller.updateText(controller.textItems.single.id, 'Hello wall');
    controller.addSticker('pangolin');

    final builder = ProfileBuilder()
      ..setUserId(1)
      ..setName('Alice')
      ..setLocation('London');
    controller.exportInto(builder);
    final profile = builder.build();

    expect(profile.textboxes, hasLength(1));
    expect(profile.textboxes.single.body, 'Hello wall');
    expect(profile.stickers, hasLength(1));
    expect(profile.stickers.single.name, 'pangolin');
  });

  test('addSticker adds known stickers and ignores unknown names', () {
    final controller = BedroomWallCreatorController(
      imagePicker: const _FakeImageFilePicker(null),
      wallImageUploader: MockWallImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
    );

    controller.addSticker('pangolin');
    controller.addSticker('does-not-exist');

    expect(controller.stickerItems, hasLength(1));
    expect(controller.stickerItems.single.stickerName, 'pangolin');
  });

  test('addImage uploads the image and stores the returned url', () async {
    final controller = BedroomWallCreatorController(
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
      wallImageUploader: MockWallImageUploader(),
      stickerCatalog: getIt<StickerCatalog>(),
    );

    await controller.addImage();

    final url = controller.imageItems.single.url;
    expect(url, isNotNull);

    final builder = ProfileBuilder()
      ..setUserId(1)
      ..setName('Alice')
      ..setLocation('London');
    controller.exportInto(builder);

    expect(builder.build().images.single.url, url);
  });

  testWidgets('shows the top bar with Back and Save', (tester) async {
    await pumpPage(tester, controller: controllerWith(null));

    expect(find.text('Create your wall'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Save'), findsOneWidget);
  });

  testWidgets('shows the three creation tools', (tester) async {
    await pumpPage(tester, controller: controllerWith(null));

    expect(find.text('Text box'), findsOneWidget);
    expect(find.text('Image'), findsOneWidget);
    expect(find.text('Sticker'), findsOneWidget);
  });

  testWidgets('cancelling the image picker adds nothing', (tester) async {
    await pumpPage(tester, controller: controllerWith(null));

    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Image, skipOffstage: false), findsNothing);
    expect(find.text('Create your wall'), findsOneWidget);
  });

  testWidgets('picking an image adds it to the canvas', (tester) async {
    await pumpPage(
      tester,
      controller: controllerWith(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_photo_alternate_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(Image, skipOffstage: false), findsOneWidget);
  });

  testWidgets('adding a text box shows placeholder text', (tester) async {
    await pumpPage(tester, controller: controllerWith(null));

    await tester.tap(find.byIcon(Icons.title));
    await tester.pumpAndSettle();

    expect(find.text('Your text', skipOffstage: false), findsOneWidget);
  });

  testWidgets('text typed into a text box is kept after editing', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = controllerWith(null);
    await pumpPage(tester, controller: controller);

    await tester.tap(find.byIcon(Icons.title));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Your text'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Hello wall');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(controller.textItems.single.text, 'Hello wall');
    expect(find.text('Hello wall', skipOffstage: false), findsOneWidget);
  });

  testWidgets('Save builds the profile and shows a confirmation banner', (
    tester,
  ) async {
    await pumpPage(tester, controller: controllerWith(null));

    await tester.tap(find.byTooltip('Save'));
    await tester.pump();

    expect(find.text('Profile saved'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
