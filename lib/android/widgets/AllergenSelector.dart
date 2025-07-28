import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ph.dart';
import 'package:iconify_flutter_plus/icons/icon_park_outline.dart';
import 'package:iconify_flutter_plus/icons/carbon.dart';
import 'package:ofd/utils/allergen_store.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

const AllergenEnumToIcon = {
  AllergensTag.CELERY: IconParkOutline.vegetables,
  AllergensTag.CRUSTACEANS: IconParkOutline.crab,
  AllergensTag.EGGS: IconParkOutline.egg_one,
  AllergensTag.FISH: IconParkOutline.fish_one,
  AllergensTag.GLUTEN: IconParkOutline.bread,
  AllergensTag.LUPIN: IconParkOutline.geometric_flowers,
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
      for (var allergenString in allergenConfiguration.avoid) {
        final allergenEnum = stringToAllergen(allergenString);
        allergenStates[allergenEnum] = AllergenSelectionEnum.avoid;
      }
      for (var allergenString in allergenConfiguration.warn) {
        final allergenEnum = stringToAllergen(allergenString);
        allergenStates[allergenEnum] = AllergenSelectionEnum.warn;
      }
    });
  }

  late Future<void> stateFuture;

  Future<void> createNewAllergenConfigurationWithState(
    Map<AllergensTag, AllergenSelectionEnum> allergenStateArgument,
  ) async {
    final UserAllergenConfiguration newAllergenConfiguration =
        UserAllergenConfiguration(avoid: [], warn: []);
    for (var allergenState in allergenStateArgument.entries) {
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
    }

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
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Configure your allergens:", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8), 
                // Descriptor Legend
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendCircle(Colors.redAccent, "Avoid"),
                      const SizedBox(width: 12),
                      _buildLegendCircle(Colors.yellowAccent, "Warn"),
                      const SizedBox(width: 12),
                      _buildLegendCircle(Colors.grey, "Ignore"),
                    ],
                  ),
                ),

                // Allergen Chips
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: primaryAllergens.map((allergen) {
                        final currentState = allergenStates[allergen]!;
                        return ActionChip(
                          onPressed: () {
                            setState(() {
                              final currentIndex = currentState.index;
                              allergenStates[allergen] =
                                  AllergenSelectionEnum.values[(currentIndex +
                                          1) %
                                      AllergenSelectionEnum.values.length];
                            });
                          },
                          label: Text(
                            cleanupAllergenString(allergenToString(allergen)),
                            style: const TextStyle(fontSize: 14),
                          ),
                          avatar: Iconify(
                            AllergenEnumToIcon[allergen] ?? Ph.placeholder,
                            color: Colors.grey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color:
                                  AllergenSelectionEnumStyle[currentState] ??
                                  Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).chipTheme.backgroundColor?.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Save Button
                FilledButton.icon(
                  onPressed: () {
                    createNewAllergenConfigurationWithState(allergenStates);
                  },
                  icon: const Iconify(Ph.floppy_disk),
                  label: const Text("Save Changes"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Legend Indicator Builder
  Widget _buildLegendCircle(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
