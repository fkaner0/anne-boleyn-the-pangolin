import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum AppIconType {
  back,
  add,
  save,
  send,
  check,
  close,
  preview,
  brokenImage,
  refresh,
  addText,
  addImage,
  textColour,
  textBackground,
  fontCycle,
  person,
  expandLess,
  expandMore,
  delete,
  sticker,
  lightbulb,
}

class _IconSource {
  final String? svgAsset;
  final String? pngAsset;
  final IconData? materialIcon;

  const _IconSource({this.svgAsset, this.pngAsset, this.materialIcon});
}

const Map<AppIconType, _IconSource> _sources = {
  AppIconType.back: _IconSource(svgAsset: 'assets/icons/icons/backarrow.svg'),
  AppIconType.add: _IconSource(svgAsset: 'assets/icons/icons/add.svg'),
  AppIconType.save: _IconSource(svgAsset: 'assets/icons/icons/save.svg'),
  AppIconType.send: _IconSource(svgAsset: 'assets/icons/icons/send.svg'),
  AppIconType.check: _IconSource(svgAsset: 'assets/icons/icons/check.svg'),
  AppIconType.close: _IconSource(svgAsset: 'assets/icons/icons/cross.svg'),
  AppIconType.preview: _IconSource(svgAsset: 'assets/icons/icons/preview.svg'),
  AppIconType.brokenImage: _IconSource(
    svgAsset: 'assets/icons/icons/brokenimage.svg',
  ),
  AppIconType.refresh: _IconSource(svgAsset: 'assets/icons/icons/refresh.svg'),
  AppIconType.addText: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/text.png',
  ),
  AppIconType.addImage: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/image.png',
  ),
  AppIconType.textColour: _IconSource(
    svgAsset: 'assets/icons/text_customisation_icons/A.svg',
  ),
  AppIconType.textBackground: _IconSource(
    svgAsset: 'assets/icons/text_customisation_icons/palette.svg',
  ),
  AppIconType.fontCycle: _IconSource(
    svgAsset: 'assets/icons/text_customisation_icons/AaAa.svg',
  ),
  AppIconType.person: _IconSource(materialIcon: Icons.person),
  AppIconType.expandLess: _IconSource(materialIcon: Icons.expand_less),
  AppIconType.expandMore: _IconSource(materialIcon: Icons.expand_more),
  AppIconType.delete: _IconSource(materialIcon: Icons.delete),
  AppIconType.sticker: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/sticker.png',
  ),
  AppIconType.lightbulb: _IconSource(materialIcon: Icons.lightbulb_outline),
};

class AppIcon extends StatelessWidget {
  final AppIconType type;
  final double? size;
  final Color? color;

  const AppIcon(this.type, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24.0;
    final resolvedColor = color ?? iconTheme.color;
    final source = _sources[type]!;

    final svgAsset = source.svgAsset;
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset,
        width: resolvedSize,
        height: resolvedSize,
        colorFilter: resolvedColor == null
            ? null
            : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      );
    }

    final pngAsset = source.pngAsset;
    if (pngAsset != null) {
      return Image.asset(
        pngAsset,
        width: resolvedSize,
        height: resolvedSize,
        fit: BoxFit.contain,
      );
    }

    return Icon(source.materialIcon, size: resolvedSize, color: resolvedColor);
  }
}
