import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initBindings();
  runApp(
    const ProviderScope(
      child: LingoApp(),
    ),
  );
}
