import 'package:openfoodfacts/openfoodfacts.dart';

void initFoodFactsConfiguration() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(name: "Nurture Assist", version: "0.0.1", comment: "li@lizj.xyz");
  OpenFoodAPIConfiguration.globalLanguages = <OpenFoodFactsLanguage>[
    OpenFoodFactsLanguage.ENGLISH,
  ];
}