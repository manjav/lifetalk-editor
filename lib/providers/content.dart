class Content {
  final Content? parent;
  List<Content>? children;
  ContentLevel level = ContentLevel.lesson;
  Map<String, dynamic> values = {};
  Content({this.parent, this.children}) {
    level = parent?.level.childLevel ?? ContentLevel.lesson;
  }

  void delete() => parent?.children?.remove(this);

  Content clone() {
    return Content(parent: parent, children: children)..values = values;
  }

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

enum ContentLevel {
  category,
  lesson,
  serie,
  slide,
  end;

  ContentLevel? get childLevel {
    final values = ContentLevel.values;
    return index >= values.length - 1 ? null : values[index + 1];
  }

  ContentLevel? get parentLevel {
    final values = ContentLevel.values;
    return index <= 1 ? null : values[index - 1];
  }

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
        "value": String,
        "media": String,
      },
      _ => {},
    };
  }
}

enum LessonMode { imitation }

enum ContentType { caption, repeat, wordBank }
