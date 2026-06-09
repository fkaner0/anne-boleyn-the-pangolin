import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/profile_setup/widgets/add_chip_button.dart';
import 'package:pangolin_app/features/profile_setup/widgets/field_label.dart';
import 'package:pangolin_app/features/profile_setup/widgets/main_image_picker.dart';
import 'package:pangolin_app/features/profile_setup/widgets/passion_meter.dart';
import 'package:pangolin_app/features/profile_setup/widgets/profile_text_field.dart';
import 'package:pangolin_app/features/profile_setup/widgets/section_title.dart';
import 'package:pangolin_app/features/recommendation/data/profile_fetcher.dart';
import 'package:pangolin_app/features/recommendation/data/profile_updater.dart';
import 'package:pangolin_app/features/recommendation/domain/profile.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/bedroom_wall_view.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/info_box.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/router/main_tab_navigation.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import 'package:pangolin_app/widgets/app_icon.dart';
import 'package:pangolin_app/widgets/island_nav_bar.dart';

const _hobbies = ['Painting', 'Pottery', 'Photography', 'Knitting'];

class EditProfilePage extends StatefulWidget {
  final int userId;
  final ProfileFetcher? profileFetcher;
  final ProfileUpdater? profileUpdater;
  final ImageFilePicker? imagePicker;
  final ImageUploader? imageUploader;
  final StickerCatalog? stickerCatalog;
  final FontCatalog? fontCatalog;

  const EditProfilePage({
    super.key,
    required this.userId,
    this.profileFetcher,
    this.profileUpdater,
    this.imagePicker,
    this.imageUploader,
    this.stickerCatalog,
    this.fontCatalog,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileFetcher _profileFetcher =
      widget.profileFetcher ?? getIt<ProfileFetcher>();
  late final ProfileUpdater _profileUpdater =
      widget.profileUpdater ?? getIt<ProfileUpdater>();
  late final ImageFilePicker _imagePicker =
      widget.imagePicker ?? GalleryImageFilePicker();
  late final ImageUploader _imageUploader =
      widget.imageUploader ?? getIt<ImageUploader>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  bool _loading = true;
  String? _loadError;
  bool _saving = false;
  bool _uploadingImage = false;

  late ProfileBuilder _builder;
  late BedroomWallCreatorController _wallController;
  late StickerCatalog _stickerCatalog;
  late FontCatalog _fontCatalog;

  Uint8List? _mainImageBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await _profileFetcher.fetchProfile(widget.userId);

      final stickerCatalog = widget.stickerCatalog ?? getIt<StickerCatalog>();
      final fontCatalog = widget.fontCatalog ?? getIt<FontCatalog>();

      _builder = ProfileBuilder.from(profile).clearWall();
      _stickerCatalog = stickerCatalog;
      _fontCatalog = fontCatalog;
      _wallController = BedroomWallCreatorController(
        imagePicker: _imagePicker,
        imageUploader: _imageUploader,
        stickerCatalog: stickerCatalog,
        fontCatalog: fontCatalog,
      )..loadFrom(profile);

      _nameController.text = profile.name;
      _ageController.text = profile.age == Profile.defaultAge
          ? ''
          : profile.age.toString();
      _locationController.text = profile.location;
      _bioController.text = profile.bio == Profile.defaultBio
          ? ''
          : profile.bio;

      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = '$error';
        _loading = false;
      });
    }
  }

  ImageProvider? get _mainImageProvider {
    final bytes = _mainImageBytes;
    if (bytes != null) return MemoryImage(bytes);
    final url = _builder.profileImageUrl;
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return null;
  }

  Profile _currentProfile() {
    final builder = _builder.copy();
    _wallController.exportInto(builder);
    return builder.build();
  }

  Future<void> _pickMainImage() async {
    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    setState(() {
      _mainImageBytes = picked.bytes;
      _uploadingImage = true;
    });

    try {
      final url = await _imageUploader.uploadImage(picked.bytes);
      _builder.setProfileImageUrl(url);
    } catch (_) {
      if (mounted) _showMessage('Could not upload that image.');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  Future<void> _openWallEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BedroomWallCreatorPage(
          controller: _wallController,
          profileBuilder: _builder,
          profileUpdater: _profileUpdater,
          onSaved: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addInterest(void Function(String) onAdd) async {
    final text = await _promptForInterest();
    if (text == null || text.isEmpty) return;
    setState(() => onAdd(text));
  }

  Future<String?> _promptForInterest() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add interest'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter interest'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final Profile profile;
    try {
      profile = _currentProfile();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Please fill in your name and location.');
      return;
    }

    try {
      await _profileUpdater.updateProfile(profile);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Could not save your profile. Please try again.');
      return;
    }

    if (!mounted) return;
    setState(() => _saving = false);
    _showMessage('Profile saved');
    MainTabNavigation.goToRecommendations(context, widget.userId);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const AppIcon(AppIconType.check),
            tooltip: 'Save',
            onPressed: _loading || _saving ? null : _save,
          ),
        ],
        bottom: _saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(minHeight: 4),
              )
            : null,
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: IslandNavBar(
        current: IslandNavTab.editProfile,
        onEditProfile: () {},
        onRecommendations: () =>
            MainTabNavigation.goToRecommendations(context, widget.userId),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(child: Text('Error: $_loadError'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileCardPreview(
            name: _builder.name ?? '',
            age: _builder.age,
            location: _builder.location ?? '',
            bio: _builder.bio ?? '',
            image: _mainImageProvider,
          ),
          _divider,
          const SectionTitle('Your Wall'),
          const SizedBox(height: 12),
          _WallCutoutPreview(
            profile: _currentProfile(),
            stickerCatalog: _stickerCatalog,
            fontCatalog: _fontCatalog,
            onEdit: _openWallEditor,
          ),
          _divider,
          const SectionTitle('Hobby'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _hobbies.contains(_builder.hobby)
                ? _builder.hobby
                : null,
            hint: const Text('Select a hobby'),
            onChanged: (value) {
              if (value != null) setState(() => _builder.setHobby(value));
            },
            items: _hobbies
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
          ),
          _divider,
          const SectionTitle('Passion Meter'),
          const SizedBox(height: 8),
          PassionMeter(
            value: _builder.passionLevel ?? 0.5,
            onChanged: (value) =>
                setState(() => _builder.setPassionLevel(value)),
          ),
          _divider,
          const SectionTitle('Other Interests'),
          const SizedBox(height: 16),
          _InterestGroup(
            label: 'Sub-interests',
            interests: _builder.subInterests,
            onAdd: () => _addInterest(_builder.addSubInterest),
            onRemove: (interest) =>
                setState(() => _builder.removeSubInterest(interest)),
          ),
          const SizedBox(height: 20),
          _InterestGroup(
            label: 'Other interests',
            interests: _builder.otherInterests,
            onAdd: () => _addInterest(_builder.addOtherInterest),
            onRemove: (interest) =>
                setState(() => _builder.removeOtherInterest(interest)),
          ),
          _divider,
          const FieldLabel('Name'),
          ProfileTextField(
            controller: _nameController,
            hintText: 'Your name',
            onChanged: (value) => setState(() => _builder.setName(value)),
          ),
          const SizedBox(height: 24),
          const FieldLabel('Age'),
          ProfileTextField(
            controller: _ageController,
            hintText: 'Your age',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              final age = int.tryParse(value);
              if (age != null) setState(() => _builder.setAge(age));
            },
          ),
          const SizedBox(height: 24),
          const FieldLabel('Rough location'),
          ProfileTextField(
            controller: _locationController,
            hintText: 'Where you are based',
            onChanged: (value) => setState(() => _builder.setLocation(value)),
          ),
          const SizedBox(height: 24),
          const FieldLabel('Main image'),
          const SizedBox(height: 8),
          MainImagePicker(
            image: _mainImageProvider,
            uploading: _uploadingImage,
            onTap: _uploadingImage ? null : _pickMainImage,
          ),
          const SizedBox(height: 24),
          const FieldLabel('Short Bio'),
          ProfileTextField(
            controller: _bioController,
            hintText: 'Summarise your vibe!',
            minLines: 3,
            maxLines: 5,
            maxLength: 100,
            onChanged: (value) => setState(() => _builder.setBio(value)),
          ),
        ],
      ),
    );
  }
}

