import 'package:flame/components.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:spacetracer/mycamera.dart';
import 'package:spacetracer/myobject.dart';

class MyPlayer extends MyObject {
  final offsetSpeed = 2.0;
  var offset = Vector3.zero();

  MyPlayer() : super(
    modelPath: "player.obj", 
    diffuseName: "player.png",
  );

  void movePlayer(MyCamera myCamera, double dt) {
    final cz = myCamera.forward;
    final cx = myCamera.right;
    final cy = myCamera.up;
    var targetOffset = Vector3.zero();
    if (game.myWorld.playing) {
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowRight)) {
        targetOffset.x -= 3;
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowLeft)) {
        targetOffset.x += 3;
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowUp)) {
        targetOffset.y -= 3;
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.arrowDown)) {
        targetOffset.y += 3;
      }
      if (targetOffset.length > 3) {
        targetOffset *= 3 / targetOffset.length;
      }
    }
    if (game.myWorld.playing || game.myWorld.finished) {
      offset += (targetOffset - offset) * offsetSpeed * dt;
    }
    position3 = myCamera.position3 + cz * 10 + cx * offset.x + cy * (offset.y - 3);
    final vz = (myCamera.position3 + cz * 15 - position3).normalized();
    var vy = myCamera.position3 + cz * 10 - position3;
    vy = (vy - vz * vy.dot(vz)).normalized();
    final vx = vz.cross(vy).normalized();
    rotation3 = Matrix4(
      vx.x, vx.y, vx.z, 0, 
      vy.x, vy.y, vy.z, 0,
      vz.x, vz.y, vz.z, 0,
      0, 0, 0, 1,
    );
  }
}