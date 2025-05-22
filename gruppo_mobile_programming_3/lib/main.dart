import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_model.dart';
import 'screens/home.dart';
import 'screens/liste_view.dart';
import 'screens/categorie.dart';
import 'screens/analisi.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SharedData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ListaPage(),
    CategoriaPage(),
    AnalisiPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _bottomItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Liste'),
    BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categorie'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analisi'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: _bottomItems,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
