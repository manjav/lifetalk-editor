// Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.videoId});

  final String? videoId;

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Youtube Player IFrame Demo')),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        
        ],
      ),
    );
  }

  @override
  void dispose() {
\    super.dispose();
  }
}
