import 'package:lifetalk_editor/utils/extension.dart';

class Content {
  int index = 0;
  final String id;
  final ParentContent? parent;
  ContentType type = ContentType.none;
  TranslationSide side = TranslationSide.none;
  Content.create(this.parent, this.id, Map map) {
    index = map["index"] ?? 0;
  }

  bool get isChat => type == ContentType.bot || type == ContentType.user;
  bool get isQuiz =>
      type == ContentType.answer ||
      type == ContentType.repeat ||
      type == ContentType.translate ||
      type == ContentType.dictation ||
      type == ContentType.wordBank ||
      type == ContentType.match ||
      type == ContentType.choices;
  bool get isStation =>
      isQuiz || type == ContentType.video || type == ContentType.youtube;

  static List<ParentContent> createAll(Map map) {
    List<ParentContent> categories = [];
    for (var entry in map.entries) {
      var category = ParentContent.create(
        null,
        ContentType.category,
        entry.key,
        entry.value,
      );

      var groups = <ParentContent>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(
          ParentContent.create(
            category,
            ContentType.group,
            gentry.key,
            gentry.value,
          ),
        );
      }
      groups.sort((a, b) => a.index - b.index);
      category.type = ContentType.category;
      category.children = groups;
      categories.add(category);
    }
    categories.sort((a, b) => a.index - b.index);
    return categories;
  }

  static void createGroups(ParentContent group, List list, ContentType type) {
    var children = <Content>[];
    if (type == ContentType.talk) {
      for (var i = 0; i < list.length; i++) {
        if (list[i]["type"] == "title") {
          group.parent!.title = list[i]["fa"];
        } else {
          String video = list[i]["en"];
          if (list[i]["type"] == "video") {
            (group.parent! as Serie).media = MediaEntry.parse(
              MediaType.video,
              "lesson_$video",
            );
          } else if (list[i]["type"] == "youtube") {
            (group.parent! as Serie).media = MediaEntry.parse(
              MediaType.video,
              "lesson_${video.split("embed/").last}",
            );
          } else {
            children.add(Talk.create(group, i, list[i]));
          }
        }
      }
    } else {
      final key = "${type.name}_index";
      var map = <int, List>{};
      for (var i = 0; i < list.length; i++) {
        final index = list[i][key];
        if (!map.containsKey(index)) {
          map[index] = [];
        }
        map[index]!.add(list[i]);
      }

      for (var entry in map.entries) {
        ParentContent child;
        if (type == ContentType.serie) {
          child = Serie.create(group, type, "${group.id}_${entry.key}", {
            "index": entry.key,
          });
        } else {
          child = ParentContent.create(
            group,
            type,
            "${group.id}_${entry.key}",
            {"index": entry.key},
          );
        }
        createGroups(child, entry.value, type.getChild());
        if (child.children.isNotEmpty) {
          children.add(child);
        }
      }
    }
    children.sort((a, b) => a.index - b.index);
    group.children = children;
  }

  Map<String, dynamic> toJson() {
    var json = <String, dynamic>{};

    if (type == ContentType.group) {
      var group = this as ParentContent;
      json["title"] = group.title;
      json["subtitle"] = group.subtitle;
      json["iconUrl"] = group.iconUrl;
    }

    if (children.isNotEmpty) {
      json["children"] = children.map((e) => e.toJson()).toList();
    }
    if (type == ContentType.serie) {
      json["media"] = (this as Serie).media?.id.substring(7);
    }
    if (this is Talk) {
      final talk = this as Talk;
      json["type"] = type.name;
      if (talk.data != null) {
        final media = talk.data as MediaEntry;
        json["range"] =
            "${(media.start * 1000).toTime()}-${((media.end ?? 0) * 1000).toTime()}";
      }
      json["locales"] = talk.locales;
    }

    return json;
  }

  List<Content> children = [];
}

class MediaEntry {
  double? end;
  double start = 0;
  String id = "";
  String url = "";
  MediaType type;
  MediaEntry(this.type, this.url, {this.start = 0, this.end, this.id = ""});
  MediaEntry.parse(this.type, this.url) {
    if (url.contains("?")) {
      final uri = Uri.parse(url);

      start = double.parse(uri.queryParameters["start"] ?? "0");
      end =
          uri.queryParameters.containsKey("end")
              ? double.parse(uri.queryParameters["end"]!)
              : null;
      id = "${uri.pathSegments.last}*${start.toTime()}-${end?.toTime() ?? ""}";
    } else {
      final parts = url.split("*");
      id = url;
      List<String> times = parts.last.split('-');
      start = times.first.parseTime();
      end = times.last.parseTime();
    }
  }
}

