import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton // Pastikan anotasi ini ada
class UserPreferencesRepository {
  final SharedPreferences _prefs;
  static const _authTokenKey = 'auth_token';

  UserPreferencesRepository(this._prefs);

  Future<void> saveAuthToken(String token) {
    return _prefs.setString(_authTokenKey, token);
  }

  String? getAuthToken() {
    return _prefs.getString(_authTokenKey);
  }

  Future<void> clearAuthToken() {
    return _prefs.remove(_authTokenKey);
  }
}