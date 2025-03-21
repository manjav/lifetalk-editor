import 'package:flutter/material.dart';

class Node {
  final Node? parent;
  List<Node>? children;
  NodeLevel level = NodeLevel.lesson;
  Map<String, dynamic> values = {};
  Node({this.parent, this.children}) {
    level = parent?.level.childLevel ?? NodeLevel.lesson;
  }

  /**
   * Returns the index of this node in its parent
   */
  int get index => parent == null ? 0 : parent!.children!.indexOf(this);

  /**
   * Returns the id of this node
   */
  String get id {
    if (parent == null) {
      return "$index";
    }
    return "${parent!.id}_$index";
  }

  /**
   * Remove this node from its parent  
   */
  void delete() => parent?.children?.remove(this);

  /**
   * Clone this node
   */
  Node clone() {
    return Node(parent: parent, children: children)..values = values;
  }

  /**
   * Convert this node to json
   */
  Map toJson() {
    var json = <String, dynamic>{};
    if (children != null) {
      json["children"] = children!.map((e) => e.toJson()).toList();
    }
    if (values.isNotEmpty) {
      for (var entry in values.entries) {
        if (entry.value is Enum) {
          json[entry.key] = (entry.value as Enum).name;
        } else {
          json[entry.key] = entry.value;
        }
      }
    }
    return json;
  }

  static Node fromJson(Map<String, dynamic> map, {Node? parent}) {
    var node = Node(parent: parent);
    for (var entry in map.entries) {
      if (entry.key == "children") {
        node.children =
            (entry.value as List)
                .map((e) => Node.fromJson(e, parent: node))
                .toList();
      } else {
        if (entry.key == "type") {
          node.values[entry.key] = NodeType.valuesByName(entry.value);
        } else {
          node.values[entry.key] = entry.value;
        }
      }
    }
    // node.values = <String, dynamic>{};
    return node;
  }
}

/** 
 *  Returns the level of this node
 */
enum NodeLevel {
  category,
  lesson,
  serie,
  slide,
  end;

  /**
 * Returns the child level of this node
 */
  NodeLevel? get childLevel {
    final values = NodeLevel.values;
    return index >= values.length - 1 ? null : values[index + 1];
  }

  /**
 * Returns the parent level of this node
 */
  NodeLevel? get parentLevel {
    final values = NodeLevel.values;
    return index <= 1 ? null : values[index - 1];
  }

  /**
 * Returns the elements of this node level
 */
  Map<String, Type> get elemets {
    return switch (this) {
      NodeLevel.category => {
        "title": String,
        "subtitle": String,
        "iconUrl": String,
      },
      NodeLevel.lesson => {
        "mode": LessonMode,
        "title": String,
        "subtitle": String,
        "iconUrl": String,
      },
      NodeLevel.serie => {"media": String},
      NodeLevel.end => {
        "type": NodeType,
        "en": String,
        "es": String,
        "pt": String,
        "fa": String,
        "range": String,
      },
      _ => {},
    };
  }
}

/// The mode of a lesson
enum LessonMode { imitation }

/// The type of a node
enum NodeType {
  caption,
  repeat,
  station,
  wordBank;

  static NodeType valuesByName(String name) =>
      NodeType.values.firstWhere((element) => element.name == name);
}

/// A widget that exposes a [NodeController] to its descendants.
class NodeController extends InheritedWidget {
  const NodeController({
    super.key,
    required this.notifier,
    required super.child,
  });

  /// The node that this widget is exposing.
  final ValueNotifier<Node?> notifier;

  /// Returns the node closest to the given context, if any.
  static ValueNotifier<Node?>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<NodeController>()
        ?.notifier;
  }

  /// Returns the node closest to the given context.
  static ValueNotifier<Node?>? of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No node found in context');
    return result!;
  }

  /// Whether the exposed node has changed.
  @override
  bool updateShouldNotify(NodeController oldWidget) =>
      notifier != oldWidget.notifier;
}
