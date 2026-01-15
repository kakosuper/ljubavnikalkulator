import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:ljubavnikalkulator/screens/ChineseZodiacPage.dart';
import 'package:ljubavnikalkulator/screens/ascendant_page.dart';
import 'package:ljubavnikalkulator/screens/calculator.dart';
import 'package:ljubavnikalkulator/screens/history.dart';
import '../widgets/app_drawer.dart';

import '../helpers/translate_helper.dart'; // Naš helper za pismo

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista stranica - koristimo prave klase gde ih imamo
final List<Widget> _pages = [
    CalculatorPage(),
    HistoryPage(), // Ovo ćemo sledeće srediti
    AscendantPage(), // OVDE MORA DA STOJI OVA KLASA
    ChineseZodiacPage(), // DODATO
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koristimo t() za naslov u AppBar-u
      appBar: AppBar(
  title: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFFFF5FA2), Color(0xFFB388FF)],
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: Text(
          t(context, "Ljubav i Zvezde"),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ),
      const SizedBox(height: 2),
      Text(
        t(context, "Kompatibilnost • Astro • Zabava"),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          color: NeumorphicTheme.isUsingDark(context) ? Colors.white60 : Colors.black54,
        ),
      ),
    ],
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  centerTitle: true,
),

      
      drawer: AppDrawer(),
      
      body: _pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.fixed, // Ovo dodaj jer sada imaš 4 ikonice
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  selectedItemColor: Colors.pink,
  unselectedItemColor: Colors.grey,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.favorite), label: t(context, "Ljubav")),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: t(context, "Istorija")),
    BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: t(context, "Podznak")),
    BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon), label: t(context, "Kineski")), // NOVA IKONICA
  ],
),
    );
  }
}