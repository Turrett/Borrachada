import 'BarcodeManager.dart';
import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  @override
  State<StatsPage> createState() => StatsPageState();
}

class StatsPageState extends State<StatsPage> {
  String present = '';
  String sold = '';

  @override
  void initState() {
    super.initState();
    present = BarcodeManager().countCreati().toString();
    sold = BarcodeManager().countCreati().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder<String>(
          future: BarcodeManager().countCreati(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else
                return Text('Numero di biglietti Creati: ${snapshot.data}', style: TextStyle(fontSize: 20));
            }
          },
        ),
        FutureBuilder<String>(
          future: BarcodeManager().countSold(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else
                return Text('Numero di biglietti Venduti: ${snapshot.data}', style: TextStyle(fontSize: 20));
            }
          },
        ),
      ],
    );
  }
}
