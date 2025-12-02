import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:vector_math/vector_math_64.dart' as v;

import '../models/totem.dart';

class ARService {
  ARSessionManager? session;
  ARObjectManager? objects;

  void attach(ARSessionManager s, ARObjectManager o) {
    session = s;
    objects = o;
  }

  Future<ARNode?> placeTotem(Totem totem, ARHitTestResult hit) async {
    if (objects == null) return null;
    final node = ARNode(
      type: totem.isLocal ? NodeType.localGLTF2 : NodeType.webGLB,
      uri: totem.assetGlb,
      position: hit.worldTransform.getTranslation(),
      rotation: v.Vector4(0, 1, 0, 0),
      scale: v.Vector3(1.0, 1.0, 1.0),
    );
    final ok = await objects!.addNode(node);
    return ok == true ? node : null;
  }
}
