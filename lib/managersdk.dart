library managersdk;

import 'package:managersdk/licence.dart';
import 'package:shared_preferences_content_provider/shared_preferences_content_provider.dart';

class ManagerSDKF {
  static final ManagerSDKF _singleton = ManagerSDKF._internal();
  factory ManagerSDKF() => _singleton;
  ManagerSDKF._internal();

  bool _wastInited = false;
  static const devappProviderAuthority = "com.sfperusac.manager.licences";
  Future<void> _init() async {
    try {
      await SharedPreferencesContentProvider.init(
        providerAuthority: devappProviderAuthority,
      );
      _wastInited = true;
    } catch (err) {
      throw Exception('''Proveedor de variables de entorno no encontrado. 
Asegúrate de tener la aplicación correcta instalada e intenta nuevamente.''');
    }
  }

  Future<List<Licence>> readLicences() async {
    if (!_wastInited) await _init();
    try {
      final value = await SharedPreferencesContentProvider.get("licences");
      if (value is! String) return [];
      if (value == "") return [];
      return licenceFromJson(value);
    } catch (err) {
      throw Exception("No se pudo leer las licencias");
    }
  }
}
