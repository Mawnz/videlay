import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PreviewView extends StatefulWidget {
  const PreviewView({super.key, required this.camera});

  final CameraDescription camera;

  @override
  _PreviewViewState createState() => _PreviewViewState();
}

class _PreviewViewState extends State<PreviewView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _startedStream = false;

  StreamController<CameraImage>? _imageStreamController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
      fps: 60,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _imageStreamController?.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processStream() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/output.mp4';

    final process = await Process.start(
      'ffmpeg',
      [
        '-y', // Overwrite output
        '-f', 'rawvideo', // Input is raw video
        '-pixel_format', 'nv21', // CameraImage format
        '-video_size', '1920x1080', // Update with your camera's resolution
        '-framerate', '60', // Match desired fps
        '-i', '-', // Read from stdin
        '-c:v', 'libx264', // Encode as H.264
        filePath,
      ],
    );

    _imageStreamController = StreamController<CameraImage>();
    _imageStreamController!.stream.listen((CameraImage image) {
      // Write raw image data to FFmpeg process
      process.stdin.add(image.planes[0].bytes); // Use planes as needed
    });

    process.stdout.listen((_) {}); // Handle FFmpeg logs if necessary
    process.stderr.listen((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _initializeControllerFuture;

          if (_startedStream) {
            await _controller.stopImageStream();
            setState(() => _startedStream = false);
            _imageStreamController?.close();
          } else {
            _processStream();
            _controller.startImageStream((CameraImage image) {
              _imageStreamController?.add(image);
            });
            setState(() => _startedStream = true);
          }
        },
        child: Icon(_startedStream ? Icons.stop : Icons.camera_alt),
      ),
    );
  }
}
