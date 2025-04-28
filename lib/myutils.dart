import 'package:flame/components.dart';
import 'package:flutter/material.dart' show ButtonStyle, Color, FontWeight, TextStyle, WidgetStatePropertyAll;
import 'package:flutter/services.dart' show rootBundle;
import 'package:spacetracer/myface.dart';

class MyUtils {
  static final recordTime = <double>[-1, -1, -1];
  static final recordScore = <int>[0, 0, 0];
  static var inverseLook = false;
  static final Map<String, List<MyFaceData>> objectCache = {};

  static String printTime(double x) {
    if (x < 0) {
      return "--:--:--";
    }
    final miliseconds = ((x % 1) * 100).toInt().toString().padLeft(2, "0");
    final seconds = (x % 60).toInt().toString().padLeft(2, "0");
    final minutes = (x ~/ 60).toString().padLeft(2, "0");
    return "$minutes:$seconds:$miliseconds";
  }

  static Future<List<MyFace>> readObject(String path) async {
    if (!objectCache.containsKey(path)) {
      final output = List<MyFaceData>.empty(growable: true);
      final vertices = List<Vector3>.empty(growable: true);
      final normals = List<Vector3>.empty(growable: true);
      final textureCoordinates = List<Vector2>.empty(growable: true);
      final lines = (await rootBundle.loadString(path)).split("\n");
      for (final line in lines) {
        final data = line.split(" ");
        if (data[0] == "v") {
          vertices.add(Vector3(
            double.parse(data[1]), 
            double.parse(data[2]), 
            double.parse(data[3]),
          ));
        }
        if (data[0] == "vn") {
          normals.add(Vector3(
            double.parse(data[1]), 
            double.parse(data[2]), 
            double.parse(data[3]),
          ));
        }
        if (data[0] == "vt") {
          textureCoordinates.add(Vector2(
            double.parse(data[1]), 
            1 - double.parse(data[2]),
          ));
        }
        if (data[0] == "f") {
          final va = data[1].split("/");
          final vb = data[2].split("/");
          final vc = data[3].split("/");
          output.add(MyFaceData(
            <Vector3>[
              vertices[int.parse(va[0]) - 1],
              vertices[int.parse(vb[0]) - 1],
              vertices[int.parse(vc[0]) - 1],
            ],
            <Vector3>[
              normals[int.parse(va[2]) - 1],
              normals[int.parse(vb[2]) - 1],
              normals[int.parse(vc[2]) - 1],
            ],
            <Vector2>[
              textureCoordinates[int.parse(va[1]) - 1],
              textureCoordinates[int.parse(vb[1]) - 1],
              textureCoordinates[int.parse(vc[1]) - 1],
            ]
          ));
        }
      }
      objectCache[path] = output;
    }
    return List<MyFace>.generate(objectCache[path]!.length, (i) {
      return MyFace(objectCache[path]![i]);
    });
  }

  static Future<List<(Vector3, Matrix4, double)>> readMap(String path) async {
    final output = List<(Vector3, Matrix4, double)>.empty(growable: true);
    final vertices = List<Vector3>.empty(growable: true);
    final lines = (await rootBundle.loadString("assets/models/$path")).split("\n");
    for (final line in lines) {
      final data = line.split(" ");
      if (data[0] == "v") {
        vertices.add(Vector3(
          double.parse(data[1]), 
          double.parse(data[2]), 
          double.parse(data[3]),
        ));
      }
      if (data[0] == "l") {
        final a = vertices[int.parse(data[1]) - 1];
        final b = vertices[int.parse(data[2]) - 1];
        final d = b - a;
        final s = d.length;
        final vz = d / s;
        late Vector3 vy;
        if (abs(vz.z) < abs(vz.x) && abs(vz.z) < abs(vz.y)) {
          vy = (forward - vz * forward.dot(vz)).normalized();
        } else if (abs(vz.x) < abs(vz.y) && abs(vz.x) < abs(vz.z)) {
          vy = (right - vz * right.dot(vz)).normalized();
        } else {
          vy = (up - vz * up.dot(vz)).normalized();
        }
        final vx = vy.cross(vz).normalized();
        output.add((
          a,
          Matrix4(
            vx.x, vx.y, vx.z, 0,
            vy.x, vy.y, vy.z, 0,
            vz.x, vz.y, vz.z, 0,
            0, 0, 0, 1
          ),
          s,
        ));
      }
    }
    return output;
  }

  static double abs(double x) => x < 0 ? -x : x;

  static const whiteButton = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Color(0xFFFFFFFF)),
  );

  static const blackText = TextStyle(
    color: Color(0xFF000000),
    fontWeight: FontWeight.bold,
  );

  static const whiteText = TextStyle(
    color: Color(0xFFFFFFFF),
    fontWeight: FontWeight.bold,
  );
  
  static final whitePaint = TextPaint(
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFFFFFFFF),
    ),
  );

  static const titleStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static final startRotations = <Matrix4>[
    Matrix4.identity(),
    Matrix4.rotationY(-radians(45)),
    Matrix4.rotationY(-radians(45)),
  ];

  static const levelColors = <int>[
    0x800080FF, 0x80FF4000, 0x8000FF80,
  ];
  
  static final Vector3 forward = Vector3(0, 0, 1);
  static final Vector3 right = Vector3(1, 0, 0);
  static final Vector3 up = Vector3(0, 1, 0);
} 

class GameOverlay { 
  static const String main = "menu";
  static const String settings = "settings";
  static const String tutorial = "tutorial";
  static const String selectLevel = "level";
  static const String finished = "finished";
  static const String paused = "paused";
}