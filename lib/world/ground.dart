import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/material.dart' hide Image;

class Ground extends PositionComponent {
  Ground({required size, required position})
      : super(size: size, position: position) {
    debugMode = true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawGround(canvas);
  }

  void drawGround(canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height),
        Paint()..color = Colors.brown.shade300);
  }
}
