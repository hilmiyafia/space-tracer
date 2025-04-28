import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:spacetracer/main.dart';

class MyFace {
  final MyFaceData data;
  late FragmentShader shader;
  late Paint paint;
  
  MyFace(this.data){
    shader = faceFragment.fragmentShader();
    paint = Paint()..shader = shader;
  }
}

class MyFaceData {
  List<Vector3> normals;
  List<Vector2> textureCoordinates;
  late Vertices vertices;
  late Matrix4 projection;
  late Vector3 center;
  late Vector3 normal;

  MyFaceData(List<Vector3> vertices, this.normals, this.textureCoordinates) {
    final vx = (vertices[1] - vertices[0]).normalized();
    final vy = vx.cross(vertices[2] - vertices[0]).normalized();
    final vz = vx.cross(vy).normalized();
    final matrix = Matrix4(
      vx.x, vx.y, vx.z, 0,
      vz.x, vz.y, vz.z, 0,
      vy.x, vy.y, vy.z, 0,
      0, 0, 0, 1,
    );
    projection = Matrix4.translation(vertices[0]) * matrix;
    final transposed = matrix.transposed();
    final va = transposed * (vertices[0] - vertices[0]);
    final vb = transposed * (vertices[1] - vertices[0]);
    final vc = transposed * (vertices[2] - vertices[0]);
    this.vertices = Vertices.raw(
      VertexMode.triangles,
      Float32List.fromList(<double>[
        va.x, va.y,
        vb.x, vb.y,
        vc.x, vc.y,
      ]),
      textureCoordinates: Float32List.fromList(<double>[
        0, 0, 1, 0, 0, 1,
      ]),
    );
    center = (va + vb + vc) / 3.0;
    normal = (normals[0] + normals[1] + normals[2]) / 3;
  }
}