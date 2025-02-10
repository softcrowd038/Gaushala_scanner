// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:gaushalascanner/pages/scanner_page.dart';

Future<void> authenticateUser(
    BuildContext context, String userId, String password) async {
  const String apiUrl =
      'https://softcrowd.in/gaushala_management_system/login_api/login_api_visitor.php';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'visitor_id': userId,
        'password': password,
      }),
    );

    print('Request: ${response.request}');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      print('Authentication successful: ${response.body}');

      final result = await Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) =>  ScannerPage(),
        ),
      );

      if (result != null) {
        print('ScannerPage result: $result');
      }
    } else {
      print('Authentication failed: ${response.body}');
    }
  } catch (error) {
    print('Error: $error');
  }
}
