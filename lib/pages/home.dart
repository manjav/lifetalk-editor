// Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:lifetalk_editor/providers/services_provider.dart';
import 'package:lifetalk_editor/widgets/hierarchy_view.dart';
import 'package:lifetalk_editor/widgets/inspector_view.dart';
import 'package:lifetalk_editor/widgets/timeline_view.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.videoId});

  final String? videoId;

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  YoutubePlayerController _controller = YoutubePlayerController(
    initialVideoId: '',
    flags: const YoutubePlayerFlags(
      useHybridComposition: false,
      disableDragSeek: true,
      hideThumbnail: true,
    ),
  );
  ValueNotifier<Content?> _selectedContent = ValueNotifier(null);

  Map<String, dynamic> _categories = {};

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async {
    ServiceState state = await serviceLocator<ServicesProvider>().initialize();
    _categories = state.data;
    _selectedContent.addListener(() {
      String video = _selectedContent.value!.values["videoUrl"] ?? "";
      if (video.isNotEmpty && _controller.value.metaData.videoId != video) {
        _controller.load(video);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final services = serviceLocator<ServicesProvider>();
    return Scaffold(
      body: ListenableBuilder(
        listenable: services,
        builder: (context, child) {
          if (services.state.status.index < ServiceStatus.complete.index) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              SizedBox(width: size.width, height: size.height),
              SizedBox(
                width: 600,
                height: 400,
                child: YoutubePlayer(controller: _controller),
              ),
              SizedBox(width: MediaQuery.of(context).size.width),
              Positioned(
                top: 76,
                right: 0,
                left: 600,
                child: InspectorView(_controller, _selectedContent),
              ),
              TimelineView(_controller, _selectedContent),
              Positioned(
                top: 400,
                width: 600,
                bottom: 0,
                child: HierarchyView(_selectedContent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
