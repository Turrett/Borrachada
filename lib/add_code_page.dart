import 'package:borrachada/BarcodeManager.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['01', '02', '03', '04'];

// ignore: must_be_immutable
class addCodePage extends StatefulWidget {
  State<addCodePage> createState() => addCodePageState();
}

class addCodePageState extends State<addCodePage> {
  String selectedItem = '00';
  String buttonText = 'Genera Codici a barre';
  bool isExecuting = false;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "1");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> eseguiFunzioneAsincrona() async {
    setState(() {
      isExecuting = true;
      buttonText = 'In esecuzione...';
    });

    // Esegui la tua funzione asincrona qui
    await BarcodeManager()
        .uploadMultipleCodes(int.parse(_controller.text), '00');

    setState(() {
      isExecuting = false;
      buttonText = 'Genera Codici a barre';
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Operazione completata'),
          content: Text(
              'Codici generati con successo, li puoi trovare su Firebase storage'),
          actions: [
            TextButton(
              child: Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'quanti codici vuoi generare?',
            ),
            SizedBox(
              width: 100,
              height: 50,
              child: TextField(
                keyboardType: TextInputType.number,
                controller: _controller,
                maxLength: 4,
              ),
            ),
          ],
        ),
        /*DropdownButton<String>(
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              child: Text(value),
              value: value,
            );
          }).toList(),
          onChanged: (value) => selectedItem = value!,
        ),*/
        ElevatedButton(
          onPressed: () => {isExecuting ? null : eseguiFunzioneAsincrona()},
          child: Text(buttonText),
        )
      ],
    );
  }
}
