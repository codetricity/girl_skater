import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Image;

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasCollisionDetection, TapDetector {
  late Ground ground;
  late Ground ground2;
  late Ground ground3;
  late Girl girl;
  final double gravity = 1.8;
  final double jumpForce = 150;
  final double groundFriction = .15;
  final double pushForce = 55;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    var girlImage = await images.load('girl2.png');
    girl = Girl.fromImage(girlImage)
      ..size = Vector2(100, 100 * girlImage.height / girlImage.width)
      ..position = Vector2(300, 100);
    add(girl);

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
  }

  @override
  onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (info.eventPosition.game.y < 100) {
      if (girl.velocity.y == 0) {
        girl.velocity.y -= jumpForce;
        girl.isJumping = true;
        print('jump');
      }
    }
    // tap on left side of screen to move left
    if (info.eventPosition.game.x < 100) {
      if (girl.facingRight) {
        girl.flipHorizontallyAroundCenter();
        girl.facingRight = false;
      }
      if (!girl.isJumping) {
        girl.velocity.x = -pushForce;
      }
      // tap on right side of screen to move right
    } else if (info.eventPosition.game.x > size.x - girl.width) {
      if (!girl.facingRight) {
        girl.flipHorizontallyAroundCenter();
        girl.facingRight = true;
      }
      if (!girl.isJumping) {
        girl.velocity.x = pushForce;
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

class Girl extends SpriteComponent with CollisionCallbacks, HasGameRef<MyGame> {
  Girl.fromImage(Image image) : super.fromImage(image) {
    debugMode = true;
    anchor = Anchor.bottomLeft;
  }
  bool facingRight = true;

  var velocity = Vector2(0, 60);
  bool isJumping = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (velocity.y != 0 || isJumping) {
      velocity.y += gameRef.gravity;
    }
    y += velocity.y * dt;

    // moving left
    if (x > 0 && velocity.x <= 0) {
      // if board is not jumping, then slow down board due to
      // friction
      if (!isJumping) {
        velocity.x = velocity.x + gameRef.groundFriction;
      }
      // do not apply too much friction and have the board
      // move in the opposite direction
      if (velocity.x > 0) {
        velocity.x = 0;
      }
      x += velocity.x * dt;
    }
    // move board to the right
    if (x < gameRef.size.x - width && velocity.x >= 0) {
      if (!isJumping) {
        velocity.x = velocity.x - gameRef.groundFriction;
      }
      if (velocity.x < 0) {
        velocity.x = 0;
      }
      x += velocity.x * dt;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground) {
      if (velocity.y > 0) {
        velocity.y = 0;
        print('hit ground');
        isJumping = false;
      }

      if (velocity.x != 0) {
        for (var point in intersectionPoints) {
          if (y - 5 >= point[1]) {
            print('collided on side ${point[1]}');
            velocity.x = 0;
          }
        }
        // print('$y, $intersectionPoints');
      }
    }
  }

  @override
  void onCollisionEnd(other) {
    super.onCollisionEnd(other);
    if (other is Ground) print('collision ended');
    isJumping = true;
  }
}
