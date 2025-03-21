import 'package:flutter/material.dart';
import 'package:intry/intry.dart';
import 'package:lifetalk_editor/providers/node.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class InspectorView extends StatefulWidget {
  const InspectorView({super.key});

  @override
  State<InspectorView> createState() => _InspectorViewState();
}

class _InspectorViewState extends State<InspectorView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: NodeController.of(context)!,
      builder: (context, value, child) {
        if (value == null) return SizedBox();
        String video = value.values["media"] ?? "";
        if (video.contains("*")) {
          video = video.split("*")[0];
        }
        final videoController = YoutubePlayerController.of(context)!;
        if (video.isNotEmpty &&
            videoController.value.metaData.videoId != video) {
          Future.microtask(() => videoController.load(video));
        }
        return Column(children: _rowsBuilder(value));
      },
    );
  }

  List<Widget> _rowsBuilder(Node node) {
    var children = <Widget>[];
    for (var entry in node.level.elemets.entries) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 40,
          child: Row(
            spacing: 10,
            children: [
              Text(entry.key),
              Expanded(child: _rowBuilder(node, entry.key, entry.value)),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget _rowBuilder(Node node, String key, Type type) {
    if (type == String) {
      return IntryTextField(
        value: node.values[key] ?? "",
        decoration: IntryFieldDecoration.outline(context),
        onChanged: (value) => _updateNode(node, key, value),
      );
    }

    if (type == NodeType) {
      return DropdownButton(
        items:
            NodeType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
        value: node.values[key] ?? NodeType.caption,
        onChanged: (value) => _updateNode(node, key, value),
      );
    }
    if (type == LessonMode) {
      return Text("Imitation");
    }

    if (type == Map) {}
    return SizedBox();
  }

  void _updateNode(Node node, String key, Object? value) {
    var newNode = node.clone();
    newNode.values[key] = value;
    NodeController.of(context)!.value = newNode;
  }
}
