import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import "package:permission_handler/permission_handler.dart";

class NoPermissionPage extends StatefulWidget {
  Permission requiredPermission;

  NoPermissionPage({super.key, required this.requiredPermission});

  @override
  State<NoPermissionPage> createState() => _NoPermissionPageState();
}

class _NoPermissionPageState extends State<NoPermissionPage> {
  bool grantedPermission = false;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      bool permGranted = await widget.requiredPermission.isGranted;
      setState(() {
        grantedPermission = permGranted;
      });
      return !permGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "The permission ${widget.requiredPermission.toString()} was not granted. This permission is required for the functioning of the app. Please change it in the settings",
            ),
            Text(
              "Permission has been: ${grantedPermission ? 'Granted' : 'Denied'}",
            ),
            MaterialButton(
              onPressed: () {
                unawaited(openAppSettings());
              },
              child: const Text("Open Settings"),
            ),
            if (grantedPermission)
              MaterialButton(
                onPressed: () {
                  context.go("/");
                },
                child: const Text("Return"),
              ),
          ],
        ),
      ),
    );
  }
}
