import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class readCodePage extends StatefulWidget {
  @override
  State<readCodePage> createState() => readCodePageState();
}

class readCodePageState extends State<readCodePage> {
  String result = '';
  TextEditingController manualControl = TextEditingController();
  verificaCodice() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            SizedBox(width: 30),
            Container(
              //verifica manuale
              width: 150,
              height: 40,
              child: ElevatedButton(
                //scannerizza
                onPressed: () async {
                  var res = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SimpleBarcodeScannerPage(),
                      ));
                  setState(() {
                    if (res is String) {
                      result = res;
                    }
                  });
                },
                child: const Text('Scannerizza'),
              ),
            ),
            SizedBox(width: 30),
            Container(
              width: 150,
              child: Text(
                'Codice : $result',
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
                
              ),
            ),
            SizedBox(width: 30),
          ]),
          
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 30),
              Container(
                //verifica manuale
                width: 150,
                height: 40,
                child: ElevatedButton(
                    onPressed: verificaCodice(),
                    child: Text('Verifica manuale')),
              ),
              SizedBox(width: 30),
              SizedBox(
                //campo manuale
                width: 150,
                height: 40,
                child: TextField(controller: manualControl),
              ),
            ],
          ),
          Divider(),
          Text('esito'),
        ],
      ),
    );
  }
}
