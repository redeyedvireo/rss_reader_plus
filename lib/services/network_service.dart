import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:rss_reader_plus/services/prefs_service.dart';

class NetworkService {
  PrefsService _prefsService;

  NetworkService(BuildContext context) {
    _prefsService = Provider.of<PrefsService>(context, listen: false);
  }

  IOClient createProxyAwareHttpClient() {
    HttpClient httpClient = new HttpClient();

    // TODO: Where to insert proxy username and password?
    
    // From https://flutterigniter.com/debugging-network-requests/

    // Make sure to replace <YOUR_LOCAL_IP> with 
    // the external IP of your computer if you're using Android. 
    // Note that we're using port 8888 which is Charles' default.
    String proxy = Platform.isAndroid ? '<YOUR_LOCAL_IP>:8888' : 'localhost:8888';

    // Hook into the findProxy callback to set
    // the client's proxy.
    httpClient.findProxy = (uri) {
      return "PROXY $proxy;";
    };

    // This is a workaround to allow Charles to receive
    // SSL payloads when your app is running on Android.
    httpClient.badCertificateCallback = 
      ((X509Certificate cert, String host, int port) => Platform.isAndroid);

    // Pass your newly instantiated HttpClient to http.IOClient.
    IOClient myClient = IOClient(httpClient);

    return myClient;
  }

  Future<String> getFeed(String url) async {
    http.Response response;

    final uri = Uri.parse(url);

    if (_prefsService.getUseNetworkProxy()) {
      final client = createProxyAwareHttpClient();
      response = await client.get(uri);
    } else {
      response = await http.get(uri);
    }

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return '';
    }
  }

  Future<Uint8List> getIcon(String url) async {
    http.Response response;
    
    final uri = Uri.parse(url);

    if (_prefsService.getUseNetworkProxy()) {
      final client = createProxyAwareHttpClient();
      response = await client.get(uri);
    } else {
      response = await http.get(uri);
    }

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
    }
  }
}