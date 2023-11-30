library managersdk;

import 'dart:convert';
import 'dart:io';

import 'package:managersdk/licence.dart';
import 'package:shared_preferences_content_provider/shared_preferences_content_provider.dart';
import 'package:http/http.dart' as http;

abstract class ReadeProvider {
  Future<void> init();
  Future<List<Licence>> licences();
  Future<String> deviceID();
}

class _SharedPreferences implements ReadeProvider {
  static const devappProviderAuthority = "com.sfperusac.manager.licences";
  @override
  Future<String> deviceID() async {
    final value = await SharedPreferencesContentProvider.get("device_id");
    if (value is String) return value;
    return "---device-id-not-found---";
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
  Future<void> init() async {}

  @override
  Future<List<Licence>> licences() async {
    final url = Uri.parse("https://local.identity.sfperu.local:7443/v1/device_licences");
    final response = await http.get(url);
    if (response.statusCode != 200) {
      final decoded = jsonDecode(response.body);
      throw "LocalIdentity Licences: ${decoded["message"]}";
    }
    final decoded = jsonDecode(response.body);
    return licenceFromJson(decoded["data"]);
  }
}

class ManagerSDKF {
  static final ManagerSDKF _singleton = ManagerSDKF._internal();
  factory ManagerSDKF() => _singleton;
  ManagerSDKF._internal();
  late ReadeProvider reader;
  bool _wastInited = false;
  Future<void> _init() async {
    if (Platform.isIOS) throw "IOS is not soported";
    reader = (Platform.isAndroid) ? _SharedPreferences() : _LocalServer();
    try {
      await reader.init();
      _wastInited = true;
    } catch (err) {
      throw Exception('''Proveedor de variables de entorno no encontrado. 
Asegúrate de tener la aplicación correcta instalada e intenta nuevamente.''');
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
}
