import 'package:flutter/material.dart';
import '../../domain/profile_text.dart';
import 'wiggle_hint.dart';

class BedroomWallTextBoxItem extends StatelessWidget {
  static const double _baseFontSize = 16;
  static const double _minWidth = 96;
  static const double _maxWidth = 240;

  final ProfileText textbox;
  final double renderScale;
  final VoidCallback onTap;
  final bool wiggle;

  const BedroomWallTextBoxItem({
    super.key,
    required this.textbox,
    required this.renderScale,
    required this.onTap,
    this.wiggle = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final position = textbox.position;
    final scale = position.scale;

    final text = [
      textbox.title,
      textbox.body,
    ].where((part) => part.isNotEmpty).join('\n');

    return Positioned(
      left: position.x * renderScale,
      top: position.y * renderScale,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: position.rotation,
          child: WiggleHint(
            enabled: wiggle,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: _minWidth * renderScale * scale,
                  maxWidth: _maxWidth * renderScale * scale,
                ),
                child: IntrinsicWidth(
                  child: Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: BoxDecoration(
                      color: textbox.backgroundHexARGB != null
                          ? Color(textbox.backgroundHexARGB!)
                          : colorScheme.surface,
                      border: Border.all(color: colorScheme.outline),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        inherit: false,
                        fontSize: _baseFontSize * renderScale * scale,
                        fontFamily: textbox.font,
                        color: textbox.fontHexARGB != null
                            ? Color(textbox.fontHexARGB!)
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
