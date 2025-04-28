import 'dart:ui';
import 'dart:async';
import 'package:flame/components.dart';
import 'package:spacetracer/myface.dart';
import 'package:spacetracer/mygame.dart';
import 'package:spacetracer/myutils.dart';

class MyObject extends PositionComponent with HasGameReference<MyGame> {
  var position3 = Vector3.zero();
  var rotation3 = Matrix4.identity();
  var scale3 = Vector3.all(1);
  String? modelPath;
  String? model0Path;
  String? diffuseName;
  String? emissionName;
  Image? diffuse;
  Image? emission;
  var backfaceCulling = true;
  var lodDistance = 50;
  var visible = true;

  var faces = List<MyFace>.empty();
  var faces0 = List<MyFace>.empty();

  MyObject({this.modelPath, this.model0Path, this.diffuseName, this.emissionName});

  @override
  FutureOr<void> onLoad() async {
    if (modelPath != null) {
      faces = await MyUtils.readObject("assets/models/${modelPath!}");
    }
    if (model0Path != null) {
      faces0 = await MyUtils.readObject("assets/models/${model0Path!}");
    }
    if (diffuseName != null) {
      diffuse = game.images.fromCache(diffuseName ?? "black.png");
    }
    if (emissionName != null) {
      emission = game.images.fromCache(emissionName ?? "black.png");
    }
  }

  Matrix4 getModelMatrix() {
    return Matrix4.identity()
    ..translate(position3)
    ..multiply(rotation3)
    ..scale(scale3);
  }
}