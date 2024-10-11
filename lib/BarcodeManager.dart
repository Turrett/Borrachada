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

  Future<String> readHtmlFile(String filePath) async {
    try {
      final file = File(filePath);
      // Leggi il contenuto del file
      String fileContent = await file.readAsString();
      return fileContent;
    } catch (e) {
      print('Errore durante la lettura del file: $e');
      throw e;
    }
  }

  sendEmail(String ricevente, File allegato //For showing snackbar
      ) async {
    String username = 'sborrachadaevents@gmail.com'; //Your Email
    String password =
        'tedozespquftcymw '; // 16 Digits App Password Generated From Google Account
    String html = '<!DOCTYPE html><html lang="it"><head>    <meta charset="UTF-8">    <meta name="viewport" content="width=device-width, initial-scale=1.0">    <title>Invito Festa di Halloween</title>    <style>        /* Stili di base per l\'email */        body {            margin: 0;            padding: 0;            background: url(\'https://i.postimg.cc/Jhn5jLQf/undefined-Imgur.jpg\') no-repeat center center fixed;            background-size: cover;            font-family: \'Arial\', sans-serif;            color: #FFFFFF;        }        .container {            text-align: center;            padding: 50px;            background: rgba(0, 0, 0, 0.7);            margin: 50px auto;            max-width: 600px;            border-radius: 10px;        }        h1 {            font-size: 3em;            margin-bottom: 20px;            text-transform: uppercase;            color: #FFA500;        }        p {            font-size: 1.2em;            margin-bottom: 30px;        }        .details {            font-size: 1.1em;            margin-top: 20px;            line-height: 1.6;        }        .cta-button {            display: inline-block;            padding: 15px 25px;            font-size: 1.2em;            color: #000;            background-color: #FFA500;            text-decoration: none;            border-radius: 5px;            margin-top: 20px;        }        .cta-button:hover {            background-color: #FFD700;        }        /* Media Queries per la responsività */        @media only screen and (max-width: 600px) {            .container {                padding: 20px;                margin: 20px auto;            }            h1 {                font-size: 2em;            }            p, .details {                font-size: 1em;            }            .cta-button {                padding: 10px 20px;                font-size: 1em;            }        }    </style></head><body>    <div class="container">        <h1>HALLOWEEN BORRACHADA</h1>        <p>Se hai ricevuto questa mail sei invitatə alla nostra festa di Halloween!</p>        <div class="details">            <p><strong>Luogo:</strong> Associazione Ekidna, via Livorno 9 Carpi</p>            <p><strong>Data:</strong> 31 Ottobre 2024</p>            <p>Non perderti una notte di divertimento, costumi incredibili e tante sorprese!</p>            <p>In allegato a questa mail troverai un <span style="color: #FFA500; font-weight: bold;">QR code</span> che ti permetterà di partecipare alla festa, è univoco e non può essere utilizzato più volte.</p>            <p>L\'accesso al locale è riservato ai possessori della <span style="color: #FFA500; font-weight: bold;">Tessera Ekidna 2024</span>. Puoi iscriverti e riceverla gratuitamente e digitalmente premendo il bottone qua sotto.</p>        </div>        <a href="https://www.ekidna.eu/section/subscribe" class="cta-button">Tesserati Ora</a>    </div></body></html>';
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
    final file = await barcodeGeneratorSvg(data);
    ;

    await uploadToFirestore(file, data);
    await uploadToFirebase(data,'');
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
      await uploadToFirebase(data,ricevente);
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

  Future<void> uploadToFirebase(String codice,String? mail) {
    return db
        .add({
          "mail":mail,
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

Future<File> barcodeGeneratorSvg(String data) async {
  String svg = new Barcode.fromType(BarcodeType.QrCode)
      .toSvg(data, width: 150, height: 150);
  Uint8List fileBytes = Uint8List.fromList(svg.codeUnits);
  final String tempPath = (await getTemporaryDirectory()).path;
  File file = File('$tempPath/barcode.png');
  await file.writeAsBytes(fileBytes);
  return file;
}

Future<File> barcodeGeneratorPng(String data) async {
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