const _divider = SizedBox(height: 36);

class _ProfileCardPreview extends StatelessWidget {
  final String name;
  final int? age;
  final String location;
  final String bio;
  final ImageProvider? image;

  const _ProfileCardPreview({
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InfoBox(
        name: name,
        age: age == null || age == Profile.defaultAge ? null : age,
        location: location,
        bio: bio,
        image: image,
      ),
    );
  }
}

class _WallCutoutPreview extends StatelessWidget {
  static const double _height = 240;

  final Profile profile;
  final StickerCatalog stickerCatalog;
  final FontCatalog fontCatalog;
  final VoidCallback onEdit;

  const _WallCutoutPreview({
    required this.profile,
    required this.stickerCatalog,
    required this.fontCatalog,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onEdit,
      child: SizedBox(
        height: _height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: ClipPath(
                clipper: _SplodgeClipper(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: context.paletteColors.surfaceMuted,
                      child: IgnorePointer(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxHeight: double.infinity,
                          child: BedroomWallView(
                            profile: profile,
                            stickerCatalog: stickerCatalog,
                            fontCatalog: fontCatalog,
                            onImageTap: (_) {},
                            onTextTap: (_) {},
                            enableWiggle: false,
                          ),
                        ),
                      ),
                    ),
                    ColoredBox(color: Colors.grey.withValues(alpha: 0.55)),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary,
              ),
              child: AppIcon(
                AppIconType.edit,
                size: 24,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplodgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    return Path()
      ..moveTo(w * 0.10, h * 0.32)
      ..cubicTo(w * 0.04, h * 0.12, w * 0.30, h * 0.02, w * 0.50, h * 0.07)
      ..cubicTo(w * 0.70, h * 0.12, w * 0.80, h * -0.02, w * 0.91, h * 0.13)
      ..cubicTo(w * 1.03, h * 0.26, w * 0.92, h * 0.42, w * 0.96, h * 0.57)
      ..cubicTo(w * 1.00, h * 0.74, w * 0.96, h * 0.94, w * 0.78, h * 0.94)
      ..cubicTo(w * 0.60, h * 0.95, w * 0.55, h * 1.03, w * 0.37, h * 0.96)
      ..cubicTo(w * 0.19, h * 0.90, w * 0.03, h * 0.96, w * 0.06, h * 0.74)
      ..cubicTo(w * 0.08, h * 0.55, w * 0.15, h * 0.50, w * 0.10, h * 0.32)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _InterestGroup extends StatelessWidget {
  final String label;
  final List<String> interests;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _InterestGroup({
    required this.label,
    required this.interests,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final interest in interests)
              InputChip(
                label: Text(interest),
                onDeleted: () => onRemove(interest),
              ),
            AddChipButton(onPressed: onAdd),
          ],
        ),
      ],
    );
  }
}
