import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ofd/utils/barcode.dart';

class OFDMaterial extends StatelessWidget {
  const OFDMaterial({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("test")
        ),
        body: Stack(
          children: [
            SelfBarcodeImplementation() 
          ],
        ),
      ),
    );
  }
}
