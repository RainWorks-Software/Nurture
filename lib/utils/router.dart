import 'dart:developer';

import 'package:go_router/go_router.dart';
import 'package:ofd/android/lib.dart' as Android;
import 'package:permission_handler/permission_handler.dart';

final routerAndroid = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => const Android.HomePage()),
    GoRoute(path: "/scanned/:upc", name: "scanned", builder: (context, state) {
      final upcCode = state.pathParameters["upc"]; 
      if (upcCode == null) throw UnimplementedError("upc code must be set.");
      log("upcCode Route Searched: $upcCode");      

      return Android.FoodCard(upcCode: upcCode);
    }),
    GoRoute(path: "/no-camera-access", name: "no_camera_access", builder: (context, state) => Android.NoPermissionPage(requiredPermission: Permission.camera)),
    GoRoute(path: "/me", name: "me", builder: (context, state) => const Android.MePage()),
  ],
);

final routerIOS = GoRouter(routes: []);
