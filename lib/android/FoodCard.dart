import 'package:flutter/cupertino.dart';

class FoodCard extends StatefulWidget {
  final String upcCode; 
  const FoodCard({super.key, required this.upcCode});

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  @override
  void initState() {
     
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("upcCode: ${widget.upcCode}"));
  }
}