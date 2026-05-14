import 'dart:ui';

import 'package:flame/components.dart' hide Block;

import '../core/constants.dart';
import '../entities/ball.dart';
import '../entities/block.dart';

abstract final class PhysicsEngine {
  static Rect gameField(Vector2 gameSize) {
    const inset = GameConst.wallInset;
    return Rect.fromLTRB(inset, inset, gameSize.x - inset, gameSize.y - inset);
  }

  static bool handleWallCollisions(Ball ball, Rect field) {
    const r = GameConst.ballRadius;
    bool bounced = false;

    if (ball.position.x - r < field.left) {
      ball.position.x = field.left + r;
      ball.velocity.x = ball.velocity.x.abs();
      ball.velocity.scale(GameConst.wallBounceDamp);
      bounced = true;
    } else if (ball.position.x + r > field.right) {
      ball.position.x = field.right - r;
      ball.velocity.x = -ball.velocity.x.abs();
      ball.velocity.scale(GameConst.wallBounceDamp);
      bounced = true;
    }

    if (ball.position.y - r < field.top) {
      ball.position.y = field.top + r;
      ball.velocity.y = ball.velocity.y.abs();
      ball.velocity.scale(GameConst.wallBounceDamp);
      bounced = true;
    } else if (ball.position.y + r > field.bottom) {
      ball.position.y = field.bottom - r;
      ball.velocity.y = -ball.velocity.y.abs();
      ball.velocity.scale(GameConst.wallBounceDamp);
      bounced = true;
    }

    return bounced;
  }

  static bool checkBallBlock(Ball ball, Block block) {
    final halfW = block.size.x / 2;
    final halfH = block.size.y / 2;

    final double closestX = ball.position.x.clamp(
      block.position.x - halfW,
      block.position.x + halfW,
    ).toDouble();
    final double closestY = ball.position.y.clamp(
      block.position.y - halfH,
      block.position.y + halfH,
    ).toDouble();

    final dx = ball.position.x - closestX;
    final dy = ball.position.y - closestY;
    return (dx * dx + dy * dy) <
        GameConst.ballRadius * GameConst.ballRadius;
  }

  static void resolveBallBlock(Ball ball, Block block) {
    final halfW = block.size.x / 2;
    final halfH = block.size.y / 2;

    final double closestX = ball.position.x.clamp(
      block.position.x - halfW,
      block.position.x + halfW,
    ).toDouble();
    final double closestY = ball.position.y.clamp(
      block.position.y - halfH,
      block.position.y + halfH,
    ).toDouble();

    final normal = Vector2(
      ball.position.x - closestX,
      ball.position.y - closestY,
    );

    if (normal.length2 < 0.001) {
      // Ball center inside block — push out along inverse velocity
      normal.setFrom(ball.velocity);
      normal.negate();
    }
    normal.normalize();

    // Reflect velocity off normal
    final dot = ball.velocity.dot(normal);
    if (dot < 0) {
      ball.velocity.sub(normal.scaled(2 * dot));
    }
    ball.velocity.scale(GameConst.blockBounceDamp);

    // Push ball outside block
    ball.position
      ..setFrom(Vector2(closestX, closestY))
      ..add(normal.scaled(GameConst.ballRadius + 0.5));
  }

  static void handleCoreCollision(
    Ball ball,
    Vector2 corePos,
    double coreRadius,
  ) {
    final dist = ball.position.distanceTo(corePos);
    final minDist = coreRadius + GameConst.ballRadius;
    if (dist >= minDist) return;

    final normal = (ball.position - corePos)..normalize();
    ball.position.setFrom(corePos + normal.scaled(minDist + 1));

    final dot = ball.velocity.dot(normal);
    if (dot < 0) {
      ball.velocity.sub(normal.scaled(2 * dot));
    }
  }
}
