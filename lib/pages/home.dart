// Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
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
    return Scaffold(
      // appBar: AppBar(title: const Text('Youtube Player IFrame Demo')),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              SizedBox(
                width: 600,
                height: 400,
                child:
                YoutubePlayer(controller: _controller!),              ),
              SizedBox(width: MediaQuery.of(context).size.width),
              Positioned(
                top: 76,
                right: 0,
                left: 600,
                child: Inspector(_controller!),
              ),
              Trimmer(_controller!),
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
