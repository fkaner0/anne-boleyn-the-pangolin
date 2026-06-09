import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/info_box.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/picker/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/uploader/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';
import 'package:pangolin_app/widgets/app_icon.dart';

class AboutMePage extends StatefulWidget {
  final ProfileBuilder profileBuilder;
  final ImageFilePicker? imagePicker;
  final WallImageUploader? wallImageUploader;
  final BedroomWallCreatorController? wallController;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const AboutMePage({
    super.key,
    required this.profileBuilder,
    this.imagePicker,
    this.wallImageUploader,
    this.wallController,
    this.onNext,
    this.onBack,
  });

  @override
  State<AboutMePage> createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  late final ImageFilePicker _imagePicker =
      widget.imagePicker ?? GalleryImageFilePicker();
  late final WallImageUploader _wallImageUploader =
      widget.wallImageUploader ?? getIt<WallImageUploader>();

  late final BedroomWallCreatorController _wallController =
      widget.wallController ??
      BedroomWallCreatorController(
        imagePicker: _imagePicker,
        wallImageUploader: _wallImageUploader,
        stickerCatalog: getIt<StickerCatalog>(),
        fontCatalog: getIt<FontCatalog>(),
      );

  ProfileBuilder get _builder => widget.profileBuilder;

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;

  Uint8List? _mainImageBytes;
  bool _uploadingImage = false;

  late String _name;
  late int? _age;
  late String _location;
  late String _bio;
  late bool _imageUploaded;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _name = _builder.name ?? '';
    _age = _builder.age;
    _location = _builder.location ?? '';
    _bio = _builder.bio ?? '';

    final url = _builder.profileImageUrl;
    _profileImageUrl = (url != null && url.isNotEmpty) ? url : null;
    _imageUploaded = _profileImageUrl != null;

    _nameController = TextEditingController(text: _name);
    _ageController = TextEditingController(text: _age?.toString() ?? '');
    _locationController = TextEditingController(text: _location);
    _bioController = TextEditingController(text: _bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  ImageProvider? get _mainImageProvider {
    if (_mainImageBytes != null) return MemoryImage(_mainImageBytes!);
    final url = _profileImageUrl;
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return null;
  }

  bool get _canSubmit =>
      _name.isNotEmpty &&
      _age != null &&
      _location.isNotEmpty &&
      _bio.isNotEmpty &&
      _imageUploaded;

  Future<void> _pickMainImage() async {
    final picked = await _imagePicker.pickImage();
    if (picked == null || !mounted) return;

    setState(() {
      _mainImageBytes = picked.bytes;
      _uploadingImage = true;
    });

    try {
      final url = await _wallImageUploader.uploadImage(picked.bytes);
      _builder.setProfileImageUrl(url);
      if (mounted) {
        setState(() {
          _profileImageUrl = url;
          _imageUploaded = true;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Could not upload that image.')),
          );
      }
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _next() {
    final onNext = widget.onNext;
    if (onNext != null) {
      onNext();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BedroomWallCreatorPage(
          profileBuilder: _builder,
          controller: _wallController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('About me'),
        leading: IconButton(
          icon: const AppIcon(AppIconType.back),
          tooltip: 'Back',
          onPressed: widget.onBack ?? () {},
        ),
        actions: [
          TextButton(
            onPressed: _canSubmit ? _next : null,
            child: const Text('Next'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FieldLabel('Preview'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InfoBox(
                  name: _name,
                  age: _age,
                  location: _location,
                  bio: _bio,
                  image: _mainImageProvider,
                ),
              ),
              const SizedBox(height: 24),
              _FieldLabel('Name'),
              _TextField(
                controller: _nameController,
                hintText: 'Your name',
                onChanged: (value) {
                  _builder.setName(value);
                  setState(() => _name = value);
                },
              ),
              const SizedBox(height: 24),
              _FieldLabel('Age'),
              _TextField(
                controller: _ageController,
                hintText: 'Your age',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final age = int.tryParse(value);
                  if (age != null) _builder.setAge(age);
                  setState(() => _age = age);
                },
              ),
              const SizedBox(height: 24),
              _FieldLabel('Rough location'),
              _TextField(
                controller: _locationController,
                hintText: 'Where you are based',
                onChanged: (value) {
                  _builder.setLocation(value);
                  setState(() => _location = value);
                },
              ),
              const SizedBox(height: 24),
              _FieldLabel('Main image'),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Put something related to your art!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _MainImagePicker(
                image: _mainImageProvider,
                uploading: _uploadingImage,
                onTap: _uploadingImage ? null : _pickMainImage,
              ),
              const SizedBox(height: 24),
              _FieldLabel('Short Bio'),
              _TextField(
                controller: _bioController,
                hintText: 'Summarise your vibe!',
                minLines: 3,
                maxLines: 5,
                maxLength: 100,
                onChanged: (value) {
                  _builder.setBio(value);
                  setState(() => _bio = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const _TextField({
    required this.hintText,
    required this.onChanged,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _MainImagePicker extends StatelessWidget {
  final ImageProvider? image;
  final bool uploading;
  final VoidCallback? onTap;

  const _MainImagePicker({
    required this.image,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              Image(image: image!, fit: BoxFit.cover)
            else
              AppIcon(AppIconType.add, size: 48, color: colorScheme.outline),
            if (uploading)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
