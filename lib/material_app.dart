import 'package:flutter/material.dart';
import 'package:ofd/utils/router.dart';

class OFDMaterial extends StatelessWidget {
  const OFDMaterial({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      darkTheme: ThemeData.dark(),
      routerConfig: routerAndroid,
    );
  }
}
