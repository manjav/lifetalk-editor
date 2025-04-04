import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:lifetalk_editor/managers/device_info.dart';
import 'package:lifetalk_editor/managers/service.dart';
import 'package:lifetalk_editor/providers/content.dart';
import 'package:lifetalk_editor/providers/responses.dart';
import 'package:lifetalk_editor/utils/extension.dart';
import 'package:nakama/nakama.dart';

class NetConnector extends IService {
  Session? _session;
  Type typeOf<T>() => T;
  NakamaGrpcClient? _nakamaClient;
  final Map<String, DateTime> _rpcTimes = {};

  @override
  initialize({List<Object>? args}) async {
    _session = await connect();
    super.initialize(args: args);
  }

  // Connect to nakama server
  Future<Session> connect() async {
    _nakamaClient = NakamaGrpcClient(
      host: "94.130.184.186",
      port: 3359,
      serverKey: "defaultkey",
      ssl: false,
    );

    final timezone = DateTime.now().timeZoneOffset.inSeconds;
    final location = await FlutterTimezone.getLocalTimezone();
    const store = "None";
    final data = {
      "store": store,
      "location": location,
      "timezone": "$timezone",
      "latestVersion": DeviceInfo.buildNumber,
      "displayName":
          "u_${DeviceInfo.model}_${location.split("/")[1]}_${StringExtensions.getRandomString(2)}",
      "device":
          '{"model":"${DeviceInfo.model}", "osVersion":"${DeviceInfo.osVersion}", "baseVersion":"${DeviceInfo.baseVersion}"}',
    };

    try {
      var session = await _nakamaClient!.authenticateDevice(
        deviceId: DeviceInfo.adId,
        vars: data,
      );
      return session;
    } catch (e) {
      debugPrint(e.toString());
      throw SkeletonException(StatusCode.UNKNOWN_ERROR, "Lost Connection!");
    }
  }

  Future<void> sessionRefresh() async {
    _session = await connect();
  }

  Future<T> rpc<T>(String id, {Map? params}) async {
    /// Frequent RPC avoidance
    final now = DateTime.now();
    final diff = now.difference(_rpcTimes[id] ?? DateTime(1)).inMilliseconds;
    // print("1 $diff $id ${_session!.expiresAt}");
    if (diff > 0 && diff < 1500) {
      debugPrint("Frequent RPC $id");
      Type type = typeOf<T>();
      if (type.toString() == "List<dynamic>") return [] as T;
      if (type.toString() == "Map<dynamic, dynamic>") return {} as T;
      return null as T;
    }
    params ??= {};
    // params["remoteConfigs"] = serviceLocator<Trackers>().remoteConfigs;
    try {
      var data = await _nakamaClient!.rpc(
        session: _session!,
        id: id,
        payload: jsonEncode(params),
      );
      // Just log for loading data
      if (id == "account_init") {
        log(data);
      }
      var result = json.decode(data!);
      var status = (result["status"] as int).toStatus();
      if (status == StatusCode.SUCCESS) {
        _rpcTimes[id] = now;
        return result["data"];
      } else {
        throw SkeletonException(status, result["message"]);
      }
    } on grpc.GrpcError catch (e) {
      final code = e.code.toStatus();
      var diff = now.difference(_rpcTimes[id] ?? DateTime(1)).inMilliseconds;
      if (code == StatusCode.UNAUTHENTICATED && diff > 0) {
        // print("2 $diff $id ${_session!.expiresAt}");
        _rpcTimes[id] = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch + 10000,
        );
        await sessionRefresh();
        await Future.delayed(Duration(seconds: 1));
        return await rpc(id, params: params);
      } else {
        throw SkeletonException(code, e.message ?? "", e.rawResponse);
      }
    } catch (e) {
      throw SkeletonException(StatusCode.UNKNOWN_ERROR, e.toString());
    }
  }

  Future<ParentContent> loadGroup(String id, Map data) async {
    final result = await rpc<List<dynamic>>(
      "content_contents",
      params: {"groupId": id, "editMode": true},
    );
    var group = ParentContent.create(null, ContentType.group, id, data);
    Content.createGroups(group, result, ContentType.serie);
    return group;
  }
}
