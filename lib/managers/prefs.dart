import 'package:lifetalk_editor/managers/service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs extends IService {
  static SharedPreferences? _instance;
  static var tutorStep = 0;
  static bool get inTutorial => tutorStep < TutorSteps.fine.value;

  @override
  initialize({List<Object>? args}) async {
    _instance = await SharedPreferences.getInstance();
    if (Pref.username.getString().isEmpty) {
      Pref.music.setBool(true);
      Pref.sfx.setBool(true);
    }
    tutorStep = Pref.tutorStep.getInt();
    Pref.session.increase(1);
    super.initialize();
  }

  static bool contains(String key) => _instance!.containsKey(key);

  static String getString(String key, {String defaultValue = ""}) =>
      _instance!.getString(key) ?? defaultValue;
  static String setString(String key, String value) {
    _instance!.setString(key, value);
    return value;
  }

  static bool getBool(String key, {bool defaultValue = false}) =>
      _instance!.getBool(key) ?? defaultValue;
  static bool setBool(String key, bool value) {
    _instance!.setBool(key, value);
    return value;
  }

  static int getInt(String key, {int defaultValue = 0}) =>
      _instance!.getInt(key) ?? defaultValue;
  static int setInt(String key, int value) {
    _instance!.setInt(key, value);
    return value;
  }

  static int increase(String key, int value) {
    if (value == 0) return 0;
    var newValue = getInt(key) + value;
    setInt(key, newValue);
    return newValue;
  }
}

enum Pref {
  sfx,
  music,
  rating,
  session,
  username,
  tutorStep,
  updatePassed,
  swipeHintShown,
}

extension PrefExtension on Pref {
  bool get isExists => Prefs.contains(name);

  int setInt(int value) => Prefs.setInt(name, value);
  int getInt({int defaultValue = 0}) =>
      Prefs.getInt(name, defaultValue: defaultValue);
  int increase(int value) => Prefs.increase(name, value);

  String setString(String value) => Prefs.setString(name, value);
  String getString({String defaultValue = ""}) =>
      Prefs.getString(name, defaultValue: defaultValue);

  bool setBool(bool value) => Prefs.setBool(name, value);
  bool getBool({bool defaultValue = false}) =>
      Prefs.getBool(name, defaultValue: defaultValue);
}

enum TutorSteps { welcome, fine }

extension PTutorStapsExtension on TutorSteps {
  int get value => switch (this) {
    TutorSteps.welcome => 0,
    TutorSteps.fine => 30,
  };

  void commit([bool force = false]) {
    if (!force && value <= Prefs.tutorStep) return;
    if (value % 10 == 0) {
      Pref.tutorStep.setInt(value);
    }
    Prefs.tutorStep = value;
  }
}
