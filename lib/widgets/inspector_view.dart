import 'package:flutter/material.dart';
import 'package:lifetalk_editor/pages/locales.dart';
import 'package:lifetalk_editor/providers/node.dart';
import 'package:lifetalk_editor/utils/extension.dart';
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
      String text = node.values[key] ?? "";
      return _rowCreator(
        key,
        TextField(
          textDirection: text.getDirection(),
          controller: TextEditingController(text: text),
          onSubmitted: (text) {
            node.values[key] = text;
            // setState(() {});
          },
        ),
      );
    }

    if (type == NodeType) {
      return _rowCreator(
        key,
        DropdownButton(
          items:
              NodeType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toPascalCase()),
                    ),
                  )
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
      return _rowCreator(key, LocaleButton(node, key));
    }
    return SizedBox();
  }

  Widget _rowCreator(String title, Widget child) {
    return Row(
      spacing: 20,
      children: [Text(title.toPascalCase()), Expanded(child: child)],
    );
  }

  void _updateNode(Node node, String key, Object? value) {
    var newNode = node.clone();
    newNode.values[key] = value;
    NodeController.of(context)!.value = newNode;
  }
}
