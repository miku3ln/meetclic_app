/*import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart'; // PlaneDetectionConfig
import 'package:ar_flutter_plugin/datatypes/node_types.dart'; // <-- NodeType aquí
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';*/

/*
class ARCapturePage extends StatefulWidget {
  final String
  glbAssetPath; // p.ej. assets/totems/sembrador/totem_sembrador.glb
  const ARCapturePage({super.key, required this.glbAssetPath});

  @override
  State<ARCapturePage> createState() => _ARCapturePageState();
}

class _ARCapturePageState extends State<ARCapturePage> {
  ARSessionManager? _session;
  ARObjectManager? _objects;
  ARNode? _node;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ARView(
        // En 0.7.3 se configura la detección de planos desde el constructor:
        planeDetectionConfig:
            PlaneDetectionConfig.horizontal, // o .horizontalAndVertical
        onARViewCreated: _onARViewCreated, // firma de 4 parámetros
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_node != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tótem invocado y guardado ✨')),
            );
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.check),
        label: const Text('Invocar'),
      ),
    );
  }

  // Firma correcta para 0.7.3:
  // ARViewCreatedCallback = void Function(
  //   ARSessionManager, ARObjectManager, ARAnchorManager, ARLocationManager)
  Future<void> _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) async {
    _session = sessionManager;
    _objects = objectManager;

    // Tap en plano o punto -> colocar GLB
    _session!.onPlaneOrPointTap = (hits) async {
      if (hits.isEmpty) return;
      final hit = hits.first;

      final node = ARNode(
        type: NodeType.localGLTF2,
        uri: widget.glbAssetPath,
        position: hit.worldTransform.getTranslation(),
        rotation: v.Vector4(0, 1, 0, 0),
        scale: v.Vector3(
          1.0,
          1.0,
          1.0,
        ), // tu GLB debe venir ya a escala en metros
      );

      final added = await _objects!.addNode(node); // devuelve bool?
      if (added == true) {
        _node = node;
        setState(() {});
      }
    };
  }
}
*/
