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

  String mailButton = 'Invia';
  bool isExecuting = false;
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "");
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

  Future<void> SendMail() async {
    setState(() {
      isExecuting = true;
      mailButton = 'Eseguo';
    });

    // Esegui la tua funzione asincrona qui
    String esito = '';
    if (_controller.text != '') {
      esito = await BarcodeManager()
          .generateSendMailAndUploadBarcode(_controller.text);
    }

    setState(() {
      isExecuting = false;
      mailButton = 'Invia';
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Operazione completata'),
          content: Text(esito),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 150,
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Inserisci la mail dell\' invitat*',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(
                      width: 230,
                      height: 50,
                      child: TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => {isExecuting ? null : SendMail()},
                    child: (isExecuting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ))
                        : Text(mailButton)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
