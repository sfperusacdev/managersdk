library managersdk;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:managersdk/licence.dart';
import 'package:shared_preferences_content_provider/shared_preferences_content_provider.dart';
import 'package:http/http.dart' as http;

abstract class ReadeProvider {
  Future<void> init() async {}
  Future<List<Licence>> licences();
  Future<String> deviceID();
  Future<String> deviceName();
}

class _SharedPreferences implements ReadeProvider {
  static const devappProviderAuthority = "com.sfperusac.manager.licences";
  @override
  Future<String> deviceID() async {
    final value = await SharedPreferencesContentProvider.get("__device_id__");
    if (value is String) return value;
    return "---device-id-not-found---";
  }

  @override
  Future<String> deviceName() async {
    final value = await SharedPreferencesContentProvider.get("__device_name__");
    if (value is String) return value;
    return "";
  }

  @override
  Future<void> init() async {
    await SharedPreferencesContentProvider.init(
      providerAuthority: devappProviderAuthority,
    );
  }

  @override
  Future<List<Licence>> licences() async {
    final value = await SharedPreferencesContentProvider.get("licences");
    return licenceFromJson(value);
  }
}

class _LocalServer implements ReadeProvider {
  @override
  Future<String> deviceName() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/devicename");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity DeviceID: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return decoded["data"]["name"] as String;
  }

  @override
  Future<String> deviceID() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/deviceid");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity DeviceID: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return decoded["data"]["id"] as String;
  }

  @override
  Future<List<Licence>> licences() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/device_licences");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity Licences: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return licenceFromJson(jsonEncode(decoded["data"]));
  }

  @override
  Future<void> init() async {}
}

class ManagerSDKF {
  static final ManagerSDKF _singleton = ManagerSDKF._internal();
  factory ManagerSDKF() => _singleton;
  ManagerSDKF._internal();
  late ReadeProvider reader;
  bool _wastInited = false;
  Future<void> _init() async {
    if (_wastInited) return;
    if (Platform.isIOS) throw "IOS is not soported";
    reader = (Platform.isAndroid) ? _SharedPreferences() : _LocalServer();
    try {
      await reader.init();
      _wastInited = true;
    } catch (err) {
      if (kDebugMode) print("ManagerSDKF._init EROR: ${err.toString()}");
      throw '''Servicio de autentificación no encontrado''';
    }
  }

  Future<List<Licence>> readLicences() async {
    if (!_wastInited) await _init();
    try {
      return await reader.licences();
    } catch (err) {
      throw Exception("No se pudo leer las licencias");
    }
  }

  Future<String> deviceID() async {
    if (!_wastInited) await _init();
    try {
      return reader.deviceID();
    } catch (err) {
      throw Exception("No se pudo leer el identificador del dispositivo");
    }
  }

  Future<String> deviceName() async {
    if (!_wastInited) await _init();
    try {
      return reader.deviceName();
    } catch (err) {
      throw Exception("No se pudo leer el nombre del dispositivo");
    }
  }
}
