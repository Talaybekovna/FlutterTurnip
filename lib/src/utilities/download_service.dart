import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

abstract class DownloadService {
  Future<String?> download({required String url});

  factory DownloadService() {
    if (kIsWeb) {
      return WebDownloadService();
    } else {
      return MobileDownloadService();
    }
  }
}

class WebDownloadService implements DownloadService {
  @override
  Future<String?> download({required String url}) async {
    // html.window.open(url, "_blank");
    final response = await http.get(Uri.parse(url));
    final byte = response.bodyBytes;
    final File file = File('C:/downloads');
    // await file.writeAsBytes(byte);
    await file.writeAsBytes(Uint8List.fromList(byte));
    return 'success';
  }
}

class MobileDownloadService implements DownloadService {
  @override
  Future<String?> download({required String url}) async {
    final appDocDir = await getExternalStorageDirectory();
    if (appDocDir != null) {
      final id = await FlutterDownloader.enqueue(
        url: url,
        savedDir: appDocDir.path,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );
      return id;
    }
    return null;
  }
}
