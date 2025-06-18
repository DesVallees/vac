import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaq/screens/home/home.dart';
import 'package:vaq/screens/schedule/schedule.dart';
import 'package:vaq/screens/store/store.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vaq/screens/auth/auth.dart'; // Import the AuthWrapper
import 'package:vaq/services/user_data.dart'; // Import the user data service
import 'package:vaq/assets/data_classes/user.dart'; // Import custom User class

import 'package:firebase_core/firebase_core.dart';
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
    // Instantiate the user data service
    final userDataService = UserDataService();

    return MultiProvider(
      providers: [
        Provider<UserDataService>.value(value: userDataService),
        StreamProvider<User?>.value(
          value: userDataService.userDataStream,
          initialData: null, // Initial data is null (no user logged in)
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner:
            false, // Hide 'debug' banner when running application
        title: 'VAQ+',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF00AAB2))
              .copyWith(
                  primary: const Color(0xFF00AAB2),
                  secondary: const Color(0xFF7ED321),
                  surface: const Color(0xFFF4F6F8),
                  onSurface: const Color(0xFF1A202C),
                  tertiary: const Color(0xFFF5A623)),
        ),

        // --- Localization Configuration ---
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        locale: const Locale('es', 'ES'),

        home: const AuthWrapper(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 1;

  void _navigateToPage(int index) {
    if (index >= 0 && index <= 2) {
      // Basic bounds check
      setState(() {
        selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = Store();
      case 1:
        page = Home(
          onNavigateToSchedule: () => _navigateToPage(2),
          onNavigateToStore: () => _navigateToPage(0),
        );
      case 2:
        page = Schedule();
      default:
        page = Home(
          onNavigateToSchedule: () => _navigateToPage(2),
          onNavigateToStore: () => _navigateToPage(0),
        );
        print('Warning: Invalid selectedIndex $selectedIndex');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Container(
            key: ValueKey<int>(selectedIndex),
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
                _navigateToPage(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
