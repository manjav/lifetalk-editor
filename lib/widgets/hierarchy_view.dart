import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:lifetalk_editor/providers/content.dart';

class HierarchyView extends StatefulWidget {
  const HierarchyView({super.key});

  @override
  State<HierarchyView> createState() => _HierarchyViewState();
}

class _HierarchyViewState extends State<HierarchyView> {
  List<Node> roots = [Node()];
  TreeController<Node>? _treeController;

  @override
  void initState() {
    _treeController = TreeController<Node>(
      roots: roots,
      childrenProvider: (Node node) => node.children ?? [],
    );
    _treeController!.toggleExpansion(roots.first);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_treeController == null) return SizedBox();
    final nodeController = NodeController.of(context)!;
    return Row(
      children: [
        Expanded(
          child: AnimatedTreeView<Node>(
            treeController: _treeController!,
            nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
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
              final node = nodeController.value!;
              if (node.level == NodeLevel.end) {
                return;
              }
              if (node.children == null) {
                node.children = [];
              }
              node.children?.add(Node(parent: node));
              _treeController!.rebuild();
              _treeController!.expand(node);
            }),
            _nodeButton(Icons.delete, () {
              nodeController.value!.delete();
              nodeController.value = null;
              _treeController!.rebuild();
            }),
          ],
        ),
      ],
    );
  }

  Widget _nodeButton(IconData icon, Function() onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Icon(icon));
  }
}
