import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pangolin_app/config/service_locator.dart';
import 'package:pangolin_app/features/recommendation/domain/profile_builder.dart';
import 'package:pangolin_app/features/recommendation/presentation/widgets/info_box.dart';
import 'package:pangolin_app/features/wall_creation/data/gallery_image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/image_file_picker.dart';
import 'package:pangolin_app/features/wall_creation/data/wall_image_uploader.dart';
import 'package:pangolin_app/features/wall_creation/presentation/controllers/bedroom_wall_creator_controller.dart';
import 'package:pangolin_app/features/wall_creation/presentation/pages/bedroom_wall_creator_page.dart';
import 'package:pangolin_app/fonts/font_catalog.dart';
import 'package:pangolin_app/stickers/sticker_catalog.dart';

class AboutMePage extends StatefulWidget {
  final ProfileBuilder profileBuilder;
  final ImageFilePicker? imagePicker;
  final WallImageUploader? wallImageUploader;
  final BedroomWallCreatorController? wallController;

  const AboutMePage({
    super.key,
    required this.profileBuilder,
    this.imagePicker,
    this.wallImageUploader,
    this.wallController,
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

  Uint8List? _mainImageBytes;
  bool _uploadingImage = false;

  String _name = '';
  int? _age;
  String _location = '';
  String _bio = '';
  bool _imageUploaded = false;

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
      if (mounted) setState(() => _imageUploaded = true);
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
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {},
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
                  image: _mainImageBytes != null
                      ? MemoryImage(_mainImageBytes!)
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _FieldLabel('Name'),
              _TextField(
                hintText: 'Your name',
                onChanged: (value) {
                  _builder.setName(value);
                  setState(() => _name = value);
                },
              ),
              const SizedBox(height: 24),
              _FieldLabel('Age'),
              _TextField(
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
                bytes: _mainImageBytes,
                uploading: _uploadingImage,
                onTap: _uploadingImage ? null : _pickMainImage,
              ),
              const SizedBox(height: 24),
              _FieldLabel('Short Bio'),
              _TextField(
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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;
  final int? maxLength;

  const _TextField({
    required this.hintText,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
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
  final Uint8List? bytes;
  final bool uploading;
  final VoidCallback? onTap;

  const _MainImagePicker({
    required this.bytes,
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
            if (bytes != null)
              Image.memory(bytes!, fit: BoxFit.cover)
            else
              Icon(Icons.add, size: 48, color: colorScheme.outline),
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
