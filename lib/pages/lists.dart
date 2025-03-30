import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:lifetalk_editor/providers/fork.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  List<Fork> _lists = [];
  Map<String, Fork> _updatedLessons = {};

  @override
  void initState() {
    _loadLists();
    super.initState();
  }

  Future<void> _loadLists() async {
    var listMap = await serviceLocator<NetConnector>().rpc(
      "content_categories",
      params: {"editMode": true},
    );
    _lists.clear();
    _updatedLessons.clear();
    var contents = Content.createLists(listMap);
    for (var list in listMap.entries) {
      for (var e in list.value["groups"].entries) {
        if (!e.value.containsKey("children")) continue;
        var fork = Fork.fromDBJson(e.value, level: ForkLevel.lesson);
        _updatedLessons[e.key] = fork;
      }
    }

    for (var list in contents) {
      var json = list.toJson();
      var fork = Fork.fromDBJson(json, level: ForkLevel.category);
      for (var i = 0; i < fork.children!.length; i++) {
        final id = fork.children![i].id;
        if (_updatedLessons.containsKey(id)) {
          fork.children![i] = _updatedLessons[id]!.clone(overrideParent: fork);
        }
      }
      _lists.add(fork);
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

  Widget _itemBuilder(Fork list) {
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
              Text(list.values["id"]),
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

  Widget _buttonBuilder(Fork list, Fork lesson) {
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
          Text(lesson.id),
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
        var newNode = Fork.fromDBJson(group.toJson());
        lesson.children = newNode.children;
        Navigator.pop(context, lesson);
      },
    );
  }
}
