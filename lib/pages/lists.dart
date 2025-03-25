import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:lifetalk_editor/providers/node.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  List<Node> _lists = [];
  Map<String, Node> _updatedLessons = {};

  @override
  void initState() {
    _loadLists();
    super.initState();
  }

  Future<void> _loadLists() async {
    var listMap = await serviceLocator<NetConnector>().loadLists();
    var contents = Content.createLists(listMap);
    _updatedLessons = <String, Node>{};
    for (var list in listMap.entries) {
      for (var e in list.value["groups"].entries) {
        if (!e.value.containsKey("children")) continue;
        var node = Node.fromDBJson(e.value, level: NodeLevel.lesson);
        _updatedLessons[e.key] = node;
      }
    }

    for (var list in contents) {
      var json = list.toJson();
      var node = Node.fromDBJson(json, level: NodeLevel.category);
      for (var i = 0; i < node.children!.length; i++) {
        final id = node.children![i].id;
        if (_updatedLessons.containsKey(id)) {
          node.children![i] = _updatedLessons[id]!.clone(overrideParent: node);
        }
      }
      _lists.add(node);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("  Lessons", style: TextStyle(fontSize: 14)),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _lists.length,
            itemBuilder: (_, index) => _itemBuilder(_lists[index]),
          ),
        ),
      ],
    );
  }

  Widget _itemBuilder(Node list) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 16,
            children: [
              Text(list.values["titles"]["en"]),
              Text(
                list.values["subtitles"]["en"],
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          for (var i = 0; i < list.children!.length; i++)
            _buttonBuilder(list, list.children![i]),
        ],
      ),
    );
  }

  Widget _buttonBuilder(Node list, Node lesson) {
    String lessonTitle =
        lesson.values["titles"].length > 0
            ? lesson.values["titles"]["en"]
            : "---";

    String lessonSubtitle =
        lesson.values["subtitles"].length > 0
            ? lesson.values["subtitles"]["en"]
            : "---";

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          _updatedLessons.containsKey(lesson.id)
              ? Colors.blueGrey
              : Colors.blue.shade900,
        ),
      ),
      child: Row(
        spacing: 16,
        children: [
          Text(lessonTitle),
          Text(lessonSubtitle, style: TextStyle(color: Colors.grey)),
        ],
      ),
      onPressed: () async {
        // Embeded group
        if (lesson.children != null) {
          Navigator.pop(context, lesson);
          return;
        }

        var group = await serviceLocator<NetConnector>().loadGroup(
          lesson.id,
          lesson.values,
        );
        var newNode = Node.fromDBJson(group.toJson());
        lesson.children = newNode.children;
        Navigator.pop(context, lesson);
      },
    );
  }
}
