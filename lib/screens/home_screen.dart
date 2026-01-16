import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:ljubavnikalkulator/screens/ChineseZodiacPage.dart';
import 'package:ljubavnikalkulator/screens/ascendant_page.dart';
import 'package:ljubavnikalkulator/screens/calculator.dart';
import 'package:ljubavnikalkulator/screens/history.dart';
import '../widgets/app_drawer.dart';

import 'package:ljubavnikalkulator/ui/ui_tokens.dart';
import 'package:ljubavnikalkulator/widgets/fancy_appbar_title.dart';

import '../helpers/translate_helper.dart'; // Naš helper za pismo

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista stranica - koristimo prave klase gde ih imamo
final List<Widget Function()> _pages = [
  () => CalculatorPage(),
  () => HistoryPage(),
  () => AscendantPage(),
  () => ChineseZodiacPage(),
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
  extendBodyBehindAppBar: true,
  appBar: AppBar(
    title: const FancyAppBarTitle(
      titleKey: "Ljubav i Zvezde",
      subtitleKey: "Kompatibilnost • Astro • Zabava",
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),
  drawer: AppDrawer(),

  body: SafeArea(
  child: _pages[_currentIndex](),
),

  bottomNavigationBar: BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: _currentIndex,
    onTap: (index) => setState(() => _currentIndex = index),
    backgroundColor: UiTokens.surface(context),
    selectedItemColor: UiTokens.accentPink,
    unselectedItemColor: UiTokens.iconMuted(context),
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: t(context, "Ljubav")),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: t(context, "Istorija")),
      BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: t(context, "Podznak")),
      BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon), label: t(context, "Kineski")),
    ],
  ),
);

  }
}