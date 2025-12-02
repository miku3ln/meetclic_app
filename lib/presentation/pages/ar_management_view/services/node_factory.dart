import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as v;

class NodeFactory {
  NodeFactory._();

  static bool isValidGlbUrl(String url) {
    if (url.isEmpty) return false;
    final u = Uri.tryParse(url);
    return u != null &&
        (u.isScheme('http') || u.isScheme('https')) &&
        u.path.toLowerCase().endsWith('.glb');
  }

  static ARNode webGlb({
    required String url,
    required v.Vector3 position,
    required v.Vector3 eulerAngles,
    required double uniformScale,
  }) {
    return ARNode(
      type: NodeType.webGLB,
      uri: url,
      position: position,
      eulerAngles: eulerAngles,
      scale: v.Vector3.all(uniformScale),
    );
  }

  /// 🔥 Archivo en filesystem (cache/descargas): usa NodeType.webGLB con scheme file://
  static ARNode localFileGlb({
    required String filePath,
    required v.Vector3 position,
    required v.Vector3 eulerAngles,
    required double uniformScale,
  }) {
    // Normaliza a URI file://
    final uri = Uri.file(filePath).toString(); // ej: file:///data/user/0/…
    return ARNode(
      type: NodeType.webGLB, // importante!
      uri: uri,
      position: position,
      eulerAngles: eulerAngles,
      scale: v.Vector3.all(uniformScale),
    );
  }
}
