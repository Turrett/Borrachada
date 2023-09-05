import 'dart:io';
import 'dart:math';
import 'package:barcode_image/barcode_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';

class BarcodeManager {
  DatabaseReference db = FirebaseDatabase.instance.ref("Halloween");
  FirebaseStorage storage = FirebaseStorage.instance;
  String progetto = 'Halloween';

  BarcodeManager() {}

  void uploadMultipleCodes(int quanti, String mantissa) {
    for (int i = 0; i < quanti; i++) {
      generateAndUploadBarcode(randomNumberGen().toString());
    }
  }

  int randomNumberGen() {
    int min = 0;
    int max = 99999999;
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  Future<void> generateAndUploadBarcode(String data) async {
    // Generate the barcode as a Uint8List
    final svg = Barcode.fromType(BarcodeType.Code128).toSvg(data);
    final Uint8List barcodeBytes = Uint8List.fromList(svg.codeUnits);

    uploadToFirestore(barcodeBytes, data);
    uploadToFirebase(data)

    // Write the bytes to a file
  }

  uploadToFirestore(Uint8List barcodeBytes, String filename) async {
    final String tempPath = (await getTemporaryDirectory()).path;
    final File file = File('$tempPath/barcode.png');
    await file.writeAsBytes(barcodeBytes);

    // Upload the file to Firebase Storage

    Reference ref = storage.ref().child('/$progetto/$filename.svg');
    UploadTask uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() => debugPrint('fatto $filename'));
  }

  uploadToFirebase(String codice) {
    db.set({
      "codice":codice,
      "utilizzato":false,
      "data":DateTime.now().toString(),
    });
  }
}
