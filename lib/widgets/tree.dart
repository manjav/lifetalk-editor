import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lifetalk_editor/providers/content.dart';

class TreeWidget extends StatefulWidget {
  const TreeWidget({super.key});

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget> {
  List<Content> roots = [Content()];
  TreeController<Content>? _treeController;

  @override
  void initState() {
    roots.first.children = List.generate(
      3,
      (i) => Content(parent: roots.first),
    );
    _treeController = TreeController<Content>(
      roots: roots,
      childrenProvider: (Content node) => node.children ?? [],
    );
    _treeController!.toggleExpansion(roots.first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_treeController == null) return SizedBox();
    return AnimatedTreeView<Content>(
      treeController: _treeController!,
      nodeBuilder: (BuildContext context, TreeEntry<Content> entry) {
        var text = entry.node.level.name;
        if (entry.node.values.isNotEmpty) {
          text += " [${entry.node.values.keys.join(", ")}]";
        }
        return InkWell(
          onTap: () {
            _treeController!.rebuild();
            _selectedContent.value = entry.node;
          },
          child: TreeIndentation(
            entry: entry,
            child: Container(
              color:
                  _selectedContent.value == entry.node
                      ? Colors.white24
                      : Colors.transparent,
              child: Text(text),
            ),
          ),
        );
      },
    );
  }

}
