import 'package:flutter/material.dart';

class OFDMaterial extends StatelessWidget {
  const OFDMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("This is some text"),
              MaterialButton(
                onPressed: () {
                  print("button clicked");
                },
                child: const Text("This is a button"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
