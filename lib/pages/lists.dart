import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/node.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  List<Node> _lists = [];

  @override
  void initState() {
    _loadLists();
    super.initState();
  }

  Future<void> _loadLists() async {
    var lists = await serviceLocator<NetConnector>().loadLists();
    for (var list in lists) {
      var json = list.toJson();
      var node = Node.fromDBJson(json, level: NodeLevel.category);
      _lists.add(node);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _lists.length,
      itemBuilder: (_, index) => _itemBuilder(_lists[index]),
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
        Navigator.pop(context, list);
      },
    );
  }
}
