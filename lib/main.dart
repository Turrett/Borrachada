import 'package:borrachada/add_code_page.dart';
import 'package:borrachada/read_code_page.dart';
import 'package:borrachada/stats.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Borrachada Tickets',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark
        
      ),
      home: const MyHomePage(title: 'Borrachada Tickets 🎟'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.add),
              label: 'Genera',
            ),
            NavigationDestination(
              icon: Icon(Icons.query_stats),
              label: 'Statistiche',
            ),
          ], 
        ),
        body: <Widget>[
          Container(
            child: readCodePage(),
          ),
          Container(
            child: addCodePage(),
          ),
          Container(
            child: StatsPage()),
        ][currentPageIndex]);
  }
}