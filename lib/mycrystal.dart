import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:spacetracer/myobject.dart';

class MyCrystal extends MyObject {
  final omega = 90.0;
  bool collected = false;
  Vector3? lastPlayerPosition;

  MyCrystal() : super(
    diffuseName: "crystal.png", 
    modelPath: "crystal.obj",
    emissionName: "white.png",
  );

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.myWorld.playing || collected) {
      return;
    }
    if (hitPlayer()) {
      game.myWorld.score += 100;
      collected = true;
      visible = false;
      lastPlayerPosition = null;
      FlameAudio.play("crystal.ogg");
    }
    rotation3 = game.myCamera.rotation3;
  }

  bool hitPlayer() {
    if (lastPlayerPosition == null) {
      lastPlayerPosition = game.myWorld.myPlayer.position3;
      return false;
    }
    var a = game.myWorld.myPlayer.position3 - lastPlayerPosition!;
    final limit = a.length;
    if (limit < 0.01) {
      lastPlayerPosition = game.myWorld.myPlayer.position3;
      return (game.myWorld.myPlayer.position3 - position3).length < 3;
    }
    a /= limit;
    final b = position3 - lastPlayerPosition!;
    final double distance = math.min(math.max(0, a.dot(b)), limit);
    final c = a * distance;
    lastPlayerPosition = game.myWorld.myPlayer.position3;
    return (c - b).length < 3; 
  }
}