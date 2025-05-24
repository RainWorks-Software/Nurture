import 'package:flutter/cupertino.dart';

class OFDCupertino extends StatelessWidget {
  const OFDCupertino({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(),
      home: CupertinoPageScaffold(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("This is some text"),
              CupertinoButton.filled(onPressed: () {
                print("button clicked");
              }, child: const Text("This is a button"))
            ]
          ),
        ),
      ),
    );
  }
}
