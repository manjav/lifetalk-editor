// Copyright 2020 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:lifetalk_editor/managers/device_info.dart';
import 'package:lifetalk_editor/managers/prefs.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/router.dart';
import 'package:lifetalk_editor/theme/theme.dart';

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

  await Prefs().initialize();
  initServices();
  runApp(const YoutubeApp());
}

class YoutubeApp extends StatefulWidget {
  const YoutubeApp({super.key});

  @override
  State<YoutubeApp> createState() => _YoutubeAppState();
}

class _YoutubeAppState extends State<YoutubeApp> {
  Future<void> _initialize() async {
    var result = await DeviceInfo.preInitialize(context, false);
    if (result) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    if (!DeviceInfo.isPreInitialized) {
      return const SizedBox();
    }

    return MaterialApp.router(
      title: 'Youtube Player IFrame Demo',
      theme: customTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
