import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission() async {
  final status = await Permission.camera.request();
  return status.isGranted;
}

class CameraSelector extends StatefulWidget {
  final Function(CameraDescription, ResolutionPreset, int) onCameraSelected;

  const CameraSelector({Key? key, required this.onCameraSelected})
      : super(key: key);

  @override
  _CameraSelectorState createState() => _CameraSelectorState();
}

class _CameraSelectorState extends State<CameraSelector> {
  List<CameraDescription>? _cameras;
  CameraDescription? _selectedCamera;
  ResolutionPreset _selectedResolution = ResolutionPreset.medium;
  int _selectedFramerate = 30;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    if (!await requestCameraPermission()) {
      setState(() {
        _cameras = [];
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      setState(() {
        _cameras = cameras;
        if (_cameras != null && _cameras!.isNotEmpty) {
          _selectedCamera = _cameras!.first;
          widget.onCameraSelected(
              _selectedCamera!, _selectedResolution, _selectedFramerate);
        }
      });
    } catch (e) {
      debugPrint("Error initializing cameras: $e");
      setState(() {
        _cameras = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_cameras!.isEmpty) {
      return const Center(
        child: Text("No cameras found."),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<CameraDescription>(
          value: _selectedCamera,
          hint: const Text("Select Camera"),
          items: _cameras!.map((camera) {
            return DropdownMenuItem(
              value: camera,
              child: Text(camera.name),
            );
          }).toList(),
          onChanged: (camera) {
            setState(() {
              _selectedCamera = camera;
            });
            widget.onCameraSelected(
                _selectedCamera!, _selectedResolution, _selectedFramerate);
          },
        ),
        DropdownButton<ResolutionPreset>(
          value: _selectedResolution,
          hint: const Text("Select Resolution"),
          items: ResolutionPreset.values.map((resolution) {
            return DropdownMenuItem(
              value: resolution,
              child: Text(resolution.toString().split('.').last),
            );
          }).toList(),
          onChanged: (resolution) {
            setState(() {
              _selectedResolution = resolution!;
            });
            widget.onCameraSelected(
                _selectedCamera!, _selectedResolution, _selectedFramerate);
          },
        ),
        DropdownButton<int>(
          value: _selectedFramerate,
          hint: const Text("Select Framerate"),
          items: [15, 30, 60].map((fps) {
            return DropdownMenuItem(
              value: fps,
              child: Text("$fps FPS"),
            );
          }).toList(),
          onChanged: (fps) {
            setState(() {
              _selectedFramerate = fps!;
            });
            widget.onCameraSelected(
                _selectedCamera!, _selectedResolution, _selectedFramerate);
          },
        ),
      ],
    );
  }
}
