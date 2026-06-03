import 'dart:ui' show Offset;

import 'canvas_transform.dart';

enum CanvasPromptAction { addImage, addTextBox }

class CanvasPrompt {
  final int id;
  final CanvasTransform transform;
  final String label;
  final CanvasPromptAction action;

  const CanvasPrompt({
    required this.id,
    required this.transform,
    required this.label,
    required this.action,
  });

  static List<CanvasPrompt> defaults() => [
    const CanvasPrompt(
      id: 0,
      transform: CanvasTransform(center: Offset(200, 155), rotation: -0.10),
      label: "What inspires me...",
      action: CanvasPromptAction.addTextBox,
    ),
    const CanvasPrompt(
      id: 1,
      transform: CanvasTransform(center: Offset(110, 400), rotation: 0.10),
      label: "Something you're inspired by...",
      action: CanvasPromptAction.addImage,
    ),
    const CanvasPrompt(
      id: 2,
      transform: CanvasTransform(center: Offset(290, 385), rotation: -0.13),
      label: "a work you're really proud of...",
      action: CanvasPromptAction.addImage,
    ),
    const CanvasPrompt(
      id: 3,
      transform: CanvasTransform(center: Offset(200, 580), rotation: 0.07),
      label: "Why I started...",
      action: CanvasPromptAction.addTextBox,
    ),
  ];
}
