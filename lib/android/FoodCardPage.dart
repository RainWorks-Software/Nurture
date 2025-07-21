import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'package:flutter/material.dart';

class ProductSummaryWidget extends StatelessWidget {
  final Product productData;

  const ProductSummaryWidget({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    // Extracting relevant data, handling nulls
    final String productName =
        productData.productName ??
        productData.productNameInLanguages?[OpenFoodFactsLanguage.ENGLISH] ??
        'Unknown Product';
    final String brand = productData.brands ?? 'Unknown Brand';
    final String country =
        productData.countries ??
        productData.productNameInLanguages?[OpenFoodFactsLanguage.ENGLISH] ??
        'Unknown Region';
    final String? imageUrl = productData.imageFrontUrl;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Ensures the column only takes up needed space
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Iconify(Ph.image_square),
                    ),
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Iconify(Ph.fork_knife),
                ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2833), // Dark text color from image
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      brand,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Iconify(Ph.map_pin_line),
                        const SizedBox(width: 5),
                        Text(
                          country,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
