import "dart:async";
import "dart:convert";
import "dart:io";

import "package:openfoodfacts/openfoodfacts.dart";
import "package:path_provider/path_provider.dart";

const ConfiguraionFileName = "user_allergen.json";

class UserAllergenConfiguration {
  List<String> avoid;
  List<String> warn;
  String name;

  UserAllergenConfiguration({required this.avoid, required this.warn, required this.name});

  get jsonEncoding {
    return jsonEncode(this);
  } 
}

class NoAllergenConfigurationPresent implements Exception {
  NoAllergenConfigurationPresent();
}

final defaultAllergenConfiguration = UserAllergenConfiguration(avoid: [""], warn: [""], name: "John Doe");

final List<AllergensTag> primaryAllergens = [
  ...AllergensTag.values
];

Future<String> getConfigurationFolder() async {
  final dir = await getApplicationDocumentsDirectory();

  return dir.path;
}

Future<UserAllergenConfiguration> getAllergenConfigurationObject() async {
  final configurationDirectory = await getConfigurationFolder();
  final finalPath = "$configurationDirectory/$ConfiguraionFileName";
  final configFile = File(finalPath);
  if (!configFile.existsSync()) {
    // this means a new one has to be created
    throw NoAllergenConfigurationPresent();
  }

  // attempt to read file
  final decodedData = await jsonDecode(configFile.readAsStringSync());

  return decodedData as UserAllergenConfiguration;
}

void initAllergenConfiguration() {
  
}