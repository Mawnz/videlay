import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';

class FFmpegWrapper {
  Process? _captureWindows;
  FFmpegSession? _captureMobile;
  // Function to get available cameras and their resolutions
  Future<List<dynamic>> getAvailableCameras() async {
    if (Platform.isWindows) {
      return await _getAvailableCamerasWindows();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return await _getAvailableCamerasMobile();
    } else {
      throw UnsupportedError("Platform not supported");
    }
  }

  // Function to start capturing video from a selected camera
  Future<void> startCapture(String cameraName, DateTime dateTime,
      {String extension = 'avi'}) async {
    String timestamp = DateFormat('yyyyMMddTHHmmss').format(dateTime);
    String outputFile = 'output_$timestamp.$extension';

    if (Platform.isWindows) {
      await _startCaptureWindows(cameraName, outputFile);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _startCaptureMobile(cameraName, outputFile);
    } else {
      throw UnsupportedError("Platform not supported");
    }
  }

  // Function to start capturing video from a selected camera
  Future<void> stopCapture() async {
    if (Platform.isWindows) {
      _stopCaptureWindows();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _stopCaptureMobile();
    } else {
      throw UnsupportedError("Platform not supported");
    }
  }

  // Function to start streaming from a file, starting from a given timestamp
  Future<void> startStream(String filePath, int startTimeInSeconds) async {
    if (Platform.isWindows) {
      await _startStreamWindows(filePath, startTimeInSeconds);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await _startStreamMobile(filePath, startTimeInSeconds);
    } else {
      throw UnsupportedError("Platform not supported");
    }
  }

  List<String> parseFFMPEGOutputDevices(String stdout) {
    print(stdout);
    List<String> devices = [];
    for (String row in stdout.split("\n")) {
      if (row.indexOf('dshow') >= 0 && row.indexOf('video') >= 0) {
        String name = row
            .substring(row.indexOf(']') + 1, row.indexOf('(video)') - 1)
            .replaceAll('\"', '')
            .substring(1);
        devices.add(name);
      }
    }
    return devices;
  }

  // **Windows-specific implementation**
  Future<List<String>> _getAvailableCamerasWindows() async {
    final process = await Process.run(
        'ffmpeg.exe', ['-list_devices', 'true', '-f', 'dshow', '-i', 'dummy'],
        workingDirectory: 'windows/ffmpeg/bin', runInShell: true);
    return parseFFMPEGOutputDevices(process.stderr);
  }

  Future<void> _startCaptureWindows(
      String cameraName, String outputFile) async {
    _captureWindows = await Process.start(
      'ffmpeg',
      ['-y', '-f', 'dshow', '-i', 'video=$cameraName', outputFile],
      workingDirectory: 'windows/ffmpeg',
    );

    _captureWindows!.stdout.listen((data) {
      print(String.fromCharCodes(data)); // Capture and log the output
    });

    _captureWindows!.stderr.listen((data) {
      print("${String.fromCharCodes(data)}");
    });

    await _captureWindows!.exitCode;
    print('Capture started on Windows with output: $outputFile');
  }

  void _stopCaptureWindows() {
    if (_captureWindows != null) {
      _captureWindows!.kill();
    }
  }

  Future<void> _startStreamWindows(
      String filePath, int startTimeInSeconds) async {
    final process = await Process.start(
      'ffmpeg',
      [
        '-ss',
        '$startTimeInSeconds',
        '-i',
        filePath,
        '-c:v',
        'libx264',
        'output_stream.mp4'
      ],
      workingDirectory: 'windows/ffmpeg',
    );

    process.stdout.listen((data) {
      print(String.fromCharCodes(data)); // Capture and log the stream
    });

    process.stderr.listen((data) {
      print("Error: ${String.fromCharCodes(data)}");
    });

    await process.exitCode;
    print('Streaming started from file: $filePath');
  }

  // **Mobile-specific implementation**
  Future<List<CameraDescription>> _getAvailableCamerasMobile() async {
// Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    return cameras;
    // For Android/iOS, use FFmpeg-Kit to list available cameras (this part might need platform-specific implementation)
    // const command = "-f android -list_devices true";
    // FFmpegKit.execute(command).then((session) async {
    //   final returnCode = await session.getReturnCode();
    //   if (returnCode != null && returnCode.isValueSuccess()) {
    //     print("Camera list retrieved successfully.");
    //     // You can process the output to extract the camera names here
    //   } else {
    //     print("Failed to retrieve camera list.");
    //   }
    // });
  }

  Future<void> _startCaptureMobile(String cameraName, String outputFile) async {
    final command = "-f android -i $cameraName -c:v libx264 $outputFile";
    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode != null && returnCode.isValueSuccess()) {
        print('Capture started on mobile with output: $outputFile');
      } else {
        print("Capture failed on mobile.");
      }
    });
  }

  Future<void> _stopCaptureMobile() async {
    if (_captureMobile != null) {
      await _captureMobile!.cancel();
    }
  }

  Future<void> _startStreamMobile(
      String filePath, int startTimeInSeconds) async {
    final command =
        "-ss $startTimeInSeconds -i $filePath -c:v libx264 output_stream.mp4";
    FFmpegKit.execute(command).then((session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode != null && returnCode.isValueSuccess()) {
        print('Streaming started from file: $filePath');
      } else {
        print("Streaming failed on mobile.");
      }
    });
  }
}
