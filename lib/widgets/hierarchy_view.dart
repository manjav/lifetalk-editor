import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/pages/lists.dart';
import 'package:lifetalk_editor/providers/fork.dart';
import 'package:lifetalk_editor/theme/theme.dart';

class HierarchyView extends StatefulWidget {
  const HierarchyView({super.key});

  @override
  State<HierarchyView> createState() => _HierarchyViewState();
}

class _HierarchyViewState extends State<HierarchyView> {
  List<Fork> roots = [Fork()];
  TreeController<Fork>? _treeController;

  @override
  void initState() {
    _treeController = TreeController<Fork>(
      roots: roots,
      childrenProvider: (Fork fork) => fork.children ?? [],
    );
    _treeController!.toggleExpansion(roots.first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_treeController == null) return SizedBox();
    final nodeController = ForkController.of(context)!;
    return Row(
      children: [
        Expanded(
          child: AnimatedTreeView<Fork>(
            treeController: _treeController!,
            nodeBuilder: (BuildContext context, TreeEntry<Fork> entry) {
              var text = entry.node.level.name;
              if (entry.node.values.isNotEmpty) {
                text += " [${entry.node.values.keys.join(", ")}]";
              }
              return InkWell(
                onTap: () {
                  _treeController!.rebuild();
                  nodeController.value = entry.node;
                },
                child: TreeIndentation(
                  entry: entry,
                  child: Container(
                    color:
                        nodeController.value == entry.node
                            ? Colors.white24
                            : Colors.transparent,
                    child: Text(text),
                  ),
                ),
              );
            },
          ),
        ),
        Column(
          children: [
            _nodeButton(Icons.add, () {
              final fork = nodeController.value!;
              if (fork.level == ForkLevel.end) {
                return;
              }
              if (fork.children == null) {
                fork.children = [];
              }
              var newNode = Fork(parent: fork);
              if (fork.level == ForkLevel.slide) {
                newNode.values["locales"] = {};
              }
              fork.children?.add(newNode);
              _treeController!.rebuild();
              _treeController!.expand(fork);
            }),
            _nodeButton(Icons.delete, () {
              nodeController.value!.delete();
              nodeController.value = null;
              _treeController!.rebuild();
            }),
            _nodeButton(Icons.folder_open, () async {
              var result = await showDialog(
                context: context,
                builder: (context) => ListsPage(),
              );
              if (result == null) return;

              roots.clear();
              roots.add(result);
              _treeController = TreeController<Fork>(
                roots: roots,
                childrenProvider: (Fork fork) => fork.children ?? [],
              );
              _treeController?.expandAll();
              setState(() {});
            }),
            _nodeButton(Icons.save, () {
              if (nodeController.value == null) return;
              final lesson = _treeController!.roots.first;
              if (lesson.level != ForkLevel.lesson) {
                print("Lesson not found!");
                return;
              }
              final json = lesson.toJson();
              final list = lesson.parent!;
              json["categoryId"] = list.id;
              json["categoryTitles"] = list.values["titles"];
              json["categorySubtitles"] = list.values["subtitles"];
              serviceLocator<NetConnector>().rpc(
                "content_group_set",
                params: json,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _nodeButton(IconData icon, Function() onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: ElevatedButton(
        style: Themes.buttonStyle(),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
