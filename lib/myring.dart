import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:spacetracer/myobject.dart';
import 'package:spacetracer/myutils.dart';

class MyRing extends MyObject {
  Vector3? lastPlayerPosition;
  final rotation3Speed = 0.1;
  final int index;

  MyRing(this.index) : super(
    modelPath: "ring.obj",
    model0Path: "ring0.obj",
    diffuseName: "ring.png", 
    emissionName: "ring_emission.png",
  );

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    rotation3 *= Matrix4.rotationZ(game.random.nextDouble() * math.pi);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.myWorld.playing) {
      return;
    }
    rotation3 *= Matrix4.rotationZ(rotation3Speed * dt);
    if (game.myWorld.checkpoint + 1 == index && hitPlayer()) {
      game.myWorld.checkpoint += 1;
      game.myWorld.resetPosition = position3;
      game.myWorld.resetRotation = lookAtMatrix(
        position3, 
        game.myWorld.rings[
          game.myWorld.checkpoint < game.myWorld.rings.length - 1 ? 
          (game.myWorld.checkpoint + 1) : 0
        ].position3
      );
      if (game.myWorld.checkpoint == game.myWorld.rings.length - 1) {
        if (game.myWorld.lap == 2) {
          FlameAudio.bgm.stop();
          game.myWorld.playing = false;
          game.myWorld.finished = true;
          game.myWorld.checkpoint -= 1;
          if (MyUtils.recordTime[game.myWorld.level] < 0 || MyUtils.recordTime[game.myWorld.level] > game.myWorld.timer) {
            MyUtils.recordTime[game.myWorld.level] = game.myWorld.timer;
            MyUtils.recordScore[game.myWorld.level] = game.myWorld.score;
          }
          // if (game.myWorld.boostNoise != null) {
          //   game.myWorld.boostNoise!.setVolume(0);
          // }
          game.myWorld.playFinish();
          game.overlays.add(GameOverlay.finished);
        } else {
          game.myWorld.resetCrystals();
          game.myWorld.checkpoint = -1;
          game.myWorld.lap += 1;
        }
      }
    }
  }

  Matrix4 lookAtMatrix(Vector3 a, Vector3 b) {
    final vz = (b - a).normalized();
    final vy = (MyUtils.up - vz * MyUtils.up.dot(vz)).normalized();
    final vx = vy.cross(vz).normalized();
    return Matrix4(
      vx.x, vx.y, vx.z, 0,
      vy.x, vy.y, vy.z, 0,
      vz.x, vz.y, vz.z, 0,
      0, 0, 0, 1,
    );
  }

  bool hitPlayer() {
    if (lastPlayerPosition == null) {
      lastPlayerPosition = game.myWorld.myPlayer.position3;
      return false;
    }
    final matrix = rotation3.transposed();
    final pos0 = matrix * (lastPlayerPosition! - position3);
    final pos1 = matrix * (game.myWorld.myPlayer.position3 - position3);
    lastPlayerPosition = game.myWorld.myPlayer.position3;
    if ((pos0.z > 0 && pos1.z > 0) || (pos0.z < 0 && pos1.z < 0)) {
      return false;
    }
    final delta = pos1.z - pos0.z;
    var intersection = pos0;
    if (delta > 0.01) {
      intersection -= (pos1 - pos0) * pos0.z / delta;
    }
    if (MyUtils.abs(intersection.x) > 6 || MyUtils.abs(intersection.y) > 6) {
      game.myWorld.showMissText();
      return false;
    }
    game.myWorld.missText.text = "";
    lastPlayerPosition = null;
    return true;
  }
}