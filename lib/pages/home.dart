// Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:lifetalk_editor/widgets/inspector.dart';
import 'package:lifetalk_editor/widgets/tree.dart';
import 'package:lifetalk_editor/widgets/trimmer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.videoId});

  final String? videoId;

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  YoutubePlayerController? _controller;
  ValueNotifier<Content?> _selectedContent = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: 'juKd26qkNAw',
      flags: const YoutubePlayerFlags(
        hideControls: false,
        useHybridComposition: false,
        disableDragSeek: true,

        hideThumbnail: true,
        autoPlay: true,
        // mute: true,
        loop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) return Center(child: CircularProgressIndicator());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(title: const Text('Youtube Player IFrame Demo')),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              SizedBox(width: size.width, height: size.height),
              SizedBox(
                width: 600,
                height: 400,
                child: YoutubePlayer(controller: _controller!),
              ),
              SizedBox(width: MediaQuery.of(context).size.width),
              Positioned(
                top: 76,
                right: 0,
                left: 600,
                child: Inspector(_controller!, _selectedContent),
              ),
              Trimmer(_controller!, _selectedContent),
              Positioned(
                top: 400,
                width: 600,
                bottom: 0,
                child: TreeWidget(_selectedContent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
