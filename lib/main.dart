// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:lifetalk_editor/router.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  usePathUrlStrategy();

  runApp(const YoutubeApp());
}

///
class YoutubeApp extends StatelessWidget {
  const YoutubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.green,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      title: 'Youtube Player IFrame Demo',
      theme: ThemeData.from(colorScheme: colorScheme),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
