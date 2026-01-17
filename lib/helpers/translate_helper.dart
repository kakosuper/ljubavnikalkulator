import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../engine/transliteration_engine.dart';

String t(BuildContext context, String text, {bool listen = false}) {
  final script = Provider.of<LanguageProvider>(context, listen: listen).currentScript;

  if (script == ScriptType.cirilica) {
    return TransliterationEngine.convertToCyrillic(text);
  }
  return text;
}
