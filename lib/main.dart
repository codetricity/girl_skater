import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:vel5/actors/skater.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasCollisionDetection, TapDetector {
  late Ground ground;
  late Ground ground2;
  late Ground ground3;
  final double gravity = 1.8;
  final double jumpForce = 150;
  final double groundFriction = .15;
  final double pushForce = 55;
  Skater skater = Skater();
  bool initialFall = true;
  late SpriteAnimation pushAnimation;
  late SpriteAnimation rideOnlyAnimation;
  late SpriteAnimation idleAnimation;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    ground =
        Ground(size: Vector2(size.x, 50), position: Vector2(0, size.y - 50));
    add(ground);

    ground2 = Ground(
        size: Vector2(size.x * .75, ground.height),
        position: Vector2(size.x * .25, size.y - ground.height - 50));
    add(ground2);

    ground3 = Ground(
        size: Vector2(size.x * .2, ground.height * 2),
        position: Vector2(size.x * .5, size.y - 4 * ground.height));
    add(ground3);
    List<Sprite> rideOnlySprites =
        await fromJSONAtlas('ride_only.png', 'ride_only.json');
    rideOnlyAnimation =
        SpriteAnimation.spriteList(rideOnlySprites, stepTime: 0.1, loop: true);

    List<Sprite> pushSprites =
        await fromJSONAtlas('skater_push.png', 'skater_push.json');
    pushAnimation =
        SpriteAnimation.spriteList(pushSprites, stepTime: 0.1, loop: true);

    idleAnimation = SpriteAnimation.spriteList(
        await fromJSONAtlas('idle.png', 'idle.json'),
        stepTime: 0.1);

    skater.animation = rideOnlyAnimation;

    var frameSize = rideOnlySprites.first.srcSize;
    skater.size = frameSize * .75;
    add(skater);
  }

  @override
  onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (info.eventPosition.game.y < 100) {
      if (skater.velocity.y == 0) {
        skater.velocity.y -= jumpForce;
        skater.isJumping = true;
        print('jump');
      }
    }
    // tap on left side of screen to move left
    if (info.eventPosition.game.x < 100) {
      if (skater.facingRight) {
        skater.flipHorizontallyAroundCenter();
        skater.facingRight = false;
      }
      if (!skater.isJumping) {
        skater.velocity.x = -pushForce;
        // change animation to pushing
        skater.animation = pushAnimation;
        Future.delayed(Duration(milliseconds: 1200), () {
          print('change to ride only animation');
          skater.animation = rideOnlyAnimation;
        });
      }

      // tap on right side of screen to move right
    } else if (info.eventPosition.game.x > size.x - skater.width) {
      if (!skater.facingRight) {
        skater.flipHorizontallyAroundCenter();
        skater.facingRight = true;
      }
      if (!skater.isJumping) {
        skater.velocity.x = pushForce;
        // change animation to pushing

        skater.animation = pushAnimation;
        Future.delayed(Duration(milliseconds: 1200), () {
          print('change to ride only animation');
          skater.animation = rideOnlyAnimation;
        });
      }
    }
  }
}

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
