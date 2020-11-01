import 'package:shared_preferences/shared_preferences.dart';

/// The Settings class contains the settings of the entire application
/// containing all the user states like dark mode, sidenav width, etc.

class Settings {
  final SharedPreferences _storage;
  Settings(this._storage);

  // Required keys
  static const _sideNavWidthKey = 'sideNavWidth';
  static const _isDarkModeKey = 'isDarkMode';

  Map<String, dynamic> _settingsConfig = {};

  /// get the width of the side navigation bar
  int get sideNavWidth => _storage.getInt(_sideNavWidthKey);

  /// change the side navigation bar's width property
  set sideNavWidth(int width) => _storage.setInt(_sideNavWidthKey, width);

  /// check if the user is requesting dark mode or not
  bool get darkModeEnabled => _storage.getBool(_isDarkModeKey);

  /// toggle the application's theme from either dark or light
  Future<bool> toogleDarkMode() async {
    bool status = darkModeEnabled;
    await _storage.setBool(_isDarkModeKey, status = !status);
    return status;
  }

  /// returns all the settings configuration in the form of a Map datatype
  Map<String, dynamic> get getAll {
    _settingsConfig.clear();
    _storage.getKeys().forEach((element) {
      _settingsConfig.addAll({element: _storage.get(element)});
    });
    return _settingsConfig;
  }
}
