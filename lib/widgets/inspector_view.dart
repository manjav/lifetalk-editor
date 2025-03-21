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
        return Column(
          children: _rowsBuilder(value),
          mainAxisSize: MainAxisSize.max,
        );
      },
    );
  }

  List<Widget> _rowsBuilder(Node node) {
    var children = <Widget>[];
    for (var entry in node.level.elemets.entries) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _rowBuilder(node, entry.key, entry.value),
        ),
      );
    }
    return children;
  }

  Widget _rowBuilder(Node node, String key, Type type) {
    if (type == String) {
      return _rowCreator(
        key,
        IntryTextField(
          value: node.values[key] ?? "",
          decoration: IntryFieldDecoration.outline(context),
          onChanged: (value) => _updateNode(node, key, value),
        ),
      );
    }

    if (type == NodeType) {
      return _rowCreator(
        key,
        DropdownButton(
          items:
              NodeType.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
          value: node.values[key] ?? NodeType.caption,
          onChanged: (value) => _updateNode(node, key, value),
        ),
      );
    }
    if (type == LessonMode) {
      return Text("Imitation");
    }

    if (type == Map) {
      final map = node.values[key] as Map;
      final values =
          Node.localeNames.map((e) => MapEntry(e, map[e] ?? "")).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(key),
          SizedBox(
            height: 480,
            child: ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: values.length,
              itemBuilder: (context, index) {
                return _rowCreator(
                  values[index].key,
                  IntryTextField(
                    value: values[index].value ?? "",
                    decoration: IntryFieldDecoration.outline(context),
                    onChanged: (text) {
                      map[values[index].key] = text;
                      _updateNode(node, key, map);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return SizedBox();
  }

  Widget _rowCreator(String title, Widget child) {
    return Row(spacing: 10, children: [Text(title), Expanded(child: child)]);
  }

  void _updateNode(Node node, String key, Object? value) {
    var newNode = node.clone();
    newNode.values[key] = value;
    NodeController.of(context)!.value = newNode;
  }
}
