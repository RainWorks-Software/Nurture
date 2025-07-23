import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:ofd/utils/allergen_store.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductSummaryWidget extends StatefulWidget {
  final Product productData;

  const ProductSummaryWidget({super.key, required this.productData});

  @override
  State<ProductSummaryWidget> createState() => _ProductSummaryWidgetState();
}

class _ProductSummaryWidgetState extends State<ProductSummaryWidget> {
  late Future<UserAllergenConfiguration> allergenConfiguration;

  @override
  void initState() {
    super.initState();

    allergenConfiguration = getAllergenConfigurationObject();
  }

  @override
  Widget build(BuildContext context) {
    final String productName =
        widget.productData.productName ??
        widget.productData.productNameInLanguages?[OpenFoodFactsLanguage
            .ENGLISH] ??
        'Unknown Product';
    final String brand = widget.productData.brands ?? 'Unknown Brand';
    final String country =
        widget.productData.countries ??
        widget.productData.productNameInLanguages?[OpenFoodFactsLanguage
            .ENGLISH] ??
        'Unknown Region';
    final String? imageUrl = widget.productData.imageFrontUrl;

    final Allergens? allergens = widget.productData.allergens;
    final List<AllergensTag> allergensConverted = [];
    if (allergens?.names != null) {
      for (final allergenName in allergens!.names) {
        print("attempting to convert $allergenName");

        try {
          allergensConverted.add(looseStringToAllergen(allergenName));
        } catch (e) {
          // Log allergens that can't be parsed. This happens when the
          // openfoodfacts API returns an allergen that is not in the local
          // AllergensTag enum.
          print('Could not parse allergen: "$allergenName"');
        }
      }
    }

    List<AllergensTag> avoidConflicts(
      List<AllergensTag> userPreference,
      List<AllergensTag> productAllergens,
    ) {
      return userPreference
          .toSet()
          .intersection(productAllergens.toSet())
          .toList();
    }

    List<AllergensTag> warnConflicts(
      List<AllergensTag> userPreference,
      List<AllergensTag> productAllergens,
    ) {
      return userPreference
          .toSet()
          .intersection(productAllergens.toSet())
          .toList();
    }

    print("Allergens: ${allergensConverted.toString()}");

    return FutureBuilder(
      future: allergenConfiguration,
      builder: (context, snapshot) {
        final avoidedAllergens = avoidConflicts(
          snapshot.data?.avoid
                  .map((allergenString) => stringToAllergen(allergenString))
                  .toList() ??
              [],
          allergensConverted,
        );

        final warnedAllergens = warnConflicts(
          snapshot.data?.warn
                  .map((allergenString) => stringToAllergen(allergenString))
                  .toList() ??
              [],
          allergensConverted,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Column(
              children: [
                Text(productName),
                Container(
                  child: (allergensConverted.isNotEmpty)
                      ? Column(
                          children: allergensConverted
                              .map((a) => Text(a.toString()))
                              .toList(),
                        )
                      : Text(
                          "No allergens were found. Please double check with package labeling or a trusted source.",
                        ),
                ),
                if (allergensConverted.isNotEmpty &&
                    avoidedAllergens.isNotEmpty)
                  Column(
                    children: [
                      Text("These allergens conflict with your preferences:"),
                      ...avoidedAllergens.map((a) => Text(a.toString())),
                    ],
                  ),
                if (allergensConverted.isNotEmpty && warnedAllergens.isNotEmpty)
                  Column(
                    children: [
                      Text("These allergens are warned with your preferences:"),
                      ...warnedAllergens.map((a) => Text(a.toString())),
                    ],
                  ),
              ],
            ),
          );
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class FoodCard extends StatefulWidget {
  final String upcCode;
  const FoodCard({super.key, required this.upcCode});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  Future<ProductResultV3> getProductInformation() async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(
      widget.upcCode,
      version: ProductQueryVersion.v3,
    );
    ProductResultV3 foodDetails = await OpenFoodAPIClient.getProductV3(
      configuration,
    );

    return foodDetails;
  }

  late Future<ProductResultV3> foodData;

  @override
  void initState() {
    super.initState();
    foodData = getProductInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: foodData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            log(
              snapshot.data?.product?.toJson().toString() ??
                  "no product information",
            );

            if (snapshot.data!.product == null) {
              return Center(child: const Text("no product information"));
            }

            return ProductSummaryWidget(productData: snapshot.data!.product!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: "Ask an AI",
            preferBelow: false,
            child: FloatingActionButton.small(
              heroTag: "ai_btn",
              onPressed: () {
                // TODO: Implement AI chat functionality
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Iconify(Ph.robot),
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: "Back",
            preferBelow: false,
            child: FloatingActionButton(
              heroTag: "back_btn",
              onPressed: () => context.pop(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Iconify(Ph.caret_left),
            ),
          ),
        ],
      ),
    );
  }
}
