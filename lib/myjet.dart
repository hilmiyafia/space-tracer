
import 'package:flame/components.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:spacetracer/myobject.dart';

class MyJet extends MyObject {
  final MyObject player;
  double bufferScale = 0;
  final bufferScaleSpeed = 10.0;

  MyJet(this.player) : super(
    diffuseName: "player.png", 
    modelPath: "jet.obj", 
    emissionName: "player_emission.png",
  ) {
    position3 = Vector3(0, 0.536901, -1.3224);
    backfaceCulling = false;
    scale3.z = -0.1;
  }

  void scaleJet(double dt) {
    if (game.myWorld.playing || game.myWorld.finished) {
      var jetOn = false;
      if (game.myWorld.playing) {
        jetOn |= game.pressedKeys.contains(LogicalKeyboardKey.keyW);
        jetOn |= game.pressedKeys.contains(LogicalKeyboardKey.arrowUp);
        jetOn |= game.pressedKeys.contains(LogicalKeyboardKey.arrowDown);
        jetOn |= game.pressedKeys.contains(LogicalKeyboardKey.arrowLeft);
        jetOn |= game.pressedKeys.contains(LogicalKeyboardKey.arrowRight);
      }
      bufferScale += ((jetOn ? 1 : 0) - bufferScale) * bufferScaleSpeed * dt;
      if (bufferScale < 0.1) {
        bufferScale = 0;
      }
      final length = game.pressedKeys.contains(LogicalKeyboardKey.space) ? 2.0 : 1.0;
      scale3.z = (length + game.random.nextDouble() * 0.3) * (bufferScale - 0.1); 
    }
  }

  @override
  Matrix4 getModelMatrix() {
    return player.getModelMatrix() * super.getModelMatrix();
  }
}