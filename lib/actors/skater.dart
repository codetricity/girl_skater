import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../main.dart';
import '../world/ground.dart';

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
  late SpriteAnimation pushAnimation;
  late SpriteAnimation rideOnlyAnimation;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    pushAnimation = SpriteAnimation.spriteList(gameRef.pushSprites,
        stepTime: 0.1, loop: true);
    rideOnlyAnimation = SpriteAnimation.spriteList(gameRef.rideOnlySprites,
        stepTime: 0.1, loop: true);
    add(RectangleHitbox(
        size: Vector2(width * .4, height),
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

    if (velocity.x == 0) {
      animation = gameRef.idleAnimation;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Ground) {
      if (velocity.y > 0) {
        // check to see if the two x intersection points
        // are really close together, which will indicate
        // that the skater is intersecting with the side
        // of the ground block
        if (intersectionPoints.length == 2) {
          var x1 = intersectionPoints.first[0];
          var x2 = intersectionPoints.last[0];
          if ((x1 - x2).abs() < 2) {
            // print('hit side, $y, $intersectionPoints');
            velocity.y = 100;
          } else {
            print('hit ground, ');
            velocity.y = 0;
            isJumping = false;
          }
        }

        if (gameRef.initialFall) {
          y -= 10;
          gameRef.initialFall = false;
        }
      }

      if (velocity.x != 0) {
        for (var point in intersectionPoints) {
          if (y - 5 >= point[1]) {
            // print('collided on side ${point[1]}');
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
