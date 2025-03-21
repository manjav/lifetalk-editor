import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/content.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  List<ParentContent> _lists = [];

  @override
  void initState() {
    _loadLists();
    super.initState();
  }

  Future<void> _loadLists() async =>
      _lists = await serviceLocator<NetConnector>().loadLists();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _lists.length,
      itemBuilder: (_, index) => _itemBuilder(_lists[index]),
    );
  }

  Widget _itemBuilder(ParentContent list) {
    Widget itemBuilder(Content group) {
      var lesson = group as ParentContent;
      return _buttonBuilder(lesson, list.title);
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SizedBox(height: 5),
          for (var group in list.children) itemBuilder(group),
        ],
      ),
    );
  }

  Widget _buttonBuilder(ParentContent lesson, String title) {
    return ElevatedButton(
      child: Text(title),
      onPressed: () async {
        await serviceLocator<NetConnector>().loadGroup(lesson);
        Navigator.pop(context, lesson.toJson());
      },
    );
  }
}
