import 'package:flutter/material.dart';

enum ScriptType { latinica, cirilica }

class LanguageProvider with ChangeNotifier {
  ScriptType _currentScript = ScriptType.latinica;
  ScriptType get currentScript => _currentScript;

  void setScript(ScriptType script) {
    _currentScript = script;
    notifyListeners();
  }
}