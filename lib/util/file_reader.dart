import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class FileReader {
  static Future<String> loadAsset(filename) async {
    return await rootBundle.loadString('assets/$filename');
  }

  static Future<String> readAboutFile() async {
    final aboutText = await loadAsset('about.html');
    return aboutText;
  }
}