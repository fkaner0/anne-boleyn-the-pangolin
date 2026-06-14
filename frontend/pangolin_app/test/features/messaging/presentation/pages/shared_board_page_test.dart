import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pangolin_app/features/friends/data/mock_friend_action_sender.dart';
import 'package:pangolin_app/features/logging/button_ids.dart';
import 'package:pangolin_app/features/logging/data/mock_button_click_logger.dart';
import 'package:pangolin_app/features/messaging/data/shared_board_service.dart';
import 'package:pangolin_app/features/messaging/domain/shared_element.dart';
import 'package:pangolin_app/features/messaging/presentation/pages/shared_board_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';
import 'package:pangolin_app/router/app_router.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

import '../../../../support/auth_test_support.dart';

final Uint8List _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

class _FakeService implements SharedBoardService {
  final StreamController<void> controller = StreamController<void>.broadcast();
  List<SharedElement> board = [];
  int failuresBeforeSuccess = 0;
  int fetchAttempts = 0;
  final List<String> sentImages = [];
  final List<String> sentReplies = [];
  final List<String> sentTexts = [];

  @override
  Stream<void> notifications(int userId) => controller.stream;

  @override
  Future<List<SharedElement>> fetchBoard(int userId, int friendUserId) async {
    fetchAttempts++;
    if (fetchAttempts <= failuresBeforeSuccess) {
      throw Exception('board not ready');
    }
    return board;
  }

  @override
  Future<void> sendImage({
    required int senderId,
    required int receiverId,
    required String url,
    required String message,
    int? datetime,
  }) async => sentImages.add(url);

  @override
  Future<void> sendText({
    required int senderId,
    required int receiverId,
    required String text,
    required String message,
    int? datetime,
  }) async => sentTexts.add(text);

  @override
  Future<void> sendReply({
    required int sharedElementId,
    required int senderId,
    required int receiverId,
    required String text,
    int? datetime,
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
    MockButtonClickLogger? logger,
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
            logger: logger ?? MockButtonClickLogger(),
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

  testWidgets('keeps the spinner and retries until the initial load succeeds', (
    tester,
  ) async {
    final service = _FakeService()
      ..board = [textElement(1, 'look at this')]
      ..failuresBeforeSuccess = 1;

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
            logger: MockButtonClickLogger(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('look at this'), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(service.fetchAttempts, 2);
    expect(find.byType(CircularProgressIndicator), findsNothing);
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

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AppIcon && w.type == AppIconType.addImage,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(service.sentImages, hasLength(1));
  });

  Future<MockFriendActionSender> pumpBoardWithRouter(
    WidgetTester tester, {
    MockButtonClickLogger? logger,
  }) async {
    final sender = MockFriendActionSender();
    final router = GoRouter(
      initialLocation: AppRoutes.sharedBoard,
      routes: [
        GoRoute(
          path: AppRoutes.sharedBoard,
          builder: (_, _) => SharedBoardPage(
            friendUserId: 2,
            profileFetcher: const _FakeProfileFetcher('Sally'),
            service: _FakeService(),
            imagePicker: _FakePicker(),
            imageUploader: MockImageUploader(),
            friendActionSender: sender,
            logger: logger ?? MockButtonClickLogger(),
          ),
        ),
        GoRoute(
          path: AppRoutes.connections,
          builder: (_, _) => const Text('CONNECTIONS'),
        ),
        GoRoute(
          path: AppRoutes.viewProfile,
          builder: (_, _) => const Text('PROFILE'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loggedInUserId(1)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return sender;
  }

  testWidgets(
    'remove connection confirms, sends remove, logs, and leaves the board',
    (tester) async {
      final logger = MockButtonClickLogger();
      final sender = await pumpBoardWithRouter(tester, logger: logger);

      await tester.tap(find.byTooltip('Remove connection'));
      await tester.pumpAndSettle();

      expect(find.text('Manage connection'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(sender.actions, hasLength(1));
      expect(sender.actions.single.kind, FriendActionKind.remove);
      expect(sender.actions.single.currentUserId, 1);
      expect(sender.actions.single.targetUserId, 2);
      expect(find.text('CONNECTIONS'), findsOneWidget);
      expect(
        logger.clicks.map((c) => c.buttonId),
        contains(ButtonIds.sharedBoardRemoveConnection),
      );
    },
  );

  testWidgets(
    'report and block reports, shows the message, and leaves the board',
    (tester) async {
      final sender = await pumpBoardWithRouter(tester);

      await tester.tap(find.byTooltip('Remove connection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report and Block'));
      await tester.pumpAndSettle();

      expect(sender.actions.single.kind, FriendActionKind.report);
      expect(sender.actions.single.targetUserId, 2);
      expect(find.textContaining('moderation team'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('CONNECTIONS'), findsOneWidget);
    },
  );

  testWidgets('remove connection does nothing when declined', (tester) async {
    final sender = await pumpBoardWithRouter(tester);

    await tester.tap(find.byTooltip('Remove connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(sender.actions, isEmpty);
    expect(find.text('CONNECTIONS'), findsNothing);
  });

  testWidgets('adding a text post sends the topic and message', (tester) async {
    final logger = MockButtonClickLogger();
    final service = await pumpBoard(tester, logger: logger);

    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is AppIcon && w.type == AppIconType.addText,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Topic'), 'Big news');
    await tester.enterText(
      find.widgetWithText(TextField, 'Message'),
      'you have to see this',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Send'));
    await tester.pumpAndSettle();

    expect(service.sentTexts, contains('Big news'));
    expect(
      logger.clicks.map((c) => c.buttonId),
      contains(ButtonIds.sharedBoardAddText),
    );
  });
}
