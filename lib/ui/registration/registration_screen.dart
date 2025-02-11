import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_banco_douro/ui/registration/registration_camera_preview_screen.dart';
import 'package:flutter_banco_douro/ui/registration/widgets/denied_camera_permission_dialog.dart';
import 'package:flutter_banco_douro/ui/registration/widgets/request_camera_permission_dialog.dart';
import 'package:flutter_banco_douro/utils/registration_capture_types.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'view_model/registration_viewmodel.dart';
import 'widgets/form_field_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDocumentType = "CNH"; // Valor inicial do dropdown

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegistrationViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro"),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              /// CAMPOS DO FORMULÁRIO
              const FormFieldWidget(label: "Nome"),
              const FormFieldWidget(label: "Sobrenome"),
              const FormFieldWidget(label: "Data de Nascimento"),
              const FormFieldWidget(label: "Endereço"),
              const FormFieldWidget(label: "Cidade"),
              const FormFieldWidget(label: "Estado"),
              const FormFieldWidget(label: "CPF"),

              /// DROPDOWN DE TIPO DE DOCUMENTO
              const SizedBox(height: 16),
              const Text("Tipo de documento"),
              DropdownButton<String>(
                value: _selectedDocumentType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "RG", child: Text("RG")),
                  DropdownMenuItem(value: "CNH", child: Text("CNH")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDocumentType = value!;
                  });
                },
              ),
              const FormFieldWidget(label: "Órgão expedidor"),

              const SizedBox(height: 16),

              /// FOTO DO DOCUMENTO
              _buildImageSection(
                label: "Fotografar documento",
                onTap: () => _handleCameraClicked(context, viewModel),
                icon: Icons.badge,
                isDocument: true,
              ),
              const SizedBox(height: 16),

              /// FOTO DO ROSTO
              _buildImageSection(
                label: "Fotografar rosto",
                onTap: () => _handleCameraClicked(
                  context,
                  viewModel,
                  isDocument: false,
                ),
                isDocument: false,
                icon: Icons.face,
              ),

              const SizedBox(height: 24),

              /// BOTÕES DE AÇÃO
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: viewModel.hasAllFilled
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                // TODO: processar os dados aqui
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text("Cadastrar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seção para exibir as imagens tiradas (Documento ou Rosto)
  Widget _buildImageSection({
    required String label,
    required VoidCallback onTap,
    required IconData icon,
    required bool isDocument,
  }) {
    final viewModel = Provider.of<RegistrationViewModel>(context);
    return Column(
      spacing: 8,
      children: [
        Container(
          width: 150,
          height: 200,
          color: Colors.grey.shade200,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 750),
            child: (!isDocument && viewModel.imageSelfie != null)
                ? Image.memory(viewModel.imageSelfie!)
                : (isDocument && viewModel.imageDocument != null)
                    ? Image.memory(viewModel.imageDocument!)
                    : Icon(
                        icon,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.camera_alt),
              label: Text(label),
            ),
          ],
        ),
      ],
    );
  }

  /// Lógica para solicitar permissão da câmera
  void _handleCameraClicked(
    BuildContext context,
    RegistrationViewModel viewModel, {
    bool isDocument = true,
  }) async {
    List<CameraDescription> listCameras = await availableCameras();
    print(listCameras.toString().replaceAll("),", "),\n"));

    PermissionStatus cameraPermissionStatus = await Permission.camera.status;

    if (cameraPermissionStatus == PermissionStatus.denied) {
      if (!context.mounted) return;
      PermissionStatus? newStatus =
          await showRequestCameraPermissionDialog(context);

      if (newStatus != null) {
        cameraPermissionStatus = newStatus;
      }
    }
    print(cameraPermissionStatus);

    if (cameraPermissionStatus != PermissionStatus.denied &&
        cameraPermissionStatus != PermissionStatus.permanentlyDenied) {
      if (!context.mounted) return;
      RegistrationCaptureTypes captureType = RegistrationCaptureTypes.selfie;
      int indexCameraDescription = listCameras.indexWhere(
        (element) => element.lensDirection == CameraLensDirection.front,
      );

      if (isDocument) {
        if (_selectedDocumentType == "CNH") {
          captureType = RegistrationCaptureTypes.cnh;
        }

        if (_selectedDocumentType == "RG") {
          captureType = RegistrationCaptureTypes.rg;
        }

        indexCameraDescription = listCameras.indexWhere(
          (element) => element.lensDirection == CameraLensDirection.back,
        );
      }

      Uint8List? resultImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationCameraPreviewScreen(
            cameraDescription: listCameras[indexCameraDescription],
            captureType: captureType,
          ),
        ),
      );
      if (resultImage != null) {
        if (isDocument) {
          viewModel.saveDocumentImage(resultImage);
        } else {
          viewModel.saveSelfieImage(resultImage);
        }
      }
    } else if (cameraPermissionStatus == PermissionStatus.permanentlyDenied) {
      if (!context.mounted) return;
      await showDeniedCameraPermissionDialog(context);
    }
  }
}
