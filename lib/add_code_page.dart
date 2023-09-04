import 'package:flutter/material.dart';

const List<String> list = <String>['01', '02', '03', '04'];

// ignore: must_be_immutable
class addCodePage extends StatefulWidget {
  State<addCodePage> createState() => addCodePageState();
}

class addCodePageState extends State<addCodePage> {
  String selectedItem = '00';

  addCodePageState() {
    //  for (var numero in numeri) {
    //   persone.add(new DropdownMenuItem(child: Text(numero)));
    // }
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
        TextField(keyboardType: TextInputType.number,maxLength: 4,),
        ElevatedButton(
          onPressed: () => {},
          child: Text('Genera codici a barre'),
        )

      ],
    );
  }
}
