import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ph.dart';
import 'package:ofd/utils/barcode.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(child: SelfBarcodeImplementation()),
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeData().primaryColor,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                 Tooltip(
                  preferBelow: false,
                  message: "Me",
                  child: IconButton(onPressed: () {
                    context.pushNamed("me");
                  }, icon: const Iconify(Ph.user)),
                 ),
                 Tooltip(
                  preferBelow: false,
                  message: "Settings",
                  child: IconButton(onPressed: () {}, icon: const Iconify(Ph.gear))
                 )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
