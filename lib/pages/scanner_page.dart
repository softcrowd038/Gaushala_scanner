// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaushalascanner/Models/animal_model.dart';
import 'package:gaushalascanner/data/app_data.dart';
import 'package:gaushalascanner/utils/Login/session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String qrResult = "";
  bool isClicked = false;
  double turns = 0.0;
  bool isCheckedIn = false;
  String uniqueID = "3f8d7d9c-6b17-4a91-b925-49d7b60d8e2f";
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();
    fetchVisitorDetails();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    initial();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  String? visitorId;

  void initial() async {
    SharedPreferences prefs = await getSharedPreferencesInstance();
    visitorId = prefs.getString("visitorId");
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processScanResult(String qrCode) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final visitorId = sharedPreferences.getString('id');

    print(visitorId);

    if (visitorId == null || visitorId.isEmpty) {
      _showErrorDialog("Visitor ID not found. Please try again.");
      return;
    }

    String apiUrl =
        isCheckedIn ? "$baseUrl/time/check-out" : "$baseUrl/time/check-in";

    try {
      Map<String, dynamic> requestData = {
        'visitorId': visitorId,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        print(data['message']);

        setState(() => isCheckedIn = !isCheckedIn);

        print(isCheckedIn);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSuccessDialog(
              '${isCheckedIn ? 'Check-in' : 'Check-out'} successful!');
        });
      } else {
        _showErrorDialog('Failed to ${isCheckedIn ? 'check_out' : 'check_in'}');
      }
    } catch (e) {
      _showErrorDialog(
          'Error during ${isCheckedIn ? 'check_out' : 'check_in'}');
    }
  }

  void _showSuccessDialog(String successMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: Text(successMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void startScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black),
            ),
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
                returnImage: true,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;

                for (final barcode in barcodes) {
                  String qrCode = barcode.rawValue ?? "";
                  if (qrCode.isNotEmpty && qrCode == uniqueID) {
                    _processScanResult(qrCode);
                    Navigator.pop(context);
                    break;
                  } else {
                    _showErrorDialog("Invalid QR Code!");
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  void startCowInfoScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black),
            ),
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
                returnImage: true,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;

                for (final barcode in barcodes) {
                  String qrCode = barcode.rawValue ?? "";
                  if (qrCode.isNotEmpty) {
                    Navigator.pop(context);
                    fetchAnimalDetails(qrCode);
                    break;
                  } else {
                    Navigator.pop(context);
                    _showAnimalErrorDialog(context, "Invalid QR Code!");
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchAnimalDetails(String qrCode) async {
    final url = Uri.parse('$baseUrl/animaldetails/byid/$qrCode');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> animalData = jsonDecode(response.body);
        Animal animal = Animal.fromJson(animalData);

        _showAnimalDialog(animal);
      } else {
        _showAnimalErrorDialog(context,
            "Failed to fetch animal details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      _showAnimalErrorDialog(context, "Error fetching animal details: $e");
    }
  }

  String dateTimeFormat(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  void _showAnimalDialog(Animal animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Animal Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "📌 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Type:  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(animal.type),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "🧬 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Breed:   ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(animal.breed),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "⚥   ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Gender:  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(animal.gender),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "🎂 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Age:   ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${animal.age} years"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "📅 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "DOB:  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(dateTimeFormat(animal.dateOfBirth)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "🎨 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Color:   ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(animal.color),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "📋 ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Characteristics:   ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(animal.physicalCharacteristics),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showAnimalErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchVisitorDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('visitorId');

    if (uuid == null) {
      print("No visitor ID found in SharedPreferences.");
      return;
    }

    final url = Uri.parse('$baseUrl/visitor/$uuid');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> visitorData = jsonDecode(response.body);
        print("Visitor Details: $visitorData");

        await sharedPreferences.setString('id', visitorData['id'].toString());
        print(sharedPreferences.getString('id'));

        await sharedPreferences.setString('email', visitorData['email']);
      } else {
        print(
            "Failed to fetch visitor details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching visitor details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionManager = Provider.of<SessionManager>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome!, ',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height * 0.020,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
                onTap: () {
                  sessionManager.clearSession(context);
                },
                child: Text(
                  'logout',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: MediaQuery.of(context).size.height * 0.020,
                      fontWeight: FontWeight.bold),
                )),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
              'https://static-00.iconduck.com/assets.00/qr-code-illustration-2048x1668-wseobvx0.png'),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
            child: const Center(
              child: Text(
                'scan qr either to check-in or check-out or to see cow info.',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.010),
            child: Center(
              child: Text(
                isClicked ? 'Check Out' : 'Check In',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              startScanner();
            },
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.008),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  color: isCheckedIn ? Colors.red : Colors.blue,
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.010),
                  child: Center(
                    child: Text(
                      isCheckedIn ? 'Check Out' : 'Check In',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              startCowInfoScanner();
            },
            child: Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.008),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                ),
                child: const Center(
                  child: Text(
                    'Cow Info',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
