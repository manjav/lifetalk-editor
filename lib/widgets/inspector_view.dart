import 'package:flutter/material.dart';
import 'package:intry/intry.dart';
import 'package:lifetalk_editor/providers/content.dart';
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
      valueListenable: ContentController.of(context)!,
      builder: (context, value, child) {
        if (value == null) return SizedBox();
        String video = value.values["videoUrl"] ?? "";
        final videoController = YoutubePlayerController.of(context)!;
        if (video.isNotEmpty &&
            videoController.value.metaData.videoId != video) {
          Future.microtask(() => videoController.load(video));
        }
        return Column(children: _rowsBuilder(value));
      },
    );
  }

  List<Widget> _rowsBuilder(Content content) {
    var children = <Widget>[];
    for (var entry in content.level.elemets.entries) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 40,
          child: Row(
            spacing: 10,
            children: [
              Text(entry.key),
              Expanded(child: _rowBuilder(content, entry.key, entry.value)),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget _rowBuilder(Content content, String key, Type type) {
    if (type == String) {
      return IntryTextField(
        value: content.values[key] ?? "",
        decoration: IntryFieldDecoration.outline(context),
        onChanged: (value) => _updateContent(content, key, value),
      );
    }

    if (type == ContentType) {
      return DropdownButton(
        items:
            ContentType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
        value: content.values[key] ?? ContentType.caption,
        onChanged: (value) => _updateContent(content, key, value),
      );
    }
    if (type == LessonMode) {
      return Text("Imitation");
    }

    if (type == Map) {}
    return SizedBox();
  }

  void _updateContent(Content content, String key, Object? value) {
    var newContent = content.clone();
    newContent.values[key] = value;
    ContentController.of(context)!.value = newContent;
  }
}
