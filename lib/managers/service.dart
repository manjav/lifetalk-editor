import 'package:lifetalk_editor/managers/logger.dart';

abstract class IService with ILogger {
  bool isInitialized = false;
  initialize({List<Object>? args}) {
    isInitialized = true;
    log("=> Service $runtimeType initialized.");
  }
}
