import 'package:flutter/material.dart';
import 'persona_pages.dart';
import 'citas_page.dart';
import 'basedatosforaneas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DB.eliminarDB();
  runApp(const AppCitas());
}

class AppCitas extends StatelessWidget {
  const AppCitas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Citas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    PersonasPage(),
    CitasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person), label: 'Personas'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Citas'),
        ],
      ),
    );
  }
}