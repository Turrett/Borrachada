import 'dart:io';

import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart';

import 'package:firebase_storage/firebase_storage.dart';

class BarcodeManager {
  BarcodeManager() {}

  uploadFile(file) async {
    final remotePath = 'Halloween/my-image.jpg';
    final ref = FirebaseStorage.instance.ref().child(remotePath);
    ref.putData(file);
  }

  buildBarcode() async {
    final image = Image(width: 300, height: 120);

// Fill it with a solid color (white)
    fill(image, color: ColorRgb8(255, 255, 255));

// Draw the barcode
    drawBarcode(image, Barcode.code128(), 'Test', font: arial24);
    uploadFile(image.getBytes());

    return image;
  }
}
