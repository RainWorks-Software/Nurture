import 'package:flutter/material.dart';

class ScannedBarcodePage extends StatefulWidget {
  final String barcodeData; 
  const ScannedBarcodePage({super.key, required this.barcodeData});

  @override
  State<ScannedBarcodePage> createState() => _ScannedBarcodePageState();
}

class _ScannedBarcodePageState extends State<ScannedBarcodePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(widget.barcodeData)
        ]
      )
    );
  }
}