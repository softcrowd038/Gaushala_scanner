// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:gaushalascanner/data/app_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gaushalascanner/pages/scanner_page.dart';
import 'package:gaushalascanner/utils/Login/session_manager.dart';
import 'package:gaushalascanner/utils/Login/validations_page.dart';
import 'package:gaushalascanner/Components/custom_button.dart';
import 'package:gaushalascanner/Components/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("visitorId") != null;
  }

  Future<void> saveVisitorId(String visitorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("visitorId", visitorId);
  }

  Future<void> authenticateUser() async {
    String apiUrl = '$baseUrl/visitor/login';
    print('entered');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userIdController.text,
          'password': passwordController.text,
        }),
      );

      print('${userIdController.text} ${passwordController.text}');

      if (response.statusCode == 200) {
        print('Authentication successful: ${response.body}');

        final Map<String, dynamic> data = jsonDecode(response.body);

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('visitorId', data['uuid']);
        sharedPreferences.setString('password', passwordController.text);

        final jwt = JWT.verify(data['token'], SecretKey(secreteKey));
        print(jwt.payload['id']);
        sharedPreferences.setString('id', jwt.payload['id'].toString());

        Provider.of<SessionManager>(context, listen: false)
            .saveAuthToken(data['token']);

        final result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ScannerPage(),
          ),
        );

        if (result != null) {
          print('ScannerPage result: $result');
        }
      } else {
        print('Authentication failed: ${response.body}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print('${userIdController.text} ${passwordController.text}');
      print('Error: $error');
    }
  }

  void validateAndAuthenticate() async {
    if (_key.currentState?.validate() ?? false) {
      await authenticateUser();

      setState(() {
        userIdController.clear();
        passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Form(
            key: _key,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.060,
                ),
                Image.network(
                    'https://img.freepik.com/free-vector/cow-eating-concept-illustration_114360-13832.jpg?t=st=1731129608~exp=1731133208~hmac=d1720b2dd877558f06c4c494239674897b7be17a83d18c71cf53bb94abc5bb23&w=740'),
                Text(
                  'SIGN IN',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                      fontWeight: FontWeight.bold),
                ),
                CustomTextField(
                  hintText: "Enter your Visitor Email here",
                  fieldController: userIdController,
                  type: TextInputType.emailAddress,
                  customValidator: (value) => validateUserId(context, value),
                  icon: const Icon(Icons.person),
                ),
                CustomTextField(
                  hintText: "Enter your password here",
                  fieldController: passwordController,
                  type: TextInputType.text,
                  customValidator: (value) => validatePassword(context, value),
                  icon: const Icon(Icons.key),
                ),
                GestureDetector(
                  onTap: () {
                    authenticateUser();
                  },
                  child: const CustomButton(
                    color: Colors.blue,
                    buttonText: "SCAN",
                  ),
                ),
              ],
            ),
          )),
        ));
  }
}
