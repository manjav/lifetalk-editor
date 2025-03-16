import 'package:flutter/material.dart';
import 'package:intry/intry.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:youtube_player_flutter/src/utils/youtube_player_controller.dart';

class InspectorView extends StatefulWidget {
  final YoutubePlayerController controller;
  final ValueNotifier<Content?> selectedContent;
  const InspectorView(this.controller, this.selectedContent, {super.key});

  @override
  State<InspectorView> createState() => _InspectorViewState();
}

class _InspectorViewState extends State<InspectorView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.selectedContent,
      builder: (context, value, child) {
        if (value == null) return SizedBox();
        return Column(children: _rowsBuilder(value.level.elemets));
      },
    );
  }

  List<Widget> _rowsBuilder(Map<String, Type> elemets) {
    var children = <Widget>[];
    for (var entry in elemets.entries) {
      children.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 40,
          child: Row(
            spacing: 10,
            children: [
              Text(entry.key),
              Expanded(child: _rowBuilder(entry.key, entry.value)),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget _rowBuilder(String key, Type type) {
    if (type == String) {
      return IntryTextField(
        value: widget.selectedContent.value!.values[key] ?? "",
        decoration: IntryFieldDecoration.outline(context),
        onChanged: (value) => _updateContent(key, value),
      );
    }

    if (type == ContentType) {
      return DropdownButton(
        items:
            ContentType.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
        value: widget.selectedContent.value!.values[key] ?? ContentType.caption,
        onChanged: (value) => _updateContent(key, value),
      );
    }
    if (type == LessonMode) {
      return Text("Imitation");
    }

    if (type == Map) {}
    return SizedBox();
  }

  void _updateContent(String key, Object? value) {
    var content = widget.selectedContent.value!.clone();
    content.values[key] = value;
    widget.selectedContent.value = content;
  }
}
