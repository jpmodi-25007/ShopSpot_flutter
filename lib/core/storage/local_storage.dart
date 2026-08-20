import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStorage {
  Future<void> write(String key, dynamic value);
  Future<T?> read<T>(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

class SharedPrefsLocalStorage implements LocalStorage {
  final SharedPreferences _prefs;

  SharedPrefsLocalStorage(this._prefs);

  @override
  Future<void> write(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    }
  }

  @override
  Future<T?> read<T>(String key) async {
    return _prefs.get(key) as T?;
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }
}
