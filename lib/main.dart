import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:ofd/utils/allergen_store.dart";
import "package:ofd/utils/openfoodfacts.dart";

import "./material_app.dart";
import "./cupertino_app.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initFoodFactsConfiguration();
  await initAllergenConfiguration();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return OFDMaterial(); 
    } else if (Platform.isIOS) {
      return OFDCupertino(); 
    } else {
      throw UnimplementedError();
    }
  }
}