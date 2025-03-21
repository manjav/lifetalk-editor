import 'package:flutter/material.dart';
import 'package:lifetalk_editor/managers/device_info.dart';
import 'package:lifetalk_editor/managers/net_connector.dart';
import 'package:lifetalk_editor/managers/service_locator.dart';
import 'package:lifetalk_editor/providers/responses.dart';

enum ServiceStatus { none, initialize, complete, changeTab, punch, error }

class ServiceState {
  final dynamic data;
  final ServiceStatus status;
  final SkeletonException? exception;

  ServiceState(this.status, {this.data, this.exception});
}

class ServicesProvider extends ChangeNotifier {
  ServiceState state = ServiceState(ServiceStatus.none);
  Map<String, dynamic> lists = {};

  Future<ServiceState> initialize() async {
    await DeviceInfo.initialize();
    try {
      lists = await serviceLocator<NetConnector>().initialize();
      changeState(ServiceStatus.complete, data: lists);
    } on SkeletonException catch (e) {
      changeState(ServiceStatus.error, exception: e);
    }
    return state;
  }

  void changeState(
    ServiceStatus state, {
    SkeletonException? exception,
    dynamic data,
  }) {
    this.state = ServiceState(state, data: data, exception: exception);
    notifyListeners();
  }
}
