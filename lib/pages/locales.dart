import 'package:flutter/material.dart';
import 'package:lifetalk_editor/providers/node.dart';
import 'package:lifetalk_editor/utils/extension.dart';

class LocalesWidget extends StatelessWidget {
  final Node node;
  final String name;
  LocalesWidget(this.node, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    var updated = false;
    return Material(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name.toPascalCase(), style: TextStyle(fontSize: 14)),
                IconButton(
                  icon: Icon(Icons.close, size: 18),
                  onPressed: () => Navigator.pop(context, updated),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 480,
              child: StatefulBuilder(
                builder: (context, setState) {
                  final values =
                      Node.localeNames
                          .map((e) => MapEntry(e, node.values[name][e] ?? ""))
                          .toList();

                  return ListView.builder(
                    padding: EdgeInsets.all(0),
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      String localeName = values[index].key;
                      String text = values[index].value ?? "";
                      return Row(
                        spacing: 30,
                        children: [
                          Text(localeName.toUpperCase()),
                          Expanded(
                            child: TextField(
                              textDirection: text.getDirection(),
                              controller: TextEditingController(text: text),
                              onSubmitted: (text) {
                                node.values[name][localeName] = text;
                                var newNode = node.clone();
                                setState(() {});
                                NodeController.of(context)!.value = newNode;
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class LocaleButton extends StatelessWidget {
  Node node;
  String name;
  LocaleButton(this.node, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => LocalesWidget(node, name),
        );
      },
      child: Text(node.values[name]?["en"] ?? ""),
    );
  }
}
