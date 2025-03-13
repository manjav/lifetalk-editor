// Copyright 2024 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:go_router/go_router.dart';
import 'package:lifetalk_editor/pages/home.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const Home(),
      routes: [
        GoRoute(
          path: 'watch',
          pageBuilder: (_, GoRouterState state) {
            return NoTransitionPage(
              child: Home(videoId: state.uri.queryParameters['v']),
            );
          },
        ),
      ],
    ),
  ],
);
