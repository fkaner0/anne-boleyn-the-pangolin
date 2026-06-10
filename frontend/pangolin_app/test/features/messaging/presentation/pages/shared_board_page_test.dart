import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/pages/shared_board_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';

import '../../../../support/auth_test_support.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeService implements SharedBoardService {
  final StreamController<void> controller = StreamController<void>.broadcast();
  List<SharedElement> board = [];
  final List<String> sentImages = [];
  final List<String> sentReplies = [];

  @override
  Stream<void> notifications(int userId) => controller.stream;

  @override
  Future<List<SharedElement>> fetchBoard(int userId, int friendUserId) async =>
      board;

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

class _FakeProfileFetcher implements ProfileFetcher {
  final String name;

  const _FakeProfileFetcher(this.name);

  @override
  Future<Profile> fetchProfile(int userId) async => Profile(
    userId: userId,
    name: name,
    location: '',
    images: [],
    textboxes: [],
  );
}

SharedElement textElement(int id, String text) => SharedElement(
  id: id,
  datetime: id,
  kind: SharedElementKind.text,
  content: text,
);

void main() {
  Future<_FakeService> pumpBoard(
    WidgetTester tester, {
    List<SharedElement> board = const [],
  }) async {
    final service = _FakeService()..board = board;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(1)],
        child: MaterialApp(
          home: SharedBoardPage(
            friendUserId: 2,
            profileFetcher: const _FakeProfileFetcher('Sally'),
            service: service,
            imagePicker: _FakePicker(),
            imageUploader: MockImageUploader(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return service;
  }

  Future<void> notify(WidgetTester tester, _FakeService service) async {
    await tester.runAsync(() async {
      service.controller.add(null);
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
  }

  testWidgets('renders the fetched board', (tester) async {
    await pumpBoard(tester, board: [textElement(1, 'look at this')]);

    expect(find.text('look at this'), findsOneWidget);
  });

  testWidgets('shows the empty state when the board is empty', (tester) async {
    await pumpBoard(tester);

    expect(find.text('Nothing shared yet'), findsOneWidget);
  });

  testWidgets('a notification refetches and shows new elements', (
    tester,
  ) async {
    final service = await pumpBoard(tester);
    expect(find.text('look at this'), findsNothing);

    service.board = [textElement(1, 'look at this')];
    await notify(tester, service);

    expect(find.text('look at this'), findsOneWidget);
  });

  testWidgets('tapping an element opens the chat popup', (tester) async {
    await pumpBoard(tester, board: [textElement(1, 'look at this')]);

    await tester.tap(find.text('look at this'));
    await tester.pumpAndSettle();

    expect(find.text('No messages yet'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Write a message'), findsOneWidget);
  });

  testWidgets('sending a reply from the popup calls the service', (
    tester,
  ) async {
    final service = await pumpBoard(
      tester,
      board: [textElement(1, 'look at this')],
    );

    await tester.tap(find.text('look at this'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Write a message'),
      'hey there',
    );
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();

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
