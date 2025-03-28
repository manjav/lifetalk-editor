import 'package:flutter/material.dart';
import 'package:lifetalk_editor/providers/fork.dart';
import 'package:lifetalk_editor/utils/extension.dart';

class LocalesWidget extends StatelessWidget {
  final Fork fork;
  final String name;
  LocalesWidget(this.fork, this.name, {super.key});

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
                      Fork.localeNames
                          .map((e) => MapEntry(e, fork.values[name]?[e] ?? ""))
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
                                if (!fork.values.containsKey(name)) {
                                  fork.values[name] = {};
                                }
                                fork.values[name][localeName] = text;
                                var newFork = fork.clone();
                                setState(() {});
                                ForkController.of(context)!.value = newFork;
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
  Fork fork;
  String name;
  LocaleButton(this.fork, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) => LocalesWidget(fork, name),
        );
      },
      child: Text(fork.values[name]?["en"] ?? ""),
    );
  }
}
