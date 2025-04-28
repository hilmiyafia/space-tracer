import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' show KeyEventResult;
import 'package:flutter/services.dart' show KeyEvent, LogicalKeyboardKey;
import 'package:spacetracer/mycamera.dart';
import 'package:spacetracer/myworld.dart';

class MyGame extends FlameGame with KeyboardEvents {
  final pressedKeys = <LogicalKeyboardKey>{};
  late MyWorld myWorld;
  late MyCamera myCamera;
  final random = math.Random();

  @override
  FutureOr<void> onLoad() async {
    FlameAudio.bgm.initialize();
    await FlameAudio.audioCache.loadAll([
      "button.ogg", 
      "crystal.ogg", 
      "bell_low.ogg", 
      "bell_high.ogg",
      "finish.ogg",
    ]);
    await images.loadAllImages();
    myWorld = MyWorld();
    myCamera = MyCamera(world: myWorld);
    addAll([myWorld, myCamera]);
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    pressedKeys.clear();
    pressedKeys.addAll(keysPressed);
    return KeyEventResult.handled;
  }
}
