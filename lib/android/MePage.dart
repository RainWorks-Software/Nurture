import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ph.dart';
import 'package:ofd/android/widgets/AllergenSelector.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: AllergenSelectorChips()),
      floatingActionButton: Tooltip(
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
    );
  }
}
