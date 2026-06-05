import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Returns the root data directory for LingoDemo.
///
/// On Windows: `D:\LingoDemoData\` (to keep files off the C drive).
/// On all other platforms: the standard app documents directory.
Future<Directory> getLingoDataDir() async {
  if (Platform.isWindows) {
    final dir = Directory(r'D:\LingoDemoData');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
  return getApplicationDocumentsDirectory();
}
