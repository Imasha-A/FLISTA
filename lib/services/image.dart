import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

Uint8List decodeBase64(String base64String) {
  return base64Decode(base64String);
}

class BarcodeImage extends StatelessWidget {
  final String base64String;

  const BarcodeImage({Key? key, required this.base64String}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Uint8List imageBytes = decodeBase64(base64String);

    return Image.memory(
      imageBytes,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.14,
      fit: BoxFit.contain,
    );
  }
}
