import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:spacetracer/myasteroid.dart';
import 'package:spacetracer/mycrystal.dart';
import 'package:spacetracer/mygame.dart';
import 'package:spacetracer/myjet.dart';
import 'package:spacetracer/myplayer.dart';
import 'package:spacetracer/myrenderer.dart';
import 'package:spacetracer/myring.dart';
import 'package:spacetracer/myutils.dart';

class MyWorld extends World with HasGameReference<MyGame> {
  late MyPlayer myPlayer;
  late MyJet myJet;
  late MyRenderer myRenderer;
  late TextComponent timerLabel;
  late TextComponent timerText;
  late TextComponent lapLabel;
  late TextComponent lapText;
  late TextComponent checkpointLabel;
  late TextComponent checkpointText;
  late TextComponent scoreLabel;
  late TextComponent scoreText;
  late TextComponent missText;
  late TextComponent titleText;
  var rings = List<MyRing>.empty(growable: true);
  var level = 0;
  var timer = 0.0;
  var score = 0;
  var playing = false;
  var finished = false;
  var checkpoint = -1;
  var lap = 1;
  var resetPosition = Vector3.zero();
  var resetRotation = Matrix4.identity();
  // AudioPlayer? boostNoise;
  AudioPlayer? finishMusic;

  @override
  Future<void> onLoad() async {
    myPlayer = MyPlayer();
    myRenderer = MyRenderer();
    myJet = MyJet(myPlayer);
    timerLabel = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    timerText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    lapLabel = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    lapText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    checkpointLabel = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    checkpointText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.topCenter);
    scoreLabel = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.bottomCenter);
    scoreText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.bottomCenter);
    missText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.center);
    titleText = TextComponent(textRenderer: MyUtils.whitePaint, anchor: Anchor.center);
    add(myPlayer);
    add(myJet);
    add(myRenderer);
    add(timerLabel);
    add(timerText);
    add(lapLabel);
    add(lapText);
    add(checkpointLabel);
    add(checkpointText);
    add(scoreLabel);
    add(scoreText);
    add(missText);
    add(titleText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.overlays.activeOverlays.contains(GameOverlay.main)) {
      return;
    }
    dt = math.min(0.1, dt);
    if (playing) {
      timer += dt;
      if (game.pressedKeys.contains(LogicalKeyboardKey.escape)) {
        FlameAudio.play("button.ogg");
        playing = false;
        game.overlays.add(GameOverlay.paused);
      }
      if (game.pressedKeys.contains(LogicalKeyboardKey.keyR)) {
        for (final ring in rings) {
          ring.lastPlayerPosition = null;
        }
        game.myCamera.position3 = resetPosition;
        game.myCamera.rotation3 = resetRotation;
        game.myCamera.velocity3 = Vector3.zero();
        missText.text = "";
        myPlayer.position3 = resetPosition + game.myCamera.forward * 10 - game.myCamera.up * 3;
        myPlayer.offset = Vector3.zero();
      }
    } else {
      if (FlameAudio.bgm.isPlaying) {
        Future.delayed(
          Duration(milliseconds: 100), 
          FlameAudio.bgm.pause,
        );
      }
    }
    game.myCamera.moveCamera(dt);
    myPlayer.movePlayer(game.myCamera, dt);
    myJet.scaleJet(dt);
    final top = -game.size.y / 2;
    final scale = game.size.y / 480;
    timerLabel.text = "TIME";
    timerLabel.scale = Vector2.all(game.size.y / 256);
    timerLabel.position = Vector2(0, top + 16 * scale);
    timerText.text = MyUtils.printTime(timer);
    timerText.scale = Vector2.all(game.size.y / 128);
    timerText.position = Vector2(0, top + 48 * scale);
    lapLabel.text = "LAP";
    lapLabel.scale = Vector2.all(game.size.y / 256);
    lapLabel.position = Vector2(-256 * scale, top + 16 * scale);
    lapText.text = "$lap/2";
    lapText.scale = Vector2.all(game.size.y / 256);
    lapText.position = Vector2(-256 * scale, top + 48 * scale);
    checkpointLabel.text = "CHECKPOINT";
    checkpointLabel.scale = Vector2.all(game.size.y / 256);
    checkpointLabel.position = Vector2(256 * scale, top + 16 * scale);
    checkpointText.text = "${checkpoint + 2}/${rings.length}";
    checkpointText.scale = Vector2.all(game.size.y / 256);
    checkpointText.position = Vector2(256 * scale, top + 48 * scale);
    scoreLabel.text = "SCORE";
    scoreLabel.scale = Vector2.all(game.size.y / 256);
    scoreLabel.position = Vector2(0, -top - 48 * scale);
    scoreText.text = score.toString();
    scoreText.scale = Vector2.all(game.size.y / 256);
    scoreText.position = Vector2(0, -top - 16 * scale);
    missText.scale = Vector2.all(game.size.y / 256);
    titleText.scale = Vector2.all(game.size.y / 64);
  }

  void showMissText() {
    missText.text = "You missed the checkpoint!";
    missText.scale = Vector2.all(game.size.y / 256);
  }

  Future<void> loadLevel(int level) async {
    // loadBoost();
    rings.clear();
    this.level = level;
    timer = 0;
    score = 0;
    finished = false;
    checkpoint = -1;
    lap = 1;
    resetPosition = Vector3.zero();
    resetRotation = MyUtils.startRotations[level];
    game.myCamera.position3 = resetPosition;
    game.myCamera.rotation3 = MyUtils.startRotations[level];
    game.myCamera.velocity3 = Vector3.zero();
    myPlayer.position3 = Vector3(0, -3, 10);
    myPlayer.offset = Vector3.zero();
    myJet.bufferScale = 0;
    titleText.text = "";
    missText.text = "";
    for (final child in children.whereType<MyRing>()) {
      remove(child);
    }
    for (final child in children.whereType<MyAsteroid>()) {
      remove(child);
    }
    for (final child in children.whereType<MyCrystal>()) {
      remove(child);
    }
    for (final data in (await MyUtils.readMap("ring_map${level + 1}.obj"))) {
      rings.add(
        MyRing(rings.length)
        ..position3 = data.$1
        ..rotation3 = data.$2,
      );
    }
    if (level > 0) {
      for (final data in (await MyUtils.readMap("asteroid_map${level + 1}.obj"))) {
        add(
          MyAsteroid()
          ..position3 = data.$1
          ..rotation3 = data.$2
          ..scale3 = Vector3.all(data.$3),
        );
      }
    }
    for (final data in (await MyUtils.readMap("crystal_map${level + 1}.obj"))) {
      add(
        MyCrystal()
        ..position3 = data.$1
      );
    }
    addAll(rings);
    countDown(false);
  }

  void resetCrystals() {
    for (final crystal in children.whereType<MyCrystal>()) {
      crystal.collected = false;
      crystal.visible = true;
      crystal.lastPlayerPosition = null;
    }
  }
  
  // Future<void> loadBoost() async {
  //   boostNoise ??= await FlameAudio.loop("boost_noise.ogg", volume: 0);
  // }

  Future<void> playFinish() async {
    if (finishMusic != null) {
      finishMusic!.stop();
      finishMusic!.dispose();
    }
    finishMusic = await FlameAudio.play("finish.ogg");
  }

  Future<void> countDown(bool resume) async {
    await Future.delayed(Duration(seconds: 1));
    FlameAudio.play("bell_low.ogg");
    titleText.text = "READY";
    await Future.delayed(Duration(seconds: 1));
    FlameAudio.play("bell_low.ogg");
    titleText.text = "SET";
    await Future.delayed(Duration(seconds: 1));
    FlameAudio.play("bell_high.ogg");
    titleText.text = "GO!";
    playing = true;
    await Future.delayed(Duration(seconds: 1));
    titleText.text = "";
    if (resume) {
      FlameAudio.bgm.resume();
    } else {
      FlameAudio.bgm.play("music${level + 1}.ogg");
    }
  }
}
