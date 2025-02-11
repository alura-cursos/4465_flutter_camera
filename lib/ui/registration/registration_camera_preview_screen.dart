import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 750),
          child: (cameraController != null &&
                  cameraController!.value.isInitialized)
              ? AspectRatio(
                  aspectRatio: 1 / cameraController!.value.aspectRatio,
                  child: CameraPreview(
                    cameraController!,
                    child: Stack(
                      children: [
                        Image.asset(
                          "assets/images/guides/guide_selfie.png",
                          fit: BoxFit.fill,
                        ),
                        const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: Text(
                              "Alinhe o rosto com o guia\ne olhe pra câmera",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: IconButton(
                              onPressed: () => _onCaptureButtonClicked(),
                              iconSize: 48,
                              icon: const Icon(Icons.camera_alt),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text("Clique para capturar"),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
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

    switch (widget.cameraDescription.sensorOrientation) {
      case 0:
        cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);
        break;
      case 90:
        cameraController!
            .lockCaptureOrientation(DeviceOrientation.landscapeRight);
        break;
      case 180:
        cameraController!
            .lockCaptureOrientation(DeviceOrientation.portraitDown);
        break;
      case 270:
        cameraController!
            .lockCaptureOrientation(DeviceOrientation.landscapeLeft);
        break;
    }

    setState(() {});
  }

  _onCaptureButtonClicked() async {}
}
