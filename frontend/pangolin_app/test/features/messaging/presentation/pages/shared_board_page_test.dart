import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/pages/shared_board_page.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';

import '../../../../support/auth_test_support.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeService implements SharedBoardService {
  final StreamController<SharedElement> controller =
      StreamController<SharedElement>.broadcast();
  final List<String> sentImages = [];
  final List<String> sentReplies = [];

  @override
  Stream<SharedElement> listen(int userId) => controller.stream;

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required int datetime,
  }) async => sentImages.add(url);

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) async {}

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    required int datetime,
  }) async => sentReplies.add(text);
}

class _FakePicker implements ImageFilePicker {
  @override
  Future<PickedImage?> pickImage() async =>
      PickedImage(bytes: _onePixelPng, aspectRatio: 1);
}

void main() {
  Future<_FakeService> pumpBoard(WidgetTester tester) async {
    final service = _FakeService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(1)],
        child: MaterialApp(
          home: SharedBoardPage(
            friendUserId: 2,
            friendName: 'Sally',
            service: service,
            imagePicker: _FakePicker(),
            imageUploader: MockImageUploader(),
          ),
        ),
      ),
    );
    await tester.pump();
    return service;
  }

  SharedElement textElement(int id, String text) => SharedElement(
    id: id,
    senderId: 2,
    receiverId: 1,
    datetime: id,
    kind: SharedElementKind.text,
    content: text,
  );

  Future<void> emit(
    WidgetTester tester,
    _FakeService service,
    SharedElement element,
  ) async {
    await tester.runAsync(() async {
      service.controller.add(element);
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();
  }

  testWidgets('renders shared elements received on the stream', (tester) async {
    final service = await pumpBoard(tester);

    await emit(tester, service, textElement(1, 'look at this'));

    expect(find.text('look at this'), findsOneWidget);
  });

  testWidgets('ignores elements not involving the friend', (tester) async {
    final service = await pumpBoard(tester);

    await emit(
      tester,
      service,
      const SharedElement(
        id: 9,
        senderId: 5,
        receiverId: 6,
        datetime: 9,
        kind: SharedElementKind.text,
        content: 'not yours',
      ),
    );

    expect(find.text('not yours'), findsNothing);
    expect(find.text('Nothing shared yet'), findsOneWidget);
  });

  testWidgets('tapping an element opens the chat popup', (tester) async {
    final service = await pumpBoard(tester);
    await emit(tester, service, textElement(1, 'look at this'));

    await tester.tap(find.text('look at this'));
    await tester.pumpAndSettle();

    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Write a message'), findsOneWidget);
  });

  testWidgets('sending a reply from the popup calls the service', (
    tester,
  ) async {
    final service = await pumpBoard(tester);
    await emit(tester, service, textElement(1, 'look at this'));

    await tester.tap(find.text('look at this'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'hey there',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pump();

    expect(service.sentReplies, contains('hey there'));
  });

  testWidgets('upload image picks, uploads and sends', (tester) async {
    final service = await pumpBoard(tester);

    await tester.tap(find.text('Upload image'));
    await tester.pumpAndSettle();

    expect(service.sentImages, hasLength(1));
  });

  testWidgets('grab from their wall is a stub', (tester) async {
    await pumpBoard(tester);

    await tester.tap(find.text('Grab from their wall'));
    await tester.pump();

    expect(find.textContaining('coming soon'), findsOneWidget);
  });
}
