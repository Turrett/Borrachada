import 'dart:io';
import 'dart:math';
import 'package:barcode_image/barcode_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';

class BarcodeManager {
  String progetto = 'Halloween';
  final db = FirebaseFirestore.instance.collection('Halloween');
  final storage = FirebaseStorage.instance;

  BarcodeManager() {}

  Future <void> uploadMultipleCodes(int quanti, String mantissa) async {
    for (int i = 0; i < quanti; i++) {
      await generateAndUploadBarcode(randomNumberGen());
    }
  }

  String randomNumberGen() {
    var number = "";
    var randomnumber = Random();
    //chnage i < 15 on your digits need
    for (var i = 0; i < 12; i++) {
      number = number + randomnumber.nextInt(9).toString();
    }
    print(number);
    return number;
  }

  Future<void> generateAndUploadBarcode(String data) async {
    // Generate the barcode as a Uint8List
    final svg = new Barcode.fromType(BarcodeType.QrCode).toSvg(data,width: 150,height: 150);
    final Uint8List barcodeBytes =new Uint8List.fromList(svg.codeUnits);

    await uploadToFirestore(barcodeBytes, data);
    await uploadToFirebase(data);

    // Write the bytes to a file
  }

  Future <void> uploadToFirestore(Uint8List barcodeBytes, String filename) async {
    final String tempPath = (await getTemporaryDirectory()).path;
    final File file = File('$tempPath/barcode.png');
    await file.writeAsBytes(barcodeBytes);

    // Upload the file to Firebase Storage

    Reference ref = storage.ref().child('/$progetto/$filename.svg');
    UploadTask uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() => debugPrint('fatto $filename'));
  }

  Future<void> uploadToFirebase(String codice) {
    return db
        .add({
          "codice": codice,
          "utilizzato": false,
          "data": DateTime.now().toString(),
        })
        .then((value) => print('aggiunto $codice a DB'))
        .catchError((error) => print("Failed to add codice: $error"));
  }

  Future<String> verifyCode(String codice) async {
    //recupero i documenti con un determinato codice
    var ret;
    QuerySnapshot query = await db
        .where("codice", isEqualTo: codice)
        .where('utilizzato', isEqualTo: false)
        .get()
        .whenComplete(() => ret = "sono stati trovati documenti");

    //verifico che sia uno solo
    if (query.docs.length == 1) {
      for (var doc in query.docs) {
        //verifico che non sia stato utilizzato
        print("codice valido");
        ret = "✔ codice valido";
        db
            .doc(doc.id)
            .update({'utilizzato': true})
            .onError((error, stackTrace) => ret += "ma non disattivato")
            .whenComplete(() => ret += "e disattivato");
      }
    } else {
      ret = "❌ il codice non esiste o è già stato validato";
    }
    print(ret);
    return ret;
  }

  Future<String> countSold() async {
    var query = await db.where('utilizzato', isEqualTo:true).get();
    return query.docs.length.toString();
  }

  Future<String> countCreati() async {
    var query = await db.get();
    return query.docs.length.toString();
  }
}
