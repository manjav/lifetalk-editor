import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_controller.dart';

class Inspector extends StatefulWidget {
  final YoutubePlayerController controller;
  const Inspector(this.controller, {super.key});

  @override
  State<Inspector> createState() => _InspectorState();
}

class _InspectorState extends State<Inspector> {
  final _textFieldController = TextEditingController(text: "OtWciKwlaG8");

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _textFieldController,

          onSubmitted: (value) {
            widget.controller.pause();
            widget.controller.load(_textFieldController.text);
          },
        ),
        ElevatedButton(
          onPressed: () async {
            widget.controller.dispose();
            widget.controller.load(widget.controller.initialVideoId);
            // setState(() {});
          },
          child: Icon(Icons.play_arrow),
        ),
      ],
    );
  }
}
