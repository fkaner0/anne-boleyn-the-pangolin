import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/widgets/creator_tool_bar.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeImageFilePicker implements ImageFilePicker {
  final PickedImage? result;

  const _FakeImageFilePicker(this.result);

  @override
  Future<PickedImage?> pickImage() async => result;
}

class _FakeProfileUpdater implements ProfileUpdater {
  final bool fail;
  final Completer<void>? gate;
  Profile? received;

  _FakeProfileUpdater({this.fail = false, this.gate});

  @override
  Future<void> updateProfile(Profile profile) async {
    received = profile;
    if (gate != null) await gate!.future;
    if (fail) throw Exception('save failed');
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    BedroomWallCreatorController? controller,
    ProfileUpdater? profileUpdater,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: BedroomWallCreatorPage(
          controller: controller,
          profileUpdater: profileUpdater,
        ),
      ),
    );
  }

  BedroomWallCreatorController controllerWith(PickedImage? picked) {
    return BedroomWallCreatorController(
      imagePicker: _FakeImageFilePicker(picked),
      imageUploader: MockImageUploader(),
      stickerCatalog: getIt<StickerCatalog>(),
      fontCatalog: getIt<FontCatalog>(),
    );
  }

  test('updateTransform persists rotation', () {
    final controller = controllerWith(null);
    controller.addTextBox();
    final item = controller.textItems.single;

    controller.updateTransform(item.id, item.transform.copyWith(rotation: 0.5));

    expect(controller.textItems.single.transform.rotation, 0.5);
  });

  test('updateTransform clamps the center within the canvas bounds', () {
    final controller = controllerWith(null);
    controller.addTextBox();
    final item = controller.textItems.single;

    controller.updateTransform(
      item.id,
      item.transform.copyWith(center: const Offset(9999, -500)),
    );

    final center = controller.textItems.single.transform.center;
    expect(center.dx, controller.canvas.width);
    expect(center.dy, 0.0);
  });

  test('updateTransform leaves an in-bounds center unchanged', () {
    final controller = controllerWith(null);
    controller.addTextBox();
    final item = controller.textItems.single;

    controller.updateTransform(
      item.id,
      item.transform.copyWith(center: const Offset(120, 240)),
    );

    expect(
      controller.textItems.single.transform.center,
      const Offset(120, 240),
    );
  });

  test('exportInto maps canvas items onto the profile builder', () {
    final controller = BedroomWallCreatorController(
      imagePicker: const _FakeImageFilePicker(null),
      imageUploader: MockImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
      fontCatalog: const FontCatalog(),
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
      imageUploader: MockImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
      fontCatalog: const FontCatalog(),
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
      imageUploader: MockImageUploader(),
      stickerCatalog: getIt<StickerCatalog>(),
      fontCatalog: const FontCatalog(),
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

  test('addSticker places the sticker at the given center', () {
    final controller = BedroomWallCreatorController(
      imagePicker: const _FakeImageFilePicker(null),
      imageUploader: MockImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
      fontCatalog: const FontCatalog(),
    );

    controller.addSticker('pangolin', center: const Offset(120, 240));

    expect(
      controller.stickerItems.single.transform.center,
      const Offset(120, 240),
    );
  });

  test('addImage places the image at the given center', () async {
    final controller = BedroomWallCreatorController(
      imagePicker: _FakeImageFilePicker(
        PickedImage(bytes: _onePixelPng, aspectRatio: 1),
      ),
      imageUploader: MockImageUploader(),
      stickerCatalog: getIt<StickerCatalog>(),
      fontCatalog: const FontCatalog(),
    );

    await controller.addImage(center: const Offset(80, 160));

    expect(
      controller.imageItems.single.transform.center,
      const Offset(80, 160),
    );
  });

  test('adding without a center defaults to the canvas center', () {
    final controller = BedroomWallCreatorController(
      imagePicker: const _FakeImageFilePicker(null),
      imageUploader: MockImageUploader(),
      stickerCatalog: StickerCatalog.fromAssetKeys(const [
        'assets/stickers/pangolin.png',
      ]),
      fontCatalog: const FontCatalog(),
    );

    controller.addSticker('pangolin');

    final canvas = controller.canvas;
    expect(
      controller.stickerItems.single.transform.center,
      Offset(canvas.width / 2, canvas.height / 2),
    );
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

  testWidgets('opening a text box for editing does not crash', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = controllerWith(null);
    controller.addTextBox();
    await pumpPage(tester, controller: controller);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Your text'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  // TODO: find TextField in canvas, not prompt generation one.
  // testWidgets('text typed into a text box is kept after editing', (
  //   tester,
  // ) async {
  //   await tester.binding.setSurfaceSize(const Size(400, 900));
  //   addTearDown(() => tester.binding.setSurfaceSize(null));

  //   final controller = controllerWith(null);
  //   await pumpPage(tester, controller: controller);

  //   await tester.tap(find.byIcon(Icons.title));
  //   await tester.pumpAndSettle();

  //   await tester.tap(find.text('Your text'));
  //   await tester.pumpAndSettle();

  //   await tester.enterText(find.byType(TextField), 'Hello wall');
  //   await tester.pumpAndSettle();

  //   await tester.tap(find.byIcon(Icons.check));
  //   await tester.pumpAndSettle();

  //   expect(controller.textItems.single.text, 'Hello wall');
  //   expect(find.text('Hello wall', skipOffstage: false), findsOneWidget);
  // });

  testWidgets('Save sends the profile and moves to the next page', (
    tester,
  ) async {
    final updater = _FakeProfileUpdater();
    await pumpPage(
      tester,
      controller: controllerWith(null),
      profileUpdater: updater,
    );

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(updater.received, isNotNull);
    expect(find.text('Profile saved'), findsOneWidget);
    expect(find.text('Your recommendations'), findsOneWidget);
  });

  testWidgets('Save shows a loading bar while the request is in flight', (
    tester,
  ) async {
    final gate = Completer<void>();
    await pumpPage(
      tester,
      controller: controllerWith(null),
      profileUpdater: _FakeProfileUpdater(gate: gate),
    );

    await tester.tap(find.byTooltip('Save'));
    await tester.pump();

    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    gate.complete();
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('Save shows an error and stays on the page when it fails', (
    tester,
  ) async {
    await pumpPage(
      tester,
      controller: controllerWith(null),
      profileUpdater: _FakeProfileUpdater(fail: true),
    );

    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Could not save'), findsOneWidget);
    expect(find.text('Create your wall'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('toolbar fades out while an item is being moved and back after', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = controllerWith(null);
    controller.addTextBox();
    await pumpPage(tester, controller: controller);
    await tester.pumpAndSettle();

    double toolbarOpacity() => tester
        .widget<AnimatedOpacity>(
          find.ancestor(
            of: find.byType(CreatorToolBar),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .opacity;

    expect(toolbarOpacity(), 1.0);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Your text')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();

    expect(toolbarOpacity(), 0.0);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(toolbarOpacity(), 1.0);
  });

  testWidgets('dragging an item to the top bar deletes it', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = controllerWith(null);
    controller.addTextBox();
    await pumpPage(tester, controller: controller);
    await tester.pumpAndSettle();

    expect(controller.items, hasLength(1));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Your text')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -500));
    await tester.pump();

    expect(find.byIcon(Icons.delete), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.items, isEmpty);
  });

  testWidgets('the bin zone follows the app bar when offset from the top', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final controller = controllerWith(null);
    controller.addTextBox();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const SizedBox(height: 120),
              Expanded(child: BedroomWallCreatorPage(controller: controller)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.items, hasLength(1));

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Your text')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    await gesture.moveTo(const Offset(200, 140));
    await tester.pump();

    expect(find.byIcon(Icons.delete), findsOneWidget);

    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.items, isEmpty);
  });
}
