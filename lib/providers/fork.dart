import 'package:flutter/material.dart';

class Fork {
  static const localeNames = [
    "en",
    "es",
    "pt",
    "fa",
    "tr",
    "fr",
    "it",
    "pl",
    "cs",
    "ru",
    "ko",
    "ja",
    "vi",
    "th",
    "zh",
    "ar",
  ];
  final Fork? parent;
  List<Fork>? children;
  ForkLevel level = ForkLevel.lesson;
  Map<String, dynamic> values = {};
  Fork({this.parent, this.children, this.level = ForkLevel.category});

  /// Returns the index of this fork in its parent
  int get index {
    if (values.containsKey("index")) {
      return values["index"];
    }
    return parent == null ? 0 : parent!.children!.indexOf(this);
  }

  /// Returns the id of this fork
  String get id {
    if (values.containsKey("id")) {
      return values["id"];
    }
    if (parent == null) {
      return "$index";
    }
    return "${parent!.id}_$index";
  }

  /// Returns the type of this fork
  ForkType get type => values["type"];

  /// Remove this fork from its parent
  void delete() => parent?.children?.remove(this);

  /// Clone this fork
  Fork clone({Fork? overrideParent}) {
    var fork = Fork(
      parent: overrideParent ?? parent,
      children: children,
      level: level,
    );
    for (var e in values.entries) {
      fork.values[e.key] = e.value;
    }
    return fork;
  }

  /// Convert this fork to json
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

  static Fork fromDBJson(
    Map<String, dynamic> map, {
    Fork? parent,
    ForkLevel level = ForkLevel.lesson,
  }) {
    var fork = Fork(parent: parent, level: level);
    for (var entry in map.entries) {
      if (entry.key == "children") {
        fork.children =
            (entry.value as List)
                .map(
                  (e) => Fork.fromDBJson(
                    e,
                    parent: fork,
                    level: fork.level.childLevel!,
                  ),
                )
                .toList();
      } else {
        if (entry.key == "type") {
          fork.values[entry.key] = ForkType.valuesByName(entry.value);
        } else {
          fork.values[entry.key] = entry.value;
        }
      }
    }
    return fork;
  }

  /// Find media of current serie
  String findMediaSerie() {
    if (!values.containsKey("media")) {
      if (parent == null) return "";
      return parent!.findMediaSerie();
    }
    String media = values["media"] ?? "";
    if (media.contains("*")) {
      media = media.split("*")[0];
    }
    return media;
  }
}

///  Returns the level of this fork
enum ForkLevel {
  category,
  lesson,
  serie,
  slide,
  end;

  /// Returns the child level of this fork
  ForkLevel? get childLevel {
    final values = ForkLevel.values;
    return index >= values.length - 1 ? null : values[index + 1];
  }

  /// Returns the parent level of this fork
  ForkLevel? get parentLevel {
    final values = ForkLevel.values;
    return index <= 1 ? null : values[index - 1];
  }

  /// Returns the elements of this fork level
  Map<String, Type> get elemets {
    return switch (this) {
      ForkLevel.category => {
        "id": String,
        "titles": Map,
        "subtitles": Map,
        "iconUrl": String,
      },
      ForkLevel.lesson => {
        "id": String,
        "mode": LessonMode,
        "titles": Map,
        "subtitles": Map,
        "iconUrl": String,
      },
      ForkLevel.serie => {"id": String, "media": String},
      ForkLevel.end => {
        "id": String,
        "type": ForkType,
        "range": String,
        "locales": Map,
      },
      _ => {},
    };
  }
}

/// The mode of a lesson
enum LessonMode { imitation }

/// The type of a fork
enum ForkType {
  caption,
  repeat,
  station,
  wordBank;

  static ForkType valuesByName(String name) =>
      ForkType.values.firstWhere((element) => element.name == name);
}

/// A widget that exposes a [ForkController] to its descendants.
class ForkController extends InheritedWidget {
  const ForkController({
    super.key,
    required this.notifier,
    required super.child,
  });

  /// The fork that this widget is exposing.
  final ValueNotifier<Fork?> notifier;

  /// Returns the fork closest to the given context, if any.
  static ValueNotifier<Fork?>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ForkController>()
        ?.notifier;
  }

  /// Returns the fork closest to the given context.
  static ValueNotifier<Fork?>? of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No fork found in context');
    return result!;
  }

  /// Whether the exposed fork has changed.
  @override
  bool updateShouldNotify(ForkController oldWidget) =>
      notifier != oldWidget.notifier;
}
