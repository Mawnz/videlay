import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import './camera.dart';

class CameraCapture extends StatefulWidget {
  @override
  _CameraCaptureState createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  CameraController? _controller;
  CameraDescription? _selectedCamera;
  ResolutionPreset _selectedResolution = ResolutionPreset.medium;
  int _selectedFramerate = 30;

  void _onCameraSelected(
      CameraDescription camera, ResolutionPreset resolution, int framerate) {
    _selectedCamera = camera;
    _selectedResolution = resolution;
    _selectedFramerate = framerate;
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (_selectedCamera == null) return;

    _controller = CameraController(
      _selectedCamera!,
      _selectedResolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera Capture"),
      ),
      body: Column(
        children: [
          CameraSelector(
            onCameraSelected: _onCameraSelected,
          ),
          Expanded(
            child: _controller != null && _controller!.value.isInitialized
                ? CameraPreview(_controller!)
                : const Center(child: Text("Select a camera to start preview")),
          ),
          ElevatedButton(
            onPressed: _controller != null && _controller!.value.isInitialized
                ? () async {
                    // Future feature: Start recording
                  }
                : null,
            child: const Text("Start Capturing"),
          ),
        ],
      ),
    );
  }
}
