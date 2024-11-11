import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gaushalascanner/pages/login_page.dart';
import 'package:gaushalascanner/pages/scanner_page.dart';
import 'package:gaushalascanner/utils/Login/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => SessionManager(prefs),
        child: MyApp(
          isLoggedIn: isLoggedIn,
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      home: isLoggedIn
          ? FutureBuilder<String?>(
              future: SharedPreferences.getInstance()
                  .then((prefs) => prefs.getString('visitorId')),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.hasData
                      ? ScannerPage(
                          visitorId: snapshot.data!,
                          password: snapshot.data!,
                        )
                      : LoginPage(isLoggedIn: isLoggedIn);
                } else {
                  return const CircularProgressIndicator();
                }
              },
            )
          : const LoginPage(isLoggedIn: false),
    );
  }
}
