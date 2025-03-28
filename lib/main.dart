// Copyright 2025 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:lifetalk_editor/managers/device_info.dart';
import 'package:lifetalk_editor/managers/prefs.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/fork.dart';
import 'package:lifetalk_editor/router.dart';
import 'package:lifetalk_editor/theme/theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  await windowManager.ensureInitialized();
  windowManager.setSize(Size(1200, 1000));
  runApp(const LifeTalkEditor());
}

class LifeTalkEditor extends StatefulWidget {
  const LifeTalkEditor({super.key});

  @override
  State<LifeTalkEditor> createState() => _LifeTalkEditorState();
}

class _LifeTalkEditorState extends State<LifeTalkEditor> {
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
    return ForkController(
      notifier: ValueNotifier<Fork?>(null),
      child: InheritedYoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: '',
          flags: const YoutubePlayerFlags(
            useHybridComposition: false,
            disableDragSeek: true,
            hideThumbnail: true,
          ),
        ),
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Lifetalk Editor',
          routerConfig: router,
          theme: customTheme,
        ),
      ),
    );
  }
}
