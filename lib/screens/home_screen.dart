import 'package:flutter/material.dart';
import 'package:ljubavnikalkulator/screens/ascendant_page.dart';
import 'package:ljubavnikalkulator/screens/calculator.dart';
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
    Center(child: Text("Istorija")), // Ovo ćemo sledeće srediti
    AscendantPage(), // OVDE MORA DA STOJI OVA KLASA
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Koristimo t() za naslov u AppBar-u
      appBar: AppBar(
        title: Text(t(context, "Ljubavni Kalkulator")),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      
      drawer: AppDrawer(),
      
      body: _pages[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.pink,
        // Koristimo t() za svaku labelu u navigaciji
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), 
            label: t(context, "Kalkulator"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), 
            label: t(context, "Istorija"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome), 
            label: t(context, "Podznak"),
          ),
        ],
      ),
    );
  }
}