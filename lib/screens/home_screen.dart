import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import '../models/accident.dart';
import '../models/user.dart';
import '../services/db_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ShakeDetector? detector;
  List<Accident> _accidents = [];

  @override
  void initState() {
    super.initState();
    // Initialize shake detector
    detector = ShakeDetector.autoStart(
      onPhoneShake: _showAccidentConfirmationModal,
    );
    _loadAccidents();
  }

  Future<void> _loadAccidents() async {
    // Load accidents from database
    List<Accident> accidents =
        await DatabaseService.instance.getAccidents(widget.user.id!);
    setState(() {
      _accidents = accidents;
    });
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location permissions are permanently denied'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<Position?> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return null;
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // send accident message to a phone number
  Future<void> _sendAccidentMessage(
      // get the phone number and all the details
      plateNumber,
      phoneNumber,
      carModel,
      latitude,
      longitude,
      insurance,
      timestamp,
      CarOwner) async {
    print('Sending accident message');
    var url = Uri.parse('https://api.pindo.io/v1/sms/');
    var token = dotenv.env['PINDO_API_KEY'];
    var headers = {
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
    final body = {
      'to': '+250788318666',
      'text':
          'Hello from Real time accident and support system, an accident has occurred at location: ($latitude, $longitude) at $timestamp. The car involved has plate number $plateNumber, model $carModel and is registered to $CarOwner with $insurance insurance.',
      'sender': 'PindoTest'
    };
    // send the request
    final response = await http.post(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message');
    }
  }

  Future<void> _logAccident() async {
    Position? locationData = await _getCurrentLocation();
    // _sendAccidentMessage(
    //     widget.user.plateNumber,
    //     widget.user.phoneNumber,
    //     widget.user.carModel,
    //     locationData!.latitude,
    //     locationData.longitude,
    //     widget.user.insurance,
    //     DateTime.now()
    //         .toIso8601String()
    //         .trim()
    //         .substring(0, 19)
    //         .replaceAll('T', ' '),
    //     widget.user.name);
    
    if (locationData == null) return;
    // print type of locationData.latitude
    print(locationData.latitude.runtimeType);
    print(locationData.longitude.runtimeType);
    
    final accident = Accident(
      userId: widget.user.id!,
      latitude: locationData.latitude,
      longitude: locationData.longitude,
      timestamp: DateTime.now()
          .toIso8601String()
          .trim()
          .substring(0, 19)
          .replaceAll('T', ' '),
    );
    await DatabaseService.instance.logAccident(accident);
    setState(() {
      _accidents.insert(0, accident); // Add accident to top of list
    });
  }

  Future<void> _showAccidentConfirmationModal() async {
        final player = AudioPlayer();
    await player.play(
      AssetSource(
        'alert.mp3',
      ),
      volume: 100,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 30), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            _logAccident(); // Auto-log if no response
          }
        });
        return AlertDialog(
          title: Text('Confirm Accident'),
          content: Text('Did an accident just occur?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close modal without logging
              },
              child: Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logAccident(); // Log accident if confirmed
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accident Location Tracker"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "\nPlate Number: ${widget.user.plateNumber}"
              "\nCar Owner: ${widget.user.name}"
              "\nPhone Number: 0${widget.user.phoneNumber}"
              "\nCar Model: ${widget.user.carModel}",
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            // Display accidents
            if (_accidents.isNotEmpty)
              Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Accidents Logged: ${_accidents.length}",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  Text(
                    "Bellow are the accidents you have logged",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                ],
              ),

            SizedBox(height: 5),
            Expanded(
              child: _accidents.isNotEmpty
                  ? ListView.builder(
                      itemCount: _accidents.length,
                      itemBuilder: (context, index) {
                        final accident = _accidents[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: Icon(Icons.warning, color: Colors.red),
                            title: Text(
                              "Location: (${accident.latitude.toStringAsFixed(4)}, ${accident.longitude.toStringAsFixed(4)})",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Time: ${accident.timestamp}"),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No accidents logged",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
            ElevatedButton(
              onPressed: _showAccidentConfirmationModal,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text("Accident detected", style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }
}
