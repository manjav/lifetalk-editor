import 'package:flutter/material.dart';
import 'package:lifetalk_editor/pages/locales.dart';
import 'package:lifetalk_editor/providers/fork.dart';
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
      valueListenable: ForkController.of(context)!,
      builder: (context, value, child) {
        if (value == null) return SizedBox();
        var media = value.findMediaSerie();
        if (media.isNotEmpty) {
          final videoController = YoutubePlayerController.of(context)!;
          if (videoController.value.metaData.videoId != media) {
            Future.microtask(() => videoController.load(media));
          }
        }
        return Column(
          children: _rowsBuilder(value),
          mainAxisSize: MainAxisSize.max,
        );
      },
    );
  }

  List<Widget> _rowsBuilder(Fork fork) {
    var children = <Widget>[];
    for (var entry in fork.level.elemets.entries) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: _rowBuilder(fork, entry.key, entry.value),
        ),
      );
    }
    return children;
  }

  Widget _rowBuilder(Fork fork, String key, Type type) {
    if (type == String) {
      String text = fork.values[key] ?? "";
      return _rowCreator(
        key,
        TextField(
          textDirection: text.getDirection(),
          controller: TextEditingController(text: text),
          onSubmitted: (text) => fork.values[key] = text,
        ),
      );
    }
    if (type == int) {
      int value = fork.values[key] ?? 0;
      return _rowCreator(
        key,
        TextField(
          controller: TextEditingController(text: value.toString()),
          onSubmitted: (text) => fork.values[key] = int.parse(text),
        ),
      );
    }

    if (type == ForkType) {
      return _rowCreator(
        key,
        DropdownButton(
          items:
              ForkType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.name.toPascalCase()),
                    ),
                  )
                  .toList(),
          value: fork.values[key] ?? ForkType.caption,
          onChanged: (value) => _updateNode(fork, key, value),
        ),
      );
    }
    if (type == LessonMode) {
      return Text("Imitation");
    }

    if (type == Map) {
      return _rowCreator(key, LocaleButton(fork, key));
    }
    return SizedBox();
  }

  Widget _rowCreator(String title, Widget child) {
    return Row(
      spacing: 20,
      children: [Text(title.toPascalCase()), Expanded(child: child)],
    );
  }

  void _updateNode(Fork node, String key, Object? value) {
    var newNode = node.clone();
    newNode.values[key] = value;
    ForkController.of(context)!.value = newNode;
  }
}
