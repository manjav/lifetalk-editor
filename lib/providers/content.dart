import 'package:flutter/material.dart';

class Content {
  final Content? parent;
  List<Content>? children;
  ContentLevel level = ContentLevel.lesson;
  Map<String, dynamic> values = {};
  Content({this.parent, this.children}) {
    level = parent?.level.childLevel ?? ContentLevel.lesson;
  }

  /**
   * Returns the index of this content in its parent
   */
  int get index => parent == null ? 0 : parent!.children!.indexOf(this);

  /**
   * Returns the id of this content
   */
  String get id {
    if (parent == null) {
      return "$index";
    }
    return "${parent!.id}_$index";
  }

  /**
   * Remove this content from its parent  
   */
  void delete() => parent?.children?.remove(this);

  /**
   * Clone this content
   */
  Content clone() {
    return Content(parent: parent, children: children)..values = values;
  }

  /**
   * Convert this content to json
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
}

/** 
 *  Returns the level of this content
 */
enum ContentLevel {
  category,
  lesson,
  serie,
  slide,
  end;

  /**
 * Returns the child level of this content
 */
  ContentLevel? get childLevel {
    final values = ContentLevel.values;
    return index >= values.length - 1 ? null : values[index + 1];
  }

  /**
 * Returns the parent level of this content
 */
  ContentLevel? get parentLevel {
    final values = ContentLevel.values;
    return index <= 1 ? null : values[index - 1];
  }

  /**
 * Returns the elements of this content level
 */
  Map<String, Type> get elemets {
    return switch (this) {
      ContentLevel.category => {
        "title": String,
        "subtitle": String,
        "iconUrl": String,
      },
      ContentLevel.lesson => {
        "mode": LessonMode,
        "title": String,
        "subtitle": String,
        "iconUrl": String,
      },
      ContentLevel.serie => {"videoUrl": String},
      ContentLevel.end => {
        "type": ContentType,
        "en": String,
        "es": String,
        "pt": String,
        "fa": String,
        "media": String,
      },
      _ => {},
    };
  }
}

/// The mode of a lesson
enum LessonMode { imitation }

/// The type of a content
enum ContentType { caption, repeat, wordBank }

/// A widget that exposes a [ContentController] to its descendants.
class ContentController extends InheritedWidget {
  const ContentController({
    super.key,
    required this.notifier,
    required super.child,
  });

  /// The content that this widget is exposing.
  final ValueNotifier<Content?> notifier;

  /// Returns the content closest to the given context, if any.
  static ValueNotifier<Content?>? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ContentController>()
        ?.notifier;
  }

  /// Returns the content closest to the given context.
  static ValueNotifier<Content?>? of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No content found in context');
    return result!;
  }

  /// Whether the exposed content has changed.
  @override
  bool updateShouldNotify(ContentController oldWidget) =>
      notifier != oldWidget.notifier;
}
