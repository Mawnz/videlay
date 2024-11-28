import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  _PreviewViewState createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _startedStream = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // get devices
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.camera,
        // Define the resolution to use.
        ResolutionPreset.high,
        fps: 60);

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // todo release camera
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;
            // Attempt to take a picture and get the file `image`
            // where it was saved.
            //final image = await _controller.takePicture();
            //if (!context.mounted) return;
            if (_startedStream) {
              _controller.stopImageStream();
              setState(() {
                _startedStream = false;
              });
            } else {
              _controller.startImageStream((image) => {
                // save images
              });
              setState(() {
                _startedStream = true;
              });
            }
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
