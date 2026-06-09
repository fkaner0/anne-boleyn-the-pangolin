import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pangolin_app/config/env.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_edit/presentation/pages/edit_profile_page.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/domain/position.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/mock_wall_image_uploader.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

class _FakeProfileFetcher implements ProfileFetcher {
  final Profile profile;
  const _FakeProfileFetcher(this.profile);

  @override
  Future<Profile> fetchProfile(int userId) async => profile;
}

class _CapturingProfileUpdater implements ProfileUpdater {
  Profile? saved;

  @override
  Future<void> updateProfile(Profile profile) async => saved = profile;
}

class _FakeImageFilePicker implements ImageFilePicker {
  @override
  Future<PickedImage?> pickImage() async => null;
}

Profile _profile() => Profile(
  userId: 7,
  name: 'Anne',
  location: 'London',
  age: 29,
  bio: 'painter and falconer',
  hobby: 'Pottery',
  subInterests: const ['glazing'],
  images: const [],
  textboxes: const [
    ProfileText(
      title: '',
      body: 'hello wall',
      position: Position(x: 200, y: 100, rotation: 0),
    ),
  ],
);

void main() {
  setUp(() async {
    await getIt.reset();
    configureDependencies(BackendMode.mock);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required ProfileFetcher fetcher,
    required ProfileUpdater updater,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfilePage(
          userId: 7,
          profileFetcher: fetcher,
          profileUpdater: updater,
          imagePicker: _FakeImageFilePicker(),
          imageUploader: MockImageUploader(),
          stickerCatalog: StickerCatalog.fromAssetKeys(const <String>[]),
          fontCatalog: const FontCatalog(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('repopulates fields from the fetched profile', (tester) async {
    await pumpPage(
      tester,
      fetcher: _FakeProfileFetcher(_profile()),
      updater: _CapturingProfileUpdater(),
    );

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Your Wall'), findsOneWidget);
    expect(find.text('Passion Meter'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Anne'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'London'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'painter and falconer'),
      findsOneWidget,
    );
    expect(find.text('glazing'), findsOneWidget);
  });

  testWidgets('saving sends the edited profile and confirms', (tester) async {
    final updater = _CapturingProfileUpdater();
    await pumpPage(
      tester,
      fetcher: _FakeProfileFetcher(_profile()),
      updater: updater,
    );

    await tester.enterText(find.widgetWithText(TextField, 'Anne'), 'Annie');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(updater.saved, isNotNull);
    expect(updater.saved!.name, 'Annie');
    expect(updater.saved!.location, 'London');
    expect(updater.saved!.textboxes, hasLength(1));
    expect(updater.saved!.textboxes.first.body, 'hello wall');
    expect(find.text('Profile saved'), findsOneWidget);
  });

  testWidgets('tapping the wall cutout opens the wall editor', (tester) async {
    await pumpPage(
      tester,
      fetcher: _FakeProfileFetcher(_profile()),
      updater: _CapturingProfileUpdater(),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('Create your wall'), findsOneWidget);
  });

  testWidgets('the recommendations tab routes to the recommendations page', (
    tester,
  ) async {
    await pumpPage(
      tester,
      fetcher: _FakeProfileFetcher(_profile()),
      updater: _CapturingProfileUpdater(),
    );

    await tester.tap(find.byIcon(Icons.style_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Your recommendations'), findsOneWidget);
  });
}
