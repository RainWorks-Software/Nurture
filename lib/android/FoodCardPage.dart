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
        try {
          allergensConverted.add(looseStringToAllergen(allergenName));
        } catch (e) {
          print('Could not parse allergen: "$allergenName"');
        }
      }
    }

    List<AllergensTag> filterMatches(
      List<AllergensTag> userList,
      List<AllergensTag> productList,
    ) {
      return userList.toSet().intersection(productList.toSet()).toList();
    }

    return FutureBuilder(
      future: allergenConfiguration,
      builder: (context, snapshot) {
        final avoidedAllergens = filterMatches(
          snapshot.data?.avoid.map(stringToAllergen).toList() ?? [],
          allergensConverted,
        );
        final warnedAllergens = filterMatches(
          snapshot.data?.warn.map(stringToAllergen).toList() ?? [],
          allergensConverted,
        );

        if (snapshot.connectionState == ConnectionState.done) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  if (imageUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(imageUrl, height: 160),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    productName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '$brand — $country',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Divider(),

                  // Allergens Section
                  Text(
                    "Detected Allergens",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (allergensConverted.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allergensConverted
                          .map(
                            (a) => Chip(
                              label: Text(cleanupAllergenString(a.toString())),
                              avatar: Iconify(
                                Ph.warning_circle_bold,
                                size: 18,
                                color: Colors.grey,
                              ),
                              // backgroundColor: Colors.orange[50],
                              side: BorderSide(color: Colors.grey),
                            ),
                          )
                          .toList(),
                    )
                  else
                    Text(
                      "No allergens detected. Please double-check with the product label or a trusted source.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  const SizedBox(height: 16),

                  // Avoided Allergens
                  if (avoidedAllergens.isNotEmpty) ...[
                    Text(
                      "⚠️ Avoid — Conflicts with your preferences",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.red[800]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: avoidedAllergens
                          .map(
                            (a) => Chip(
                              label: Text(cleanupAllergenString(a.toString())),
                              avatar: Iconify(
                                Ph.x_circle_fill,
                                color: Colors.red,
                                size: 18,
                              ),
                              // backgroundColor: Colors.red[50],
                              side: BorderSide(color: Colors.red),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Warned Allergens
                  if (warnedAllergens.isNotEmpty) ...[
                    Text(
                      "⚠️ Warning — Use with caution",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.amber[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: warnedAllergens
                          .map(
                            (a) => Chip(
                              label: Text(a.toString()),
                              avatar: Iconify(
                                Ph.triangle,
                                color: Colors.amber[800],
                                size: 18,
                              ),
                              // backgroundColor: Colors.amber[50],
                              side: BorderSide(color: Colors.amber),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  if (avoidedAllergens.isEmpty && warnedAllergens.isEmpty)
                    Center(
                      child: Text(
                        "Nothing here conflicts. Always a best idea to double-check though.",
                        style: TextStyle(color: Colors.green[200]),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
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
  late Future<ProductResultV3> foodData;

  @override
  void initState() {
    super.initState();
    foodData = _fetchProduct();
  }

  Future<ProductResultV3> _fetchProduct() async {
    final config = ProductQueryConfiguration(
      widget.upcCode,
      version: ProductQueryVersion.v3,
    );
    return await OpenFoodAPIClient.getProductV3(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: foodData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final product = snapshot.data?.product;

            if (product == null) {
              return const Center(child: Text("No product information found."));
            }

            return ProductSummaryWidget(productData: product);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: "Ask AI about this product",
            child: FloatingActionButton.small(
              heroTag: "ai_btn",
              onPressed: () {
                // TODO: Implement AI chat functionality
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Iconify(Ph.robot),
            ),
          ),
          const SizedBox(height: 12),
          Tooltip(
            message: "Go back",
            child: FloatingActionButton(
              heroTag: "back_btn",
              onPressed: () => context.pop(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Iconify(Ph.caret_left),
            ),
          ),
        ],
      ),
    );
  }
}
