import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vac/screens/home/home.dart';
import 'package:vac/screens/landing/introduction.dart';
import 'package:vac/screens/schedule/schedule.dart';
import 'package:vac/screens/store/store.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import Firebase Core
import 'package:firebase_core/firebase_core.dart';
// Import the generated options file
import 'firebase_options.dart';

// Make main async
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // Use the generated options
  );

  // Initialize locale data
  await initializeDateFormatting('es_ES', null);

  // Run app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, // Hide 'debug' banner when running application
        title: 'VAC+',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(123, 2, 193, 1)),
        ),
        home: Introduction(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Store();
      case 1:
        page = Home();
      case 2:
        page = Schedule();
      default:
        throw UnimplementedError(
            'No widget selected for Nav\'s index #$selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Color.fromRGBO(244, 241, 241, 1),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Container(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: SizedBox(width: double.infinity, child: page),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: mainArea,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Tienda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month),
                  label: 'Agenda',
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
