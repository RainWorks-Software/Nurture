import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    detectionTimeoutMs: 1000,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
    autoStart: false,
  );

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.isCurrent == true) {
      _subscription ??= controller.barcodes.listen(_handleBarcode);
      log("returned to page, attempting to start camera again");
      unawaited(controller.start());
      setState(() {
        hasScannedBarcode = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Start listening to lifecycle changes.
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    _subscription = controller.barcodes.listen(_handleBarcode);

    // Finally, start the scanner itself.
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!controller.value.hasCameraPermission) {
      context.goNamed("no_camera_access");
      log("No camera permission granted. Going to show permission screen.");
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

  @override
  Future<void> dispose() async {
    // Stop listening to lifecycle changes.
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(_subscription?.cancel());
    _subscription = null;
    // Dispose the widget itself.
    super.dispose();
    // Finally, dispose of the controller.
    await controller.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (!mounted || hasScannedBarcode) return;
    final barcodeData = capture.barcodes.first.rawValue;

    if (barcodeData == null) return;

    setState(() {
      hasScannedBarcode = true;
    });

    context.pushNamed("scanned", pathParameters: {"upc": barcodeData});
    await controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(onDetect: _handleBarcode, controller: controller);
  }
}
