import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ofd/utils/barcode.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SelfBarcodeImplementation(),
      )
    );
  }
}