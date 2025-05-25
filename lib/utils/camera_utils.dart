import 'package:camera/camera.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class NoRearCameraError extends Error {}

Future<CameraDescription> returnRearFacingCamera() async {
  for (final camera in await availableCameras()) {
    if (camera.lensDirection == CameraLensDirection.back) {
      return camera;
    }
  }
  throw NoRearCameraError;
}

CameraController createCameraController(CameraDescription camera, {ResolutionPreset cameraQuality = ResolutionPreset.high}) {
  final controller = CameraController(camera, cameraQuality, enableAudio: false);

  return controller;
}

MobileScannerController createBarcodeController() {
  final MobileScannerController controller = MobileScannerController(

  );

  controller.
}

void main() async {
  var rear = await returnRearFacingCamera();

  var controller = CameraController(rear, ResolutionPreset.high, enableAudio: false);
     
}