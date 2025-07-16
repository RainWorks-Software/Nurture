import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class FoodCard extends StatefulWidget {
  final String upcCode; 
  const FoodCard({super.key, required this.upcCode});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  Future<ProductResultV3> getProductInformation() async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(widget.upcCode, version: ProductQueryVersion.v3);
    ProductResultV3 foodDetails = await OpenFoodAPIClient.getProductV3(configuration) ;

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
      body: FutureBuilder(future: foodData, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          log(snapshot.data?.product?.toJson().toString() ?? "no product information");

          return Center(child: Text(snapshot.data?.product?.toJson().toString() ?? "no product data"));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      }),
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