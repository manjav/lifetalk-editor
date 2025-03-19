import 'package:get_it/get_it.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/providers/services_provider.dart';

final serviceLocator = GetIt.instance;

void initServices() {
  serviceLocator.registerSingleton<ServicesProvider>(ServicesProvider());
  serviceLocator.registerSingleton<NetConnector>(NetConnector());
}
