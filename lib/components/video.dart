import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:videlay_app/components/preview.dart';
import './camera.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key? key}) : super(key: key);
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final FFmpegWrapper _camera = FFmpegWrapper();
  String _deviceName = "";
  List<String> _devicesWindows = [];
  List<CameraDescription> _devicesMobile = [];
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _initializeDevices();
  }

  Future<void> _initializeDevices() async {
    // get devices
    var devices = await _camera.getAvailableCameras();
    setState(() {
      if (Platform.isWindows) {
        _devicesWindows = devices as List<String>;
      } else {
        _devicesMobile = devices as List<CameraDescription>;
      }
    });
  }

  void _startVideoStream() {
    if (_deviceName.isNotEmpty) {
      _camera.startCapture(_deviceName, DateTime.now());
      setState(() {
        _started = true;
      });
    }
  }

  void _stopVideoStream() {
    if (_deviceName.isNotEmpty) {
      _camera.stopCapture();
      setState(() {
        _started = false;
      });
    }
  }

  @override
  void dispose() {
    // todo release camera
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Camera capture")),
      body: Platform.isWindows
          ? Center(
              child: Column(
              children: [
                // Start capture
                (_started
                    ? Center(
                        child: TextButton(
                            onPressed: _stopVideoStream,
                            child: const Text("Stop")),
                      )
                    : Center(
                        child: TextButton(
                            onPressed: _startVideoStream,
                            child: const Text("Start")))),
                // Select device
                (_devicesWindows.length > 0
                    ? DropdownMenu<String>(
                        initialSelection: _devicesWindows.first,
                        onSelected: (String? val) {
                          if (val != null && val.isNotEmpty) {
                            setState(() {
                              _deviceName = val;
                            });
                          }
                        },
                        dropdownMenuEntries: _devicesWindows
                            .map<DropdownMenuEntry<String>>((String val) {
                          return DropdownMenuEntry<String>(
                              value: val, label: val);
                        }).toList(),
                      )
                    : const Center(child: Text("Loading devices..."))),
              ],
            ))
          : (
              _devicesMobile.length > 0
                  ? Center(
                      child: PreviewView(camera: _devicesMobile.first),
                    )
                  : Center(
                      child: Text("Loading devices..."),
                    )
            ),
    );
  }
}
