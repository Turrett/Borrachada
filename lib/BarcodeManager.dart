import 'dart:io';
import 'dart:math';
import 'package:barcode_image/barcode_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:image/image.dart' as im;

class BarcodeManager {
  String progetto = 'Halloween';
  final db = FirebaseFirestore.instance.collection('Halloween');
  final storage = FirebaseStorage.instance;

  BarcodeManager() {}

  Future<void> uploadMultipleCodes(int quanti, String mantissa) async {
    for (int i = 0; i < quanti; i++) {
      await generateAndUploadBarcode(randomNumberGen());
    }
  }

  sendEmail(String ricevente, File allegato //For showing snackbar
      ) async {
    String username = 'sborrachadaevents@gmail.com'; //Your Email
    String password =
        'tedozespquftcymw '; // 16 Digits App Password Generated From Google Account
    String html ="<sectionid=\"header\"class=\"header\"><divclass=\"overlay\"><divclass=\"header-image\"><divclass=\"header-content\"><divclass=\"container\"><divclass=\"header-content-inner\"><h1style=\"margin:0;font-size:75px;text-transform:uppercase;padding:0;\">Spooky</h1><h1>HalloweenEventsLandingPageHTMLTemplate</h1><adata-scroll=\"\"data-options=\"{&quot;easing&quot;:&quot;easeInQuad&quot;}\"href=\"#demo-section\"class=\"custom-btn\">SeeDemos</a></div></div></div></div></div></section>" ;
    final smtpServer = gmail(username, password);
    // Use the SmtpServer class to configure an SMTP server:
    // final smtpServer = SmtpServer('smtp.domain.com');
    // See the named arguments of SmtpServer for further configuration
    // options.
    print("connection done");
    // crea un numero univoco
    final message = Message()
      ..from = Address(username, 'Borrachada')
      ..recipients.add(ricevente)
      // ..ccRecipients.addAll(['abc@gmail.com', 'xyz@gmail.com']) // For Adding Multiple Recipients
      // ..bccRecipients.add(Address('a@gmail.com')) For Binding Carbon Copy of Sent Email
      ..subject = 'Halloween 2024'
      ..text = 'Invito per festa Halloween'
      ..html = html // For Adding Html in email
      ..attachments = [
        FileAttachment(allegato) //For Adding Attachments
      ];

    try {
      final sendReport = await send(message, smtpServer);
      print('Message Sent' + sendReport.toString());
    } on MailerException catch (e) {
      throw e;
    } finally {}
  }

  Future<void> generateAndUploadBarcode(String data) async {
    // Generate the barcode as a Uint8List
    final file= await barcodeGeneratorSvg(data);;

    await uploadToFirestore(file, data);
    await uploadToFirebase(data);
  }

  Future<String> generateSendMailAndUploadBarcode(String ricevente) async {
    String data = randomNumberGen();
    final file = await barcodeGeneratorPng(data);
    String esito = '';

    try {
      //invio mail
      await sendEmail(ricevente, file);
      esito += ('mail inviata correttamente a ' + ricevente);
      print('mail inviata correttamente a ' + ricevente);

      //upload, se la mail fallisce non viene eseguito
      await uploadToFirestore(file, data);
      esito += '\nfile caricato Correttamente';
      print('file ' + data + ' caricato Correttamente');

      // aggiornamento del db
      await uploadToFirebase(data);
      esito += '\nentry nel DB aggiunta';
      print('Entry nel DB aggiunta');

      esito += '\n ✔ tutto a posto ✔';
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }

      esito +=
          'invio Mail fallito, verificare che esista e che sia possibile inviare mail';
    } on (Exception e,) {
      print('An error occurred: $e');
      esito +=
          'errore durante la creazione del codice o durante il caricamento del file';
    } finally {
      return esito;
    }
  }

  Future<void> uploadToFirestore(File file, String filename) async {
    // Upload the file to Firebase Storage
    Reference ref = storage.ref().child('/$progetto/$filename.svg');
    UploadTask uploadTask = ref.putFile(file);
    try {
      await uploadTask.whenComplete(() => debugPrint('fatto $filename'));
    } catch (e) {
      throw e;
    }
  }

  Future<void> uploadToFirebase(String codice) {
    return db
        .add({
          "codice": codice,
          "utilizzato": false,
          "dataCreazione": DateTime.now().toString(),
        })
        .then((value) => print('aggiunto $codice a DB'))
        .catchError((error) => throw error);
  }

// ----------------------------Verification Functions-----------------------------------

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

//-----------------------------Statistic------------------------------------------------

  Future<String> countSold() async {
    var query = await db.where('utilizzato', isEqualTo: true).get();
    return query.docs.length.toString();
  }

  Future<String> countCreati() async {
    var query = await db.get();
    return query.docs.length.toString();
  }
}

//----------------------------Helper functions------------------------------------------

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

Future<File> barcodeGeneratorSvg(String data) async{
   String svg = new Barcode.fromType(BarcodeType.QrCode)
      .toSvg(data, width: 150, height: 150);
     Uint8List fileBytes = Uint8List.fromList(svg.codeUnits);
     final String tempPath = (await getTemporaryDirectory()).path;
  File file = File('$tempPath/barcode.png');
  await file.writeAsBytes(fileBytes);
  return file;
}

Future <File> barcodeGeneratorPng (String data)async {
  final image = im.Image(width: 600, height: 350);

  // Fill it with a solid color (white)
  im.fill(image, color: im.ColorRgb8(255, 255, 255));

  // Draw the barcode
  drawBarcode(image, Barcode.qrCode(), data, font: im.arial24);

  Uint8List fileBytes = im.encodePng(image);
  final String tempPath = (await getTemporaryDirectory()).path;
  File file = File('$tempPath/$data.png');
  await file.writeAsBytes(fileBytes);
  return file;
}
