import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/services_provider.dart';

class ListsPage extends StatefulWidget {
  const ListsPage({super.key});

  @override
  State<ListsPage> createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  @override
  Widget build(BuildContext context) {
    final lists = serviceLocator<ServicesProvider>().lists.values.toList();
    return ListView.builder(
      itemBuilder: (_, index) => _itemBuilder(lists[index]),
      itemCount: lists.length,
    );
  }

  Widget _itemBuilder(Map list) {
    final groups = list["groups"].values.toList();
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SizedBox(height: 5),
          for (var group in groups)
            _buttonBuilder(
              group,
              group["title"] != "" ? group["title"] : list["title"],
            ),
        ],
      ),
    );
  }

  Widget _buttonBuilder(Map group, String title) {
    return ElevatedButton(
      child: Text(title),
      onPressed: () async {
        var text = await rootBundle.loadString("assets/texts/new.json");
        final lesson = jsonDecode(text);
        Navigator.pop(context, lesson);
      },
    );
  }
}
