// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:gaushalascanner/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utils/Login/session_manager.dart';

class ScannerPage extends StatefulWidget {
  final String visitorId;
  final String password;

  const ScannerPage(
      {super.key, required this.visitorId, required this.password});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String qrResult = "";
  bool isClicked = false;
  double turns = 0.0;
  bool isCheckedIn = false;
  String uniqueID = "Rutik@123";
  MobileScannerController? scannerController;

  @override
  void initState() {
    super.initState();

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
    String apiUrl =
        'https://softcrowd.in/gaushala_management_system/login_api/check_in_out_api.php';

    try {
      Map<String, dynamic> requestData = {
        'qrCode': qrCode,
        'action': isCheckedIn ? 'check_out' : 'check_in',
        'visitor_id': widget.visitorId,
        'password': widget.password,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(requestData),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        String time = data['time'] ?? '';

        if (isCheckedIn) {
          _saveCheckOutTimeLocally(time);
        } else {
          _saveCheckInTimeLocally(time);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSuccessDialog(
              '${isCheckedIn ? 'Check-out' : 'Check-in'} successful!');
        });
      } else {
        _showErrorDialog('Failed to ${isCheckedIn ? 'check_out' : 'check_in'}');
      }

      setState(() => isCheckedIn = !isCheckedIn);
    } catch (e) {
      _showErrorDialog(
          'Error during ${isCheckedIn ? 'check_out' : 'check_in'}');
    }
  }

  void _saveCheckInTimeLocally(String checkInTime) {
    print('Check-in time saved locally: $checkInTime');
  }

  void _saveCheckOutTimeLocally(String checkOutTime) {
    print('Check-out time saved locally: $checkOutTime');
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
                final Uint8List? image = capture.image;

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

                if (image != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(barcodes.first.rawValue ?? ""),
                      content: Image.memory(image),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Welcome!, ${widget.visitorId}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.020,
                  fontWeight: FontWeight.bold),
            ),
            GestureDetector(
                onTap: () {
                  context.read<SessionManager>().setLoggedIn(false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(isLoggedIn: false),
                    ),
                  );
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Stack(
            children: [
              AnimatedRotation(
                turns: turns,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOutExpo,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isClicked = !isClicked;
                      turns += isClicked ? 0.25 : -0.25;
                    });
                    startScanner();
                  },
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Stack(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.height * 0.30,
                        child: Image.asset('assets/images/part.gif'),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.11,
                        left: MediaQuery.of(context).size.height * 0.115,
                        child: const Icon(
                          Icons.fingerprint_sharp,
                          color: Colors.blue,
                          size: 60,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.008),
                      child: Container(
                        decoration: BoxDecoration(
                            color: isClicked ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height * 0.025)),
                        child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height * 0.010),
                          child: Text(
                            isClicked ? 'Check Out' : 'Check In',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Image.asset(
                          "assets/images/arrow.png",
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.height * 0.12,
                        ),
                      ],
                    )
                  ]),
            ],
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  startScanner();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Stack(children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28,
                      width: MediaQuery.of(context).size.height * 0.28,
                      child: Image.network(
                          'https://media1.tenor.com/m/Vuj0gisW_3cAAAAd/moving-formation.gif'),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.10,
                      left: MediaQuery.of(context).size.height * 0.10,
                      child: const Icon(
                        Icons.fingerprint_sharp,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                  ]),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.008),
                      child: const Text(
                        'Cow Info',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Image.asset(
                          "assets/images/arrow.png",
                          height: MediaQuery.of(context).size.height * 0.12,
                          width: MediaQuery.of(context).size.height * 0.12,
                        ),
                      ],
                    )
                  ]),
            ],
          ),
        ],
      ),
    );
  }
}
