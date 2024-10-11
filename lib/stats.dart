

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Wrap(
          children: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('STATISTICHE',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 30.0),)),
          ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                   
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<String>(
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<String>(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
