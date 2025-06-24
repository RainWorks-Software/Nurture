import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ofd/android/lib.dart' as android;

class SelfBarcodeImplementation extends StatefulWidget {
  const SelfBarcodeImplementation({super.key});

  @override
  State<SelfBarcodeImplementation> createState() =>
      SelfBarcodeImplementationState();
}

class SelfBarcodeImplementationState extends State<SelfBarcodeImplementation>
    with WidgetsBindingObserver {
  bool hasScannedBarcode = false;
  StreamSubscription<Object?>? _subscription;

  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 250,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    autoStart: false,
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        _subscription = controller.barcodes.listen(_handleBarcode);

        unawaited(controller.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!mounted || hasScannedBarcode) return;
    final barcodeData = capture.barcodes.first.rawValue;

    if (barcodeData == null) return;

    if (Platform.isAndroid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              android.ScannedBarcodePage(barcodeData: barcodeData),
        ),
      );
      setState(() {
        hasScannedBarcode = true;
      });
    } else if (Platform.isIOS) {
    } else {
      throw "unsupported platform";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(onDetect: _handleBarcode, controller: controller),
      ],
    );
  }
}
