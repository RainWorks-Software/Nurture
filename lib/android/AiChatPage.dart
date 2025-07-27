import 'dart:async';
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:iconify_flutter_plus/iconify_flutter_plus.dart';
import 'package:iconify_flutter_plus/icons/ph.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:path_provider/path_provider.dart';

final gemma = FlutterGemmaPlugin.instance;
const ModelFileName = "model.bin";
const ModelNetworkDownloadUrl = "";
Future<File?> retrieveAiModelPathIfExists() async {
  final configurationDirectory = (await getApplicationDocumentsDirectory()).path;
  final finalPath = "$configurationDirectory/$ModelFileName";
  final modelFile = File(finalPath);

  if (!modelFile.existsSync()) {
    return null;
  }

  return modelFile;
} 

class ModelDownloadFromWebWidget extends StatefulWidget {
  const ModelDownloadFromWebWidget({super.key});

  @override
  State<ModelDownloadFromWebWidget> createState() => _ModelDownloadFromWebWidgetState();
}

class _ModelDownloadFromWebWidgetState extends State<ModelDownloadFromWebWidget> {
  final modelManager = gemma.modelManager;
  late final bool isDownloading; 
  late final Stream<int> downloadProgressStream;

  @override
  void initState() {
    super.initState();
    downloadProgressStream = modelManager.downloadModelFromNetworkWithProgress(ModelNetworkDownloadUrl); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
         TextButton.icon(label: isDownloading ? const Text("Downloading Model...") : const Text("Download Model"), icon: const Iconify(Ph.download), onPressed: () {
            if (isDownloading) return;

            setState(() {
              isDownloading = true;
            });
         }),
         if (isDownloading) StreamBuilder(stream: downloadProgressStream, builder: (context, state) {
            print("${state.data}"); 
            return Column(
              children: [
                CircularProgressIndicator(
                  value: state.data!.toDouble(),
                ),
                Text("${state.data!}% completed")
              ],
            );
         }),
      ],)
    );
  }
}

class AiChatPrompt extends StatefulWidget {
  final Product product;
  const AiChatPrompt({super.key, required this.product});

  @override
  State<AiChatPrompt> createState() => _AiChatPromptState();
}

class _AiChatPromptState extends State<AiChatPrompt> {
  @override
  Widget build(BuildContext context) {
    return ModelDownloadFromWebWidget();
  }
}