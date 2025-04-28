import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:spacetracer/main.dart';
import 'package:spacetracer/myface.dart';
import 'package:spacetracer/mygame.dart';
import 'package:spacetracer/myobject.dart';
import 'package:spacetracer/myutils.dart';

class MyRenderer extends PositionComponent with HasGameReference<MyGame> {
  late FragmentShader skyShader;
  late List<Image> skyImages;
  late Paint skyPaint;
  late List<Image> probeImages;
  late Image blackImage;  
  late Paint flarePaint;
  late Image flare0Image;
  late Rect flare0Rect;
  late Rect flare1RectSrc;
  late Rect flare1RectDst;
  late Image flare1Image;
  late Image vignetteImage;
  late Paint vignettePaint;
  late Rect vignetteRect;
  late List<Image> minimapImages;
  final identity = Float64List.fromList(Matrix4.identity().storage);
  late Paint checkpointPaint;
  late Paint playerPaint;
  late Paint minimapPaint;
  final minimapRatios = <double>[0.29, 0.185, 0.165];
  final minimapOffsets = <Vector2>[
    Vector2(-45, 2), 
    Vector2(-31, -37), 
    Vector2(-17, -13)
  ]; 
  final flareDirections = <Vector3>[
    Vector3(0, 0, -1),
    Vector3(-1, 0, 0),
    Vector3(1, 0, 0),
  ];
  final playerShape = Path()
  ..moveTo(0, -16)
  ..lineTo(16, 16)
  ..lineTo(0, 8)
  ..lineTo(-16, 16)
  ..close();

  @override
  FutureOr<void> onLoad() {
    skyShader = skyFragment.fragmentShader();
    skyPaint = Paint()..shader = skyShader;
    skyImages = [
      game.images.fromCache("skybox1.png"),
      game.images.fromCache("skybox2.png"),
      game.images.fromCache("skybox3.png"),
    ];
    probeImages = [
      game.images.fromCache("probe1.png"),
      game.images.fromCache("probe2.png"),
      game.images.fromCache("probe3.png"),
    ];
    blackImage = game.images.fromCache("black.png");
    flarePaint = Paint()..blendMode = BlendMode.plus;
    flare0Image = game.images.fromCache("flare0.png");
    flare0Rect = Rect.fromLTWH(0, 0, 256, 128);
    flare1RectSrc = Rect.fromLTWH(0, 0, 128, 128);
    flare1RectDst = Rect.fromLTWH(0, 0, 512, 256);
    flare1Image = game.images.fromCache("flare1.png");
    vignetteImage = game.images.fromCache("vignette.png");
    vignetteRect = Rect.fromLTWH(0, 0, 128, 128);
    vignettePaint = Paint()..blendMode = BlendMode.multiply;
    checkpointPaint = Paint()..color = Color(0xFF40C0FF);
    playerPaint = Paint()..color = Color(0xFFFF0000)..style = PaintingStyle.fill;
    minimapPaint = Paint()..blendMode = BlendMode.screen;
    minimapImages = [
      game.images.fromCache("minimap1.png"),
      game.images.fromCache("minimap2.png"),
      game.images.fromCache("minimap3.png"),
    ];
  }

  @override
  void render(Canvas canvas) {
    if (game.overlays.activeOverlays.contains(GameOverlay.main)) {
      return;
    }
    renderSky(canvas);
    renderObjects(canvas);
    renderVignette(canvas);
    renderFlare(canvas);
    renderMinimap(canvas);
  }

  void renderSky(Canvas canvas) {
    final height = math.tan(radians(game.myCamera.fov) / 2);
    skyShader
    ..setFloatUniforms((UniformsSetter value) {
      value
      ..setVector(game.myCamera.forward) 
      ..setVector(game.myCamera.right)
      ..setVector(-game.myCamera.up)
      ..setFloat(height / game.size.y);
    })
    ..setImageSampler(0, skyImages[game.myWorld.level]);
    canvas.drawRect(
      (-game.size / 2).toPositionedRect(game.size), 
      skyPaint,
    );
  }

