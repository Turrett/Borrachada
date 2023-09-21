import 'package:borrachada/BarcodeManager.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['01', '02', '03', '04'];

// ignore: must_be_immutable
class addCodePage extends StatefulWidget {
  State<addCodePage> createState() => addCodePageState();
}

class addCodePageState extends State<addCodePage> {
  String selectedItem = '00';
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

  String generateRandomCode(String mantissa) {
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        /*DropdownButton<String>(
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              child: Text(value),
              value: value,
            );
          }).toList(),
          onChanged: (value) => selectedItem = value!,
        ),*/
        SizedBox(height: 200,width:300,child:Text('quanti codici vuoi generare?'),),
        
        TextField(
          keyboardType: TextInputType.number,
          controller: _controller,
          maxLength: 4,
        ),
        ElevatedButton(
          onPressed: () => {BarcodeManager().uploadMultipleCodes(int.parse(_controller.text), '00')},
          child: Text('Genera codici a barre'),
        )
      ],
    );
  }
}