enum MediaType { voice, sound, video, youtube }

class ParentContent extends Content {
  int score = 0;
  int passedOrder = 100000;
  String title = "", subtitle = "", iconUrl = "", mode = "";
  Content? majority;
  ParentContent.create(
    ParentContent? parent,
    ContentType type,
    String id,
    Map map,
  ) : super.create(parent, id, map) {
    this.type = type;
    title = map["title"] ?? "";
    subtitle = map["subtitle"] ?? "";
    iconUrl = map["iconUrl"] ?? "";
    mode = map["mode"] ?? "";
  }
}

class Serie extends ParentContent {
  MediaEntry? media;
  Serie.create(super.parent, super.type, super.id, super.map) : super.create();
}

class Talk extends Content {
  dynamic data;
  int score = 0;
  Map<String, String> locales = {};
  Talk.create(ParentContent parent, int index, Map map)
    : super.create(parent, map["id"], map) {
    for (var entry in map.entries) {
      if (entry.key == "serie_index" ||
          entry.key == "slide_index" ||
          entry.key == "group_id" ||
          entry.key == "index" ||
          entry.key == "type" ||
          entry.key == "id")
        continue;
      locales[entry.key] = entry.value;
    }

    if (map["type"].endsWith("_1")) {
      type = ContentType.user;
    } else if (map["type"].endsWith("_2")) {
      type = ContentType.bot;
    } else if (map["type"].startsWith("avatar_")) {
      type = ContentType.avatar;
      // data = AvatarExpression.values.indexWhere(
      //   (e) => e.name == map["type"].substring(7),
      // );
    } else {
      var trimmed = map["type"];
      var index = trimmed.indexOf(' ');
      trimmed = trimmed.substring(0, index == -1 ? null : index);
      type = ContentType.getEnum(trimmed);

      MediaEntry? media = (parent.parent! as Serie).media;
      var args = map["type"].split(' ');
      if (args.length > 1) {
        if (args.last == "n") {
          data = 1;
        }
        // Create media talks
        if (args.last.contains('~')) {
          List<String> times = args.last.split('~');
          data = MediaEntry(
            MediaType.video,
            "",
            id: media == null ? "" : media.id,
            start: double.parse(times.first),
            end: double.parse(times.last),
          );
        } else if (args.last.contains('-')) {
          List<String> times = args.last.split('-');
          data = MediaEntry(
            MediaType.video,
            "",
            id: media == null ? "" : media.id,
            start: times.first.parseTime(),
            end: times.last.parseTime(),
          );
        }
      }
    }
  }

  TranslationSide get textSide {
    if (type == ContentType.caption ||
        (type == ContentType.translate && data > 0)) {
      return TranslationSide.native;
    }
    if (type == ContentType.repeat || type == ContentType.head) {
      return TranslationSide.target;
    }
    return TranslationSide.none;
  }
}

enum TranslationSide { none, native, target }

enum ContentType {
  none,
  category,
  group,
  slide,
  serie,
  talk,
  head,
  text,
  caption,
  repeat,
  translate,
  answer,
  dictation,
  choices,
  match,
  user,
  bot,
  image,
  video,
  youtube,
  avatar,
  uncover,
  station,
  wordBank;

  ContentType getChild() {
    return switch (this) {
      ContentType.serie => ContentType.slide,
      ContentType.slide => ContentType.talk,
      _ => none,
    };
  }

  double get micIndex => switch (this) {
    ContentType.translate => 1,
    ContentType.answer => 2,
    _ => 0,
  };

  static ContentType getEnum(String type) {
    for (var value in ContentType.values) {
      if (value.name == type) return value;
    }
    return ContentType.none;
  }
}

enum PresentMode {
  none,
  native,
  target,
  both;

  bool get hasNative => this == PresentMode.native || this == PresentMode.both;
  bool get hasTarget => this == PresentMode.target || this == PresentMode.both;
}
