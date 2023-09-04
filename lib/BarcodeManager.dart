import 'dart:io';
import 'package:barcode_image/barcode_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';


class BarcodeManager {
  BarcodeManager() {}
 

  Future<void> generateAndUploadBarcode(String data) async {
  // Generate the barcode as a Uint8List
  final bc = Barcode.code128();
  final svg = bc.toSvg(data,);
  final Uint8List barcodeBytes = Uint8List.fromList(svg.codeUnits);

  uploadToFirestore(barcodeBytes,data);

  // Write the bytes to a file
  
}

uploadToFirestore(Uint8List barcodeBytes,String filename) async {
final String tempPath = (await getTemporaryDirectory()).path;
  final File file = File('$tempPath/barcode.png');
  await file.writeAsBytes(barcodeBytes);

  // Upload the file to Firebase Storage
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('/Halloween/$filename.svg');
  UploadTask uploadTask = ref.putFile(file);
  await uploadTask;
}

}
