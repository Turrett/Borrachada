import 'package:borrachada/BarcodeManager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['01', '02', '03', '04'];

// ignore: must_be_immutable
class addCodePage extends StatefulWidget {
  // Create a storage reference from our app
  String dataUrl = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==';

  State<addCodePage> createState() => addCodePageState();
}

class addCodePageState extends State<addCodePage> {
  late Future<ListResult> futureFiles;

  String selectedItem = '00';
  String svgpic = '';

  @override
  void initState() {
    super.initState();
  }


  String generateRandomCode(String mantissa) {
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButton<String>(
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              child: Text(value),
              value: value,
            );
          }).toList(),
          onChanged: (value) => selectedItem = value!,
        ),
        Text('quanti codici vuoi generare?'),
        TextField(
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
        ElevatedButton(
          onPressed: () => {BarcodeManager().buildBarcode()},
          child: Text('Genera codici a barre'),
        ),
      ],
    );
  }
}
