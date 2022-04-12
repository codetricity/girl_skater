import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../main.dart';

class Skater extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<MyGame> {
  Skater() : super() {
    debugMode = true;
    anchor = Anchor.bottomLeft;
  }
  bool facingRight = true;

  var velocity = Vector2(0, 60);
  bool isJumping = false;
  SpriteAnimationComponent skater = SpriteAnimationComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(RectangleHitbox(
        size: Vector2(width * .6, height),
        position: Vector2(width / 2, height),
        anchor: Anchor.bottomCenter));
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

        if (gameRef.initialFall) {
          y -= 10;
          gameRef.initialFall = false;
        }
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
