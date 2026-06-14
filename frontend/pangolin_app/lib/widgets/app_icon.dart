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
  edit,
  chevronRight,
  wallpaper,
  peopleAlt,
  message,
  moreVert,
  moreHoriz,
  personRemove,
  sticker,
  lightbulb,
  meFilled,
  meUnfilled,
  findFilled,
  findUnfilled,
  palsFilled,
  palsUnfilled,
}

class _IconSource {
  final String? svgAsset;
  final String? pngAsset;
  final IconData? materialIcon;

  const _IconSource({this.pngAsset, this.materialIcon}) : svgAsset = null;
}

const Map<AppIconType, _IconSource> _sources = {
  AppIconType.back: _IconSource(pngAsset: 'assets/icons/icons/back.png'),
  AppIconType.add: _IconSource(pngAsset: 'assets/icons/icons/add.png'),
  AppIconType.save: _IconSource(pngAsset: 'assets/icons/icons/save.png'),
  AppIconType.send: _IconSource(pngAsset: 'assets/icons/icons/send.png'),
  AppIconType.check: _IconSource(pngAsset: 'assets/icons/icons/tick.png'),
  AppIconType.close: _IconSource(pngAsset: 'assets/icons/icons/cross.png'),
  AppIconType.preview: _IconSource(pngAsset: 'assets/icons/icons/preview.png'),
  AppIconType.brokenImage: _IconSource(
    pngAsset: 'assets/icons/icons/brokenimage.png',
  ),
  AppIconType.refresh: _IconSource(pngAsset: 'assets/icons/icons/refresh.png'),
  AppIconType.addText: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/addtext.png',
  ),
  AppIconType.addImage: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/addimage.png',
  ),
  AppIconType.textColour: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/textcolour.png',
  ),
  AppIconType.textBackground: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/palettecolour.png',
  ),
  AppIconType.fontCycle: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/font.png',
  ),
  AppIconType.person: _IconSource(materialIcon: Icons.person),
  AppIconType.expandLess: _IconSource(materialIcon: Icons.expand_less),
  AppIconType.expandMore: _IconSource(materialIcon: Icons.expand_more),
  AppIconType.delete: _IconSource(materialIcon: Icons.delete),
  AppIconType.edit: _IconSource(materialIcon: Icons.edit),
  AppIconType.chevronRight: _IconSource(materialIcon: Icons.chevron_right),
  AppIconType.wallpaper: _IconSource(materialIcon: Icons.wallpaper),
  AppIconType.peopleAlt: _IconSource(materialIcon: Icons.people_alt_outlined),
  AppIconType.message: _IconSource(materialIcon: Icons.chat_bubble_outline),
  AppIconType.moreVert: _IconSource(materialIcon: Icons.more_vert),
  AppIconType.moreHoriz: _IconSource(materialIcon: Icons.more_horiz),
  AppIconType.personRemove: _IconSource(materialIcon: Icons.person_remove),
  AppIconType.sticker: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/addsticker.png',
  ),
  AppIconType.lightbulb: _IconSource(
    pngAsset: 'assets/icons/icons/lightbulb.png',
  ),
  AppIconType.meFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/mefilled.png',
  ),
  AppIconType.meUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/meunfilled.png',
  ),
  AppIconType.findFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/findfilled.png',
  ),
  AppIconType.findUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/findunfilled.png',
  ),
  AppIconType.palsFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/palsfilled.png',
  ),
  AppIconType.palsUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/palsunfilled.png',
  ),
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
