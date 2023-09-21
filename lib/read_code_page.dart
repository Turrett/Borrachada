import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:borrachada/BarcodeManager.dart';

class readCodePage extends StatefulWidget {
  @override
  State<readCodePage> createState() => readCodePageState();
}

class readCodePageState extends State<readCodePage> {
  String cameraReading = '';
  String result = '';

  TextEditingController manualControl = TextEditingController();
  late TextEditingController output = TextEditingController();

  verificaCodice() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                          builder: (context) =>
                              const SimpleBarcodeScannerPage(),
                        ));
                    setState(() {
                      if (res is String) {
                        manualControl.text = res;
                      }
                    });
                  },
                  child: const Text('Scannerizza'),
                ),
              ),
              SizedBox(
                //campo manuale
                width: 150,
                height: 40,
                child: TextField(controller: manualControl),
              ),
            ],
          ),
          Divider(),
          Container(
            //verifica manuale
            width: 150,
            height: 40,
            child: ElevatedButton(
                onPressed: () async {
                  String res =
                      await BarcodeManager().verifyCode(manualControl.text);
                  setState(() {
                    result = res;
                  });
                },
                child: Text('Verifica ')),
          ),
          Divider(),
          Text(result),
        ],
      ),
    );
  }
}
