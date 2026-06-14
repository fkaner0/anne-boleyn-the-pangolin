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
  reply,
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

  const _IconSource({this.pngAsset, this.svgAsset, this.materialIcon});
}

const Map<AppIconType, _IconSource> _sources = {
  AppIconType.back: _IconSource(pngAsset: 'assets/icons/icons/back.png', svgAsset: 'assets/icons/icons-svg/back.svg'),
  AppIconType.add: _IconSource(pngAsset: 'assets/icons/icons/add.png', svgAsset: 'assets/icons/icons-svg/add.svg'),
  AppIconType.save: _IconSource(pngAsset: 'assets/icons/icons/save.png', svgAsset: 'assets/icons/icons-svg/save-filled.svg'),
  AppIconType.send: _IconSource(pngAsset: 'assets/icons/icons/send.png', svgAsset: 'assets/icons/icons-svg/send-filled.svg'),
  AppIconType.check: _IconSource(pngAsset: 'assets/icons/icons/tick.png', svgAsset: 'assets/icons/icons-svg/tick.svg'),
  AppIconType.close: _IconSource(pngAsset: 'assets/icons/icons/cross.png', svgAsset: 'assets/icons/icons-svg/cross.svg'),
  AppIconType.preview: _IconSource(pngAsset: 'assets/icons/icons/preview.png', svgAsset: 'assets/icons/icons-svg/preview.svg'),
  AppIconType.brokenImage: _IconSource(
    pngAsset: 'assets/icons/icons/brokenimage.png',
    svgAsset: 'assets/icons/icons-svg/brokenimage.svg',
  ),
  AppIconType.refresh: _IconSource(
    pngAsset: 'assets/icons/icons/refresh.png',
    svgAsset: 'assets/icons/icons-svg/refresh.svg'
  ),
  AppIconType.addText: _IconSource(
  pngAsset: 'assets/icons/wall_addition_icons/addtext.png',
  svgAsset: 'assets/icons/wall_addition_icons-svg/addtext.svg',
  ),
  AppIconType.addImage: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/addimage.png',
    svgAsset: 'assets/icons/wall_addition_icons-svg/addimage.svg',
  ),
  AppIconType.textColour: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/textcolour.png',
    svgAsset: 'assets/icons/text_customisation_icons-svg/textcolour.svg',
  ),
  AppIconType.textBackground: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/palettecolour.png',
    svgAsset: 'assets/icons/text_customisation_icons-svg/palettecolour.svg',
  ),
  AppIconType.fontCycle: _IconSource(
    pngAsset: 'assets/icons/text_customisation_icons/font.png',
    svgAsset: 'assets/icons/text_customisation_icons-svg/font.svg',
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
  AppIconType.reply: _IconSource(materialIcon: Icons.reply),
  AppIconType.personRemove: _IconSource(materialIcon: Icons.person_remove),
  AppIconType.sticker: _IconSource(
    pngAsset: 'assets/icons/wall_addition_icons/addsticker.png',
    svgAsset: 'assets/icons/wall_addition_icons-svg/addsticker.svg',
  ),
  AppIconType.lightbulb: _IconSource(
    pngAsset: 'assets/icons/icons/lightbulb.png',
    svgAsset: 'assets/icons/icons-svg/lightbulb.svg',
  ),
  AppIconType.meFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/mefilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/mefilled.svg',
  ),
  AppIconType.meUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/meunfilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/meunfilled.svg',
  ),
  AppIconType.findFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/findfilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/findfilled.svg',
  ),
  AppIconType.findUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/findunfilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/findunfilled.svg',
  ),
  AppIconType.palsFilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/palsfilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/palsfilled.svg',
  ),
  AppIconType.palsUnfilled: _IconSource(
    pngAsset: 'assets/icons/menu_bar_icons/palsunfilled.png',
    svgAsset: 'assets/icons/menu_bar_icons-svg/palsunfilled.svg',
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

    // prefers svg over png always
    final svgAsset = source.svgAsset;
    if (svgAsset != null) {
      return SvgPicture.asset(
        svgAsset,
        width: resolvedSize,
        height: resolvedSize,
        // colorFilter: resolvedColor == null
        //     ? null
        //     : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
        fit: BoxFit.contain,
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
