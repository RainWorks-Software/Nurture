import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:ofd/android/lib.dart' as Android;
import 'package:iconify_flutter/iconify_flutter.dart';

final routerAndroid = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => const Android.HomePage()),
    GoRoute(path: "/scanned/:upc", name: "scanned", builder: (context, state) {
      final upcCode = state.pathParameters["upc"]; 
      if (upcCode == null) throw UnimplementedError("upc code must be set.");
      print("upcCode Route Searched: $upcCode");      

      return Scaffold(
        body: Android.FoodCard(upcCode: upcCode),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              onPressed: () {
                // TODO: Implement AI chat functionality
              },
              tooltip: "Ask an AI",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Iconify(Ph.robot),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: () => context.pop(),
              tooltip: "Back",
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Iconify(Ph.caret_left),
            ),
          ],
        ),
      );
    })
  ],
);

final routerIOS = GoRouter(routes: []);
