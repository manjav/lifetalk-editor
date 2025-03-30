import 'package:flutter/material.dart';
import 'package:lifetalk_editor/providers/fork.dart';
import 'package:lifetalk_editor/utils/extension.dart';

class LocalesWidget extends StatefulWidget {
  final Fork fork;
  final String name;
  LocalesWidget(this.fork, this.name, {super.key});

  @override
  State<LocalesWidget> createState() => _LocalesWidgetState();
}

class _LocalesWidgetState extends State<LocalesWidget> {
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
              children: [
                Text(
                  widget.name.toPascalCase(),
                  style: TextStyle(fontSize: 14),
                ),
                Expanded(child: SizedBox()),
                IconButton(
                  icon: Icon(Icons.dynamic_feed_sharp, size: 18),
                  onPressed: () => _sameFill(context),
                ),
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
                          .map(
                            (e) => MapEntry(
                              e,
                              widget.fork.values[widget.name]?[e] ?? "",
                            ),
                          )
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
                                if (!widget.fork.values.containsKey(
                                  widget.name,
                                )) {
                                  widget.fork.values[widget.name] = {};
                                }
                                widget.fork.values[widget.name][localeName] =
                                    text;
                                var newFork = widget.fork.clone();
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

  void _sameFill(BuildContext context) {
    for (var code in Fork.localeNames) {
      if (code == "en") continue;
      widget.fork.values[widget.name][code] =
          widget.fork.values[widget.name]["en"];
    }
    ForkController.of(context)!.value = widget.fork.clone();
    setState(() {});
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
