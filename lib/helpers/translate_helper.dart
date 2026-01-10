import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../engine/transliteration_engine.dart';

String t(BuildContext context, String text) {
  final script = Provider.of<LanguageProvider>(context).currentScript;
  
  if (script == ScriptType.cirilica) {
    return TransliterationEngine.convertToCyrillic(text);
  }
  return text; // Vraća originalnu latinicu
}