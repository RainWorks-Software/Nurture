import "dart:async";
import "dart:convert";
import "dart:io";

import "package:openfoodfacts/openfoodfacts.dart";
import "package:path_provider/path_provider.dart";

const ConfigurationFileName = "user_allergen.json";

class UserAllergenConfiguration {
  List<String> avoid;
  List<String> warn;

  UserAllergenConfiguration({
    required this.avoid,
    required this.warn,
  });

  Map<String, dynamic> toJson() => {
    'avoid': avoid,
    'warn': warn,
  };

  factory UserAllergenConfiguration.fromJson(Map<String, dynamic> json) {
    return UserAllergenConfiguration(
      avoid: List<String>.from(json['avoid']),
      warn: List<String>.from(json['warn']),
    );
  }

  String get jsonEncoding => jsonEncode(toJson());
}


class NoAllergenConfigurationPresent implements Exception {
  NoAllergenConfigurationPresent();
}

final defaultAllergenConfiguration = UserAllergenConfiguration(
  avoid: [AllergensTag.NUTS.toString(), AllergensTag.MILK.toString()],
  warn: [AllergensTag.FISH.toString()],
);

final List<AllergensTag> primaryAllergens = [...AllergensTag.values];

String allergenToString(AllergensTag allergen) => allergen.toString();
AllergensTag stringToAllergen(String allergenString) =>
    AllergensTag.values.firstWhere((e) => e.toString() == allergenString);

Future<String> getConfigurationFolder() async {
  final dir = await getApplicationDocumentsDirectory();

  return dir.path;
}

Future<UserAllergenConfiguration> getAllergenConfigurationObject() async {
  final configurationDirectory = await getConfigurationFolder();
  final finalPath = "$configurationDirectory/$ConfigurationFileName";
  final configFile = File(finalPath);

  print("configurationPath: $finalPath");

  if (!configFile.existsSync()) {
    // this means a new one has to be created
    throw NoAllergenConfigurationPresent();
  }

  // attempt to read file
  final jsonString = await configFile.readAsString();
  final decodedMap = jsonDecode(jsonString);
  return UserAllergenConfiguration.fromJson(decodedMap);
}

Future<void> writeAllergenConfigurationObject(
  UserAllergenConfiguration configuration,
) async {
  final jsonEncoding = configuration.jsonEncoding;
  final configurationDirectory = await getConfigurationFolder();
  final finalPath = "$configurationDirectory/$ConfigurationFileName";
  final configFile = File(finalPath);

  configFile.writeAsStringSync(jsonEncoding);
}

Future<void> initAllergenConfiguration() async {
  try {
    await getAllergenConfigurationObject();
  } on NoAllergenConfigurationPresent {
    final jsonEncoding = defaultAllergenConfiguration.jsonEncoding;
    final configurationDirectory = await getConfigurationFolder();
    final finalPath = "$configurationDirectory/$ConfigurationFileName";
    final configFile = File(finalPath);

    configFile.writeAsStringSync(jsonEncoding);
  }
}
