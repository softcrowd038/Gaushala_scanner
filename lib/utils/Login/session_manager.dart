import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  late final SharedPreferences _prefs;

  SessionManager(SharedPreferences prefs) : _prefs = prefs;

  Future<bool> isLoggedIn() async {
    return _prefs.getBool("isLoggedIn") ?? false;
  }

  void setLoggedIn(bool value) async {
    await _prefs.setBool("isLoggedIn", value);
    notifyListeners();
  }

  String? getVisitorId() {
    return _prefs.getString("visitorId");
  }

  void setVisitorId(String visitorId) async {
    await _prefs.setString("visitorId", visitorId);
    notifyListeners();
  }
}
