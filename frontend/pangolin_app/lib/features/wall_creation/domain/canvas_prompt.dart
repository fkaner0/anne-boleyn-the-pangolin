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
      transform: CanvasTransform(center: Offset(200, 110), rotation: 0.07, scale: 1.3),
      label: "\"What I'd love to create...\"",
      action: CanvasPromptAction.addTextBox,
    ),
    const CanvasPrompt(
      id: 1,
      transform: CanvasTransform(center: Offset(110, 270), rotation: 0.10),
      label: "A work you're really proud of",
      action: CanvasPromptAction.addImage,
    ),
    const CanvasPrompt(
      id: 2,
      transform: CanvasTransform(center: Offset(290, 263), rotation: -0.13),
      label: "Something you're inspired by",
      action: CanvasPromptAction.addImage,
    ),
    const CanvasPrompt(
      id: 3,
      transform: CanvasTransform(center: Offset(135, 424), rotation: 0, scale: 1.0),
      label: "\"Why I started...\"",
      action: CanvasPromptAction.addTextBox,
    ),
    const CanvasPrompt(
      id: 4,
      transform: CanvasTransform(center: Offset(250, 500), rotation: 0, scale: 1.0),
      label: "\"Why I still love it...\"",
      action: CanvasPromptAction.addTextBox,
    ),
    const CanvasPrompt(
      id: 5,
      transform: CanvasTransform(center: Offset(200, 670), rotation: 0, scale: 1.7),
      label: "Something you're working on at the moment",
      action: CanvasPromptAction.addImage,
    ),
  ];
}
