import 'dart:typed_data';

import 'package:http/http.dart' as http;

class NetworkService {

  static Future<String> getFeed(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '';
    }
  }

  static Future<Uint8List> getIcon(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }
}