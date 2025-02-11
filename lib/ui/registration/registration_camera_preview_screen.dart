import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_banco_douro/utils/registration_capture_types.dart';

class RegistrationCameraPreviewScreen extends StatefulWidget {
  final CameraDescription cameraDescription;
  final RegistrationCaptureTypes captureType;
  const RegistrationCameraPreviewScreen({
    super.key,
    required this.cameraDescription,
    required this.captureType,
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
      backgroundColor: _isSelfie ? Colors.white : Colors.black,
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
                          _getImageByType,
                          fit: BoxFit.fill,
                        ),
                        Visibility(
                          visible: _isSelfie,
                          child: const Align(
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
                        ),
                        Visibility(
                          visible: _isSelfie,
                          child: Align(
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
                        ),
                        Visibility(
                          visible: _isSelfie,
                          child: const Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Text("Clique para capturar"),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_isSelfie,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Transform.rotate(
                                angle: pi / 2,
                                child: IconButton.filled(
                                  onPressed: () => _onCaptureButtonClicked(),
                                  iconSize: 48,
                                  icon: const Icon(Icons.camera_alt),
                                ),
                              ),
                            ),
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

  String get _getImageByType {
    switch (widget.captureType) {
      case RegistrationCaptureTypes.selfie:
        return "assets/images/guides/guide_selfie.png";
      case RegistrationCaptureTypes.cnh:
        return "assets/images/guides/guide_cnh.png";
      case RegistrationCaptureTypes.rg:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  bool get _isSelfie {
    return widget.captureType == RegistrationCaptureTypes.selfie;
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
