import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RegistrationCameraPreviewScreen extends StatefulWidget {
  final CameraDescription cameraDescription;
  const RegistrationCameraPreviewScreen({
    super.key,
    required this.cameraDescription,
  });

  @override
  State<RegistrationCameraPreviewScreen> createState() =>
      _RegistrationCameraPreviewScreenState();
}

class _RegistrationCameraPreviewScreenState
    extends State<RegistrationCameraPreviewScreen> {
  CameraController? cameraController;

  @override
  void initState() {
    _initializeCamera();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 750),
        child:
            (cameraController != null && cameraController!.value.isInitialized)
                ? CameraPreview(cameraController!)
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _initializeCamera() async {
    cameraController = CameraController(
      widget.cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await cameraController!.initialize();
    setState(() {});
  }
}
