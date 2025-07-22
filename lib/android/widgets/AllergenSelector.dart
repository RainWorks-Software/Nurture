import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/icon_park_outline.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:ofd/utils/allergen_store.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

const AllergenEnumToIcon = {
  AllergensTag.CELERY: IconParkOutline.vegetables,
  AllergensTag.CRUSTACEANS: IconParkOutline.crab,
  AllergensTag.EGGS: IconParkOutline.egg_one,
  AllergensTag.FISH: IconParkOutline.fish_one,
  AllergensTag.GLUTEN: Ph.placeholder,
  AllergensTag.LUPIN: Ph.placeholder,
  AllergensTag.MILK: IconParkOutline.milk,
  AllergensTag.MOLLUSCS: Ph.placeholder,
  AllergensTag.MUSTARD: Ph.placeholder,
  AllergensTag.NUTS: IconParkOutline.nut,
  AllergensTag.PEANUTS: Ph.placeholder,
  AllergensTag.SESAME_SEEDS: Ph.placeholder,
  AllergensTag.SOYBEANS: Ph.placeholder,
};

enum AllergenSelectionEnum { ignore, warn, avoid }

final AllergenSelectionEnumStyle = {
  AllergenSelectionEnum.ignore: Colors.grey,
  AllergenSelectionEnum.warn: Colors.yellowAccent,
  AllergenSelectionEnum.avoid: Colors.redAccent,
};

class AllergenSelectorChips extends StatefulWidget {
  const AllergenSelectorChips({super.key});

  @override
  State<AllergenSelectorChips> createState() => _AllergenSelectorChipsState();
}

class _AllergenSelectorChipsState extends State<AllergenSelectorChips> {
  Map<AllergensTag, AllergenSelectionEnum> allergenStates = Map.fromIterables(
    AllergensTag.values,
    List.filled(AllergensTag.values.length, AllergenSelectionEnum.ignore),
  );

  Future<void> setStateFromFileConfiguration() async {
    final UserAllergenConfiguration allergenConfiguration =
        await getAllergenConfigurationObject();
    if (!mounted) return;

    setState(() {
      allergenConfiguration.avoid.forEach((allergenString) {
        final allergenEnum = stringToAllergen(allergenString);
        allergenStates[allergenEnum] = AllergenSelectionEnum.avoid;
      });
      allergenConfiguration.warn.forEach((allergenString) {
        final allergenEnum = stringToAllergen(allergenString);
        allergenStates[allergenEnum] = AllergenSelectionEnum.warn;
      });
    });
  }

  late Future<void> stateFuture;

  Future<void> createNewAllergenConfigurationWithState(
    Map<AllergensTag, AllergenSelectionEnum> allergenStateArgument,
  ) async {
    final UserAllergenConfiguration newAllergenConfiguration =
        UserAllergenConfiguration(avoid: [], warn: []);
    allergenStateArgument.entries.forEach((allergenState) {
      final allergenString = allergenToString(allergenState.key);
      final allergenSelectionEnum = allergenState.value;

      switch (allergenSelectionEnum) {
        case AllergenSelectionEnum.avoid:
          newAllergenConfiguration.avoid.add(allergenString);
        case AllergenSelectionEnum.warn:
          newAllergenConfiguration.warn.add(allergenString);
        default:
          break;
      }
    });

    await writeAllergenConfigurationObject(newAllergenConfiguration);

    Fluttertoast.showToast(msg: "Saved", gravity: ToastGravity.BOTTOM);
  }

  @override
  void initState() {
    super.initState();
    stateFuture = setStateFromFileConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: stateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: primaryAllergens
                    .map(
                      (allergen) => ActionChip(
                        onPressed: () {
                          setState(() {
                            final currentIndex =
                                allergenStates[allergen]?.index;
                            if (currentIndex == null) return;
                            allergenStates[allergen] =
                                AllergenSelectionEnum.values[(currentIndex +
                                        1) %
                                    (AllergenSelectionEnum.values.length)];
                          });
                        },
                        label: Text(
                          cleanupAllergenString(allergenToString(allergen)),
                        ),
                        avatar: Iconify(
                          AllergenEnumToIcon[allergen] ?? Ph.placeholder,
                          color: ThemeData().primaryColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            width: 1,
                            color:
                                AllergenSelectionEnumStyle[allergenStates[allergen]] ??
                                Colors.transparent,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              FilledButton(
                onPressed: () {
                  createNewAllergenConfigurationWithState(allergenStates);
                },
                child: const Text("Save Changes"),
              ),
            ],
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
