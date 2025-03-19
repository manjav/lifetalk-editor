import 'dart:io';
import 'dart:math' as math;

import 'package:advertising_id/advertising_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifetalk_editor/managers/logger.dart';
import 'package:lifetalk_editor/managers/prefs.dart';
import 'package:lifetalk_editor/utils/extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfo {
  static double ratio = 1;
  static Size size = Size.zero;
  static double aspectRatio = 1;
  static double devicePixelRatio = 1;
  static String id = "";
  static String adId = "";
  static String model = "";
  static String osVersion = "";
  static String baseVersion = "";
  static String packageName = "";
  static String buildNumber = "";
  static String version = "";
  static String appName = "";
  static bool isPreInitialized = false;
  static Map<String, dynamic> _deviceData = {};

  static String get operatingSystem => isWeb ? "web" : Platform.operatingSystem;
  static bool get isWeb => kIsWeb;
  static bool get isIOS => operatingSystem == "ios";
  static bool get isAndroid => operatingSystem == "android";
  static bool get isMobile => isAndroid || isIOS;
  static bool get isLinux => operatingSystem == "linux";
  static bool get isMacOS => operatingSystem == "macos";
  static bool get isWindows => operatingSystem == "windows";

  static Future<bool> preInitialize(
    BuildContext context, [
    bool forced = false,
  ]) async {
    if (!forced && isPreInitialized) return false;
    try {
      // Get screen info
      var q = MediaQuery.of(context);
      size = q.size;
      devicePixelRatio = q.devicePixelRatio;
      var width = math.min(size.width, size.height);
      var height = math.max(size.width, size.height);
      ratio = width / 390; // Comes from figma design
      aspectRatio = width / height;
    } catch (e) {
      debugPrint("$e");
    }
    // Find advertise id
    await _findAdId();

    // Get app info
    try {
      var packageInfo = await PackageInfo.fromPlatform();
      packageName = packageInfo.packageName;
      buildNumber = packageInfo.buildNumber;
      version = packageInfo.version;
      appName = packageInfo.appName;
    } catch (e) {
      debugPrint("$e");
    }
    isPreInitialized = true;
    return true;
  }

  static Future<void> initialize() async {
    ILogger.slog(
      DeviceInfo,
      "◢◤◢◤◢◤◢◤◢◤◢ ${DeviceInfo.size} ${DeviceInfo.devicePixelRatio} $ratio ◢◤◢◤◢◤◢◤◢◤◢",
    );
    // Get device info
    var deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (isWeb) {
        _deviceData = _readWebBrowserInfo(
          await deviceInfoPlugin.webBrowserInfo,
        );
        model = _deviceData["vendor"];
        osVersion = _deviceData["platform"] ?? "";
        baseVersion = _deviceData["userAgent"];
      } else {
        if (isAndroid) {
          _deviceData = _readAndroidBuildData(
            await deviceInfoPlugin.androidInfo,
          );
          id = _deviceData["fingerprint"];
          model = _deviceData["model"];
          osVersion = _deviceData["version.release"] ?? "";
          baseVersion = _deviceData["version.sdkInt"].toString();
        } else if (isIOS) {
          _deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          id = _deviceData["identifierForVendor"];
          model = _deviceData["name"];
          osVersion = _deviceData["systemVersion"] ?? "";
          baseVersion = _deviceData["utsname.version:"];
        } else if (isLinux) {
          _deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (isMacOS) {
          _deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (isWindows) {
          _deviceData = _readWindowsDeviceInfo(
            await deviceInfoPlugin.windowsInfo,
          );
        }
      }
    } on PlatformException {
      _deviceData = <String, dynamic>{
        "Error:": "Failed to get platform version.",
      };
    }
  }

  static _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      "version.securityPatch": build.version.securityPatch,
      "version.sdkInt": build.version.sdkInt,
      "version.release": build.version.release,
      "version.previewSdkInt": build.version.previewSdkInt,
      "version.incremental": build.version.incremental,
      "version.codename": build.version.codename,
      "version.baseOS": build.version.baseOS,
      "board": build.board,
      "bootloader": build.bootloader,
      "brand": build.brand,
      "device": build.device,
      "display": build.display,
      "fingerprint": build.fingerprint,
      "hardware": build.hardware,
      "host": build.host,
      "id": build.id,
      "manufacturer": build.manufacturer,
      "model": build.model,
      "product": build.product,
      "supported32BitAbis": build.supported32BitAbis,
      "supported64BitAbis": build.supported64BitAbis,
      "supportedAbis": build.supportedAbis,
      "tags": build.tags,
      "type": build.type,
      "isPhysicalDevice": build.isPhysicalDevice,
      "systemFeatures": build.systemFeatures,
    };
  }

  static _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      "name": data.name,
      "systemName": data.systemName,
      "systemVersion": data.systemVersion,
      "model": data.model,
      "localizedModel": data.localizedModel,
      "identifierForVendor": data.identifierForVendor,
      "isPhysicalDevice": data.isPhysicalDevice,
      "utsname.sysname:": data.utsname.sysname,
      "utsname.nodename:": data.utsname.nodename,
      "utsname.release:": data.utsname.release,
      "utsname.version:": data.utsname.version,
      "utsname.machine:": data.utsname.machine,
    };
  }

  static _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      "name": data.name,
      "version": data.version,
      "id": data.id,
      "idLike": data.idLike,
      "versionCodename": data.versionCodename,
      "versionId": data.versionId,
      "prettyName": data.prettyName,
      "buildId": data.buildId,
      "variant": data.variant,
      "variantId": data.variantId,
      "machineId": data.machineId,
    };
  }

  static _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      "browserName": data.browserName.name,
      "appCodeName": data.appCodeName,
      "appName": data.appName,
      "appVersion": data.appVersion,
      "deviceMemory": data.deviceMemory,
      "language": data.language,
      "languages": data.languages,
      "platform": data.platform,
      "product": data.product,
      "productSub": data.productSub,
      "userAgent": data.userAgent,
      "vendor": data.vendor,
      "vendorSub": data.vendorSub,
      "hardwareConcurrency": data.hardwareConcurrency,
      "maxTouchPoints": data.maxTouchPoints,
    };
  }

  static _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      "computerName": data.computerName,
      "hostName": data.hostName,
      "arch": data.arch,
      "model": data.model,
      "kernelVersion": data.kernelVersion,
      "osRelease": data.osRelease,
      "activeCPUs": data.activeCPUs,
      "memorySize": data.memorySize,
      "cpuFrequency": data.cpuFrequency,
      "systemGUID": data.systemGUID,
    };
  }

  static _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      "numberOfCores": data.numberOfCores,
      "computerName": data.computerName,
      "systemMemoryInMegabytes": data.systemMemoryInMegabytes,
    };
  }

  static Future<void> _findAdId() async {
    String createId() {
      if (Prefs.contains("deviceId")) {
        return Prefs.getString("deviceId");
      }
      return Prefs.setString("deviceId", StringExtensions.getRandomString(20));
    }

    try {
      if (!isWeb) {
        adId = (await AdvertisingId.id(false))!;
      }
      if (adId.isEmpty || adId.startsWith("0000")) {
        adId = createId();
      }
    } catch (e) {
      adId = createId();
    }
  }
}

extension DeviceI on int {
  double get d => this * DeviceInfo.ratio;
  int get i => d.round();
}

extension DeviceD on double {
  double get d => this * DeviceInfo.ratio;
  int get i => d.round();
}
