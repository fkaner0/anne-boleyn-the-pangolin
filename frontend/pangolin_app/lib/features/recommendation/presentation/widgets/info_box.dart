import 'package:flutter/material.dart';
import 'package:pangolin_app/theme/palette_colors.dart';
import '../../domain/recommendation.dart';

class InfoBox extends StatelessWidget {
  final String name;
  final int? age;
  final String location;
  final String bio;
  final ImageProvider? image;

  const InfoBox({
    super.key,
    required this.name,
    required this.location,
    required this.bio,
    this.age,
    this.image,
  });

  factory InfoBox.fromRecommendation(Recommendation recommendation) {
    final url = recommendation.imageUrl;
    return InfoBox(
      name: recommendation.name,
      location: recommendation.location,
      bio: recommendation.bio,
      image: url.isEmpty ? null : NetworkImage(url),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      color: Theme.of(context).colorScheme.outline,
      alignment: Alignment.center,
      child: const Icon(Icons.person),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = image;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageProvider == null
                ? _imagePlaceholder(context)
                : Image(
                    image: imageProvider,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _imagePlaceholder(context),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.paletteColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    age == null ? name : '$name ($age)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    location,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(bio, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
