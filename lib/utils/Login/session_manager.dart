import 'package:flutter/material.dart';
import 'package:gaushalascanner/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  String? get authToken => _prefs.getString('auth_token');

  Future<void> saveAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
    notifyListeners();
  }

  Future<void> clearSession(BuildContext context) async {
    await _prefs.remove('auth_token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
    notifyListeners();
  }
}