  void renderObjects(Canvas canvas) {
    final projectionViewMatrix = game.myCamera.getProjectionViewMatrix();
    final faces = List<(Matrix4, MyFace, double, MyObject)>.empty(growable: true);
    for (final myObject in game.myWorld.children.whereType<MyObject>()) {
      if (!myObject.visible) { 
        continue;
      }
      final modelMatrix = myObject.getModelMatrix();
      final distance = (myObject.position3 - game.myCamera.position3).length;
      final lod = distance > myObject.lodDistance && myObject.faces0.isNotEmpty ? myObject.faces0 : myObject.faces;
      for (final face in lod) {
        final matrix = modelMatrix * face.data.projection;
        final center = matrix * face.data.center;
        final projected = projectionViewMatrix * center;
        if (projected.z < game.size.y) {
          continue;
        }
        final normal = myObject.rotation3 * face.data.normal;
        if (normal.dot(game.myCamera.position3 - center) < 0 && myObject.backfaceCulling) {
          continue;
        }
        var i = 0;
        for (; i < faces.length; i++) {
          if (faces[i].$3 < projected.z) {
            break;
          }
        }
        faces.insert(i, (projectionViewMatrix * matrix, face, projected.z, myObject));
      }
    }
    for (final buffer in faces) {
      buffer.$2.shader
      ..setFloatUniforms((UniformsSetter value) {
        value
        ..setVector(buffer.$4.rotation3 * buffer.$2.data.normals[0])
        ..setVector(buffer.$4.rotation3 * buffer.$2.data.normals[1])
        ..setVector(buffer.$4.rotation3 * buffer.$2.data.normals[2])
        ..setVectors(buffer.$2.data.textureCoordinates);
      })
      ..setImageSampler(0, buffer.$4.diffuse ?? blackImage)
      ..setImageSampler(1, buffer.$4.emission ?? blackImage)
      ..setImageSampler(2, probeImages[game.myWorld.level]);
      canvas
      ..save()
      ..transform32(buffer.$1.storage)
      ..drawVertices(
        buffer.$2.data.vertices,
        BlendMode.srcOver,
        buffer.$2.paint,
      )
      ..restore();
    }
  }

  void renderVignette(Canvas canvas) {
    final half = game.size / 2;
    canvas.drawImageRect(
      vignetteImage, 
      vignetteRect, 
      Rect.fromLTWH(-half.x, -half.y, game.size.x, game.size.y), 
      vignettePaint,
    );
  }

  void renderFlare(Canvas canvas) {
    var direction = game.myCamera.rotation3.transposed() * flareDirections[game.myWorld.level];
    if (direction.z < 0.01) {
      return;
    }
    direction /= direction.z;
    direction.y = -direction.y;
    final height = math.tan(radians(game.myCamera.fov) / 2) / 2;
    if (MyUtils.abs(direction.y) > height) {
      return;
    }
    final width = game.size.x * height / game.size.y;
    if (MyUtils.abs(direction.x) > width) {
      return;
    }
    final center = Vector2(
      direction.x * game.size.x / width / 2, 
      direction.y * game.size.y / height / 2,
    );
    canvas
    ..drawImageRect(
      flare0Image, 
      flare0Rect, 
      Rect.fromLTWH(
        center.x - game.size.y, 
        center.y - game.size.y / 2, 
        2 * game.size.y, 
        game.size.y,
      ), 
      flarePaint,
    )
    ..save()
    ..transform32(
      (
        Matrix4.identity()
        ..translate(Vector3(-center.x, -center.y, 0))
        ..rotateZ(math.atan2(center.x, -center.y))
        ..translate(Vector3(-256, -128, 0))
      ).storage
    )
    ..drawImageRect(
      flare1Image, 
      flare1RectSrc, 
      flare1RectDst,
      flarePaint,
    )
    ..restore();
  }

  void renderMinimap(Canvas canvas) {
    final index = game.myWorld.level;
    final width = minimapImages[index].width.toDouble();
    final height = minimapImages[index].height.toDouble();
    final scale = game.size.y / 480;
    final center = Vector2(-game.size.x / 2 + 128, 0);
    canvas.drawImageRect(
      minimapImages[index], 
      Rect.fromLTWH(0, 0, width, height), 
      Rect.fromLTWH(
        center.x - width * scale / 2, 
        center.y - height * scale / 2, 
        width * scale, 
        height * scale,
      ), 
      minimapPaint,
    );
    if (-1 <= game.myWorld.checkpoint && game.myWorld.checkpoint < game.myWorld.rings.length - 1) {
      final target = game.myWorld.rings[game.myWorld.checkpoint + 1];
      canvas.drawCircle(
        Offset(
          center.x - (target.position3.x * minimapRatios[index] + minimapOffsets[index].x) * scale,
          center.y + (target.position3.z * minimapRatios[index] + minimapOffsets[index].y) * scale,
        ), 
        8 * scale, 
        checkpointPaint,
      );
    }
    final cameraForward = game.myCamera.rotation3.forward;
    final cameraAngle = math.atan2(-cameraForward.x, -cameraForward.z);
    canvas
    ..save()
    ..translate(
      center.x - (game.myWorld.myPlayer.position3.x * minimapRatios[index] + minimapOffsets[index].x) * scale, 
      center.y + (game.myWorld.myPlayer.position3.z * minimapRatios[index] + minimapOffsets[index].y) * scale,
    )    
    ..rotate(cameraAngle)
    ..drawPath(playerShape, playerPaint)
    ..restore();
  }
}
