import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_image.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_sticker.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_text.dart';

class ProfileBuilder {
  int? _userId;
  String? _name;
  String? _location;
  final List<ProfileImage> _images = [];
  final List<ProfileText> _textboxes = [];
  final List<ProfileSticker> _stickers = [];

  ProfileBuilder();

  // Creates a builder from a Profile
  ProfileBuilder.from(Profile profile)
    : _userId = profile.userId,
      _name = profile.name,
      _location = profile.location {
    _images.addAll(profile.images);
    _textboxes.addAll(profile.textboxes);
    _stickers.addAll(profile.stickers);
  }

  // Creates an independent copy of this builder.
  ProfileBuilder copy() {
    final clone = ProfileBuilder()
      .._userId = _userId
      .._name = _name
      .._location = _location;
    clone._images.addAll(_images);
    clone._textboxes.addAll(_textboxes);
    clone._stickers.addAll(_stickers);
    return clone;
  }

  ProfileBuilder setUserId(int userId) {
    _userId = userId;
    return this;
  }

  ProfileBuilder setName(String name) {
    _name = name;
    return this;
  }

  ProfileBuilder setLocation(String location) {
    _location = location;
    return this;
  }

  // Append a single ProfileImage
  ProfileBuilder addImage(ProfileImage image) {
    _images.add(image);
    return this;
  }

  /// Appends all `images` to the profile.
  ProfileBuilder addImages(Iterable<ProfileImage> images) {
    _images.addAll(images);
    return this;
  }

  /// Appends a single ProfileText
  ProfileBuilder addTextBox(ProfileText textbox) {
    _textboxes.add(textbox);
    return this;
  }

  // Appends all `textboxes` ProfileText to the profile.
  ProfileBuilder addTextBoxes(Iterable<ProfileText> textboxes) {
    _textboxes.addAll(textboxes);
    return this;
  }

  /// Appends a single ProfileSticker
  ProfileBuilder addSticker(ProfileSticker sticker) {
    _stickers.add(sticker);
    return this;
  }

  // Appends all `stickers` ProfileSticker to the profile.
  ProfileBuilder addStickers(Iterable<ProfileSticker> stickers) {
    _stickers.addAll(stickers);
    return this;
  }

  // Requires userId, name, and location to be set before building the Profile.
  Profile build() {
    final userId = _userId;
    final name = _name;
    final location = _location;

    final missing = [
      if (userId == null) 'userId',
      if (name == null) 'name',
      if (location == null) 'location',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Cannot build Profile: missing required field(s): '
        '${missing.join(', ')}.',
      );
    }

    return Profile(
      userId: userId!,
      name: name!,
      location: location!,
      images: List.unmodifiable(_images),
      textboxes: List.unmodifiable(_textboxes),
      stickers: List.unmodifiable(_stickers),
    );
  }
}
