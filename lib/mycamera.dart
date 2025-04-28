import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:spacetracer/mygame.dart';
import 'package:spacetracer/myutils.dart';

class MyCamera extends CameraComponent with HasGameReference<MyGame> {
  var position3 = Vector3.zero();
  var rotation3 = Matrix4.identity();
  var fov = 120.0;

  final lookSpeed = 1.0;
  var velocity3 = Vector3.zero();
  var terminalVelocity = 30.0;
  var omega = Vector2.zero();

  var forward = Vector3(0, 0, 1);
  var right = Vector3(1, 0, 0);
  var up = Vector3(0, 1, 0);

  MyCamera({super.world});
  
  void moveCamera(double dt) {
    var targetOmega = Vector2.zero();
    var targetTerminalVelocity = 30.0;
    var acceleration = 50.0;
    var targetFov = 120.0;
    if (game.myWorld.playing && !game.myWorld.finished) {
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
        targetOmega.y += lookSpeed;
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
        targetOmega.y -= lookSpeed;
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
        targetOmega.x += lookSpeed * (MyUtils.inverseLook ? 1 : -1);
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
        targetOmega.x += lookSpeed * (MyUtils.inverseLook ? -1 : 1);
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.keyW)) {
        velocity3 += forward * acceleration * dt;
        if (game.pressedKeys.contains(LogicalKeyboardKey.space)) {
          targetTerminalVelocity = 60;
          acceleration = 60;
          targetFov = 140;
          // if (game.myWorld.boostNoise != null) {
          //   game.myWorld.boostNoise!.setVolume(1);
          // }
        } else {
          // if (game.myWorld.boostNoise != null) {
          //   game.myWorld.boostNoise!.setVolume(0);
          // }
          targetTerminalVelocity = 30;
          acceleration = 50;
          targetFov = 120;
        }
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.keyS)) {
        velocity3 -= velocity3 * 4 * math.min(1, dt);
      }
    }
    terminalVelocity += (targetTerminalVelocity - terminalVelocity) * 10 * dt;
    fov += (targetFov - fov) * 2 * dt;
    velocity3 -= velocity3 * 0.8 * dt;
    if (velocity3.length > terminalVelocity) {
      velocity3 *= terminalVelocity / velocity3.length;
    }
    if (game.myWorld.playing || game.myWorld.finished) {
      position3 += velocity3 * dt;
      omega += (targetOmega - omega) * 10 * dt;
      rotation3 *= Matrix4.identity()
      ..rotateY(omega.y * dt)
      ..rotateX(omega.x * dt);
    }
    forward = rotation3.forward;
    right = rotation3.right;
    up = rotation3.up;
  }

  Matrix4 getProjectionViewMatrix() {
    return Matrix4.identity()
    ..scale(game.size.y)
    ..scale(Vector3(1, -1, 1))
    ..setEntry(3, 2, math.tan(radians(fov) / 2))
    ..translate(Vector3(0, 0, -1))
    ..multiply(rotation3.transposed())
    ..translate(-position3);
  }
}