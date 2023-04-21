// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, unnecessary_new, use_build_context_synchronously, prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart'; // For Calendor
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quick_shift/constants.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:quick_shift/data_getter.dart';
import 'package:quick_shift/screens/DashboardPages/user_booking.dart';
import 'package:quick_shift/screens/payment.dart';

import '../auth_page.dart';

class UserScaffold extends StatefulWidget {
  const UserScaffold({super.key});

  @override
  State<UserScaffold> createState() => _UserScaffoldState();
}

class _UserScaffoldState extends State<UserScaffold> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser_info(); // By using this first we are setting values user_firstname & user_phoneNumber orelse those values will be pushed as NULL to request collection
  }

  final _request = <String, dynamic>{};

  //TextEditingControllers
  final _dateController = TextEditingController();
  final _searchSourceController = TextEditingController();
  final _searchDestinationController = TextEditingController();
  // Validators
  final _formDateValidatorKey = GlobalKey<FormState>();
  final _formSourceValidatorKey = GlobalKey<FormState>();
  final _formDestinationValidatorKey = GlobalKey<FormState>();

  final Set<Polyline> _polyLine = {};

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  Position? currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingofMap = 0;

  late LatLng destination;
  late LatLng source;

  Set<Marker> markers = {};

  // Veichle Type Field Variables
  final List<String> veichleTypes = [
    'Small',
    'Medium',
    'Large',
  ];
  String? selectedVeichletype;

  // Extra Service Field Variables
  final List<String> extraServiceType = [
    'Yes',
    'No',
  ];
  String? selectedOptionForExtraService;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<String> showGoogleAutoComplete() async {
    const kGoogleApiKey = "AIzaSyCGdkjJ8ZIZzupMHqv-OoeD9n3PY4WQnP4";

    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "in",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: kGoogleApiKey,
      types: ["(cities)"],
      hint: "Search City",
      components: [new Component(Component.country, "in")],
    );
    return p!.description!;
  }

  void drawPolyLine(String placeId) {
    _polyLine.clear();
    _polyLine.add(Polyline(
      polylineId: PolylineId(placeId),
      visible: true,
      points: [source, destination],
      color: Colors.purple,
      width: 5,
    ));
  }

  DateTime _datetime = DateTime.now();

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((value) {
      setState(() {
        _datetime = value!;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_datetime);
      });
    });
  }

  Future<int> get_next_request_id() async {
    final response =
        await http.get(Uri.parse('http://localhost:8001/nextrequestid'));
    if (response.statusCode == 200) {
      //List requests = [];
      int requests = int.parse(response.body);
      if (requests == 1) {
        //print("hello");
        return 1;
      }
      return requests;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future loadRequestData() async {
    // Circular Loading
    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return Center(child: CircularProgressIndicator());
    //     });

    // Firebase Database Update Function
    if (_formDateValidatorKey.currentState!.validate() &&
        _formSourceValidatorKey.currentState!.validate() &&
        _formDestinationValidatorKey.currentState!.validate()) {
      int t = await get_next_request_id();
      int v = Random().nextInt(500) + 1;
      trans_id = v;
      final request = <String, dynamic>{
        'date': '${_datetime.day} / ${_datetime.month} / ${_datetime.year}',
        'sourceAddress': _searchSourceController.text.trim().toString(),
        'destinationAddress':
            _searchDestinationController.text.trim().toString(),
        'extraServicesRequired': selectedOptionForExtraService,
        'vehicleType': selectedVeichletype,
        'userEmail': details[0]["email"].toString(),
        'userName': details[0]["firstname"].toString() +
            " " +
            details[0]["lastname"].toString(),
        'userPhoneNo': details[0]["phoneNumber"].toString(),
        'driverEmail': 'Assigning...',
        'driverName': 'Assigning...',
        'driverPhoneNo': 'Assigning...',
        'status': 'Processing',
        'paymentstatus': '0',
        'trans_id': v.toString(),
        'id': t.toString(),
      };

      print("request");
      print(request);

      final response = await http.put(
        Uri.parse('http://localhost:8001/createrequest'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );
      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Container(
                    height: 150,
                    child: Column(children: [
                      const Text(
                        "Payment",
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepPurple, //background color of button
                            side: const BorderSide(
                                width: 2,
                                color:
                                    Colors.deepPurple), //border width and color
                            elevation: 3, //elevation of button
                            shape: RoundedRectangleBorder(
                                //to set border radius to button
                                borderRadius: BorderRadius.circular(18)),
                            padding: const EdgeInsets.all(
                                18) //content padding inside button
                            ),
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(
                              builder: (BuildContext context) {
                            return Payment();
                          }));
                        },
                        child: const Text("Confirm & Pay"),
                      ),
                    ])));
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar,
      backgroundColor: defaultBackgroundColor,
      drawer: Drawer(
        backgroundColor: Colors.grey[300],
        child: Column(children: [
          DrawerHeader(
            child: ImageIcon(AssetImage('assets/images/logo.png'), size: 160),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.home),
              title: Text(
                'D A S H B O A R D',
                style: drawerTextColor,
              ),
              onTap: (() {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return UserScaffold();
                }));
              }),
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.account_box),
              title: Text(
                'M Y  B O O K I N G S',
                style: drawerTextColor,
              ),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return UserBooking();
                }));
              },
            ),
          ),
          Padding(
            padding: tilePadding,
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                'L O G O U T',
                style: drawerTextColor,
              ),
              onTap: () async {
                // await FirebaseAuth.instance.signOut();
                // Phoenix.rebirth(context);
                final response = await http.post(Uri.parse(
                    'http://localhost:8000/logout/' + details[0]["email"]));
                if (response.statusCode == 200) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return AuthPage();
                  }));
                }
              },
            ),
          )
        ]),
      ),
      body: Stack(
        // Using Stack because the Box is above the Google Map
        children: [
          // GoogleMap(
          //   padding: EdgeInsets.only(bottom: bottomPaddingofMap),
          //   markers: markers,
          //   polylines: _polyLine,
          //   mapType: MapType.normal,
          //   myLocationButtonEnabled: true,
          //   initialCameraPosition: _kGooglePlex,
          //   myLocationEnabled: true,
          //   zoomGesturesEnabled: true,
          //   zoomControlsEnabled: true,
          //   onMapCreated: (GoogleMapController controller) {
          //     _controllerGoogleMap.complete(controller);
          //     newGoogleMapController = controller;
          //     setState(() {
          //       bottomPaddingofMap = 300.0;
          //     });
          //     locatePosition();
          //   },
          // ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 600.0,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Hi there !",
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Where to SHIFT ?",
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Brand-Bold",
                              color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        // Book Schedule from Calendor
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Form(
                            key: _formDateValidatorKey,
                            child: TextFormField(
                              readOnly: true,
                              onTap: _showDatePicker,
                              controller: _dateController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Enter Date of Shifting',
                                prefixIcon: Icon(Icons.calendar_month),
                                contentPadding: EdgeInsets.all(12.0),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              onSaved: (value) => _request['date'] = value,
                              validator: (date) {
                                if (date == null || date.isEmpty) {
                                  return 'Please enter a Date';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Enter Source Location
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        //   child: Form(
                        //     key: _formSourceValidatorKey,
                        //     child: TextFormField(
                        //       readOnly: true,
                        //       onTap: () async {
                        //         String selectedPlace =
                        //             await showGoogleAutoComplete();
                        //         _searchSourceController.text = selectedPlace;
                        //         List<geoCoding.Location> locations =
                        //             await geoCoding
                        //                 .locationFromAddress(selectedPlace);
                        //         source = LatLng(locations.first.latitude,
                        //             locations.first.longitude);
                        //         setState(() {
                        //           markers.add(Marker(
                        //               markerId: MarkerId(selectedPlace),
                        //               infoWindow: InfoWindow(
                        //                 title: 'Source: $selectedPlace',
                        //               ),
                        //               position: source));
                        //         });
                        //         newGoogleMapController.animateCamera(
                        //             CameraUpdate.newCameraPosition(
                        //                 CameraPosition(
                        //                     target: source, zoom: 14)));
                        //       },
                        //       controller: _searchSourceController,
                        //       decoration: InputDecoration(
                        //         enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(color: Colors.white),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide:
                        //               BorderSide(color: Colors.deepPurple),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         hintText: 'Search source location',
                        //         prefixIcon:
                        //             Icon(Icons.search), // Adds Email Icon
                        //         contentPadding: EdgeInsets.all(12.0),
                        //         fillColor: Colors.grey[200],
                        //         filled: true,
                        //       ),
                        //       validator: (sourceLoc) {
                        //         if (sourceLoc == null || sourceLoc.isEmpty) {
                        //           return 'Please enter Source Location';
                        //         }
                        //         return null;
                        //       },
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 15),
                        // // Destination Field
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        //   child: Form(
                        //     key: _formDestinationValidatorKey,
                        //     child: TextFormField(
                        //       readOnly: true,
                        //       onTap: () async {
                        //         String selectedPlace =
                        //             await showGoogleAutoComplete();
                        //         _searchDestinationController.text =
                        //             selectedPlace;
                        //         List<geoCoding.Location> locations =
                        //             await geoCoding
                        //                 .locationFromAddress(selectedPlace);
                        //         destination = LatLng(locations.first.latitude,
                        //             locations.first.longitude);
                        //         setState(() {
                        //           markers.add(Marker(
                        //               markerId: MarkerId(selectedPlace),
                        //               infoWindow: InfoWindow(
                        //                 title: 'Destination: $selectedPlace',
                        //               ),
                        //               position: destination));
                        //           drawPolyLine(selectedPlace);
                        //         });
                        //         drawPolyLine(selectedPlace);
                        //         newGoogleMapController.animateCamera(
                        //             CameraUpdate.newCameraPosition(
                        //                 CameraPosition(
                        //                     target: destination, zoom: 10)));
                        //       },
                        //       controller: _searchDestinationController,
                        //       decoration: InputDecoration(
                        //         enabledBorder: OutlineInputBorder(
                        //           borderSide: BorderSide(color: Colors.white),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //           borderSide:
                        //               BorderSide(color: Colors.deepPurple),
                        //           borderRadius: BorderRadius.circular(12),
                        //         ),
                        //         hintText: 'Enter Destination',
                        //         prefixIcon: Icon(Icons.search),
                        //         contentPadding: EdgeInsets.all(12.0),
                        //         fillColor: Colors.grey[200],
                        //         filled: true,
                        //       ),
                        //       validator: (destinationLoc) {
                        //         if (destinationLoc == null ||
                        //             destinationLoc.isEmpty) {
                        //           return 'Please enter a Destination location';
                        //         }
                        //         return null;
                        //       },
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Form(
                            key: _formSourceValidatorKey,
                            child: TextFormField(
                              controller: _searchSourceController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Enter source address',
                                prefixIcon: Icon(Icons.search),
                                contentPadding: const EdgeInsets.all(12.0),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              onSaved: (value) =>
                                  _request['sourceAddress'] = value,
                              validator: (breed) {
                                if (breed == null || breed.isEmpty) {
                                  return 'Please source details';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Form(
                            key: _formDestinationValidatorKey,
                            child: TextFormField(
                              controller: _searchDestinationController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                hintText: 'Enter destination address',
                                prefixIcon: Icon(Icons.search),
                                contentPadding: const EdgeInsets.all(12.0),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              onSaved: (value) =>
                                  _request['destinationAddress'] = value,
                              validator: (breed) {
                                if (breed == null || breed.isEmpty) {
                                  return 'Please enter destination details';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Enter Vehicle Type Dropdown Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Form(
                            child: DropdownButtonFormField2(
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.all(12.0),
                                hintText: 'Enter Vehicle Type',
                                prefixIcon: Icon(Icons.fire_truck_sharp),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              items: veichleTypes
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                // Do Smoething here
                                setState(() {
                                  selectedVeichletype = value.toString();
                                });
                              },
                              onSaved: (value) {
                                selectedVeichletype = value.toString();
                                _request['vehicleType'] = selectedVeichletype;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Extra Services Field (Yes or No) Dropdown Field
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Form(
                            child: DropdownButtonFormField2(
                              //alignment: Alignment.centerLeft,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.deepPurple),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.all(12.0),
                                hintText: 'Do you want extra Services?',
                                prefixIcon: Icon(Icons.price_check),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black45,
                              ),
                              buttonPadding:
                                  const EdgeInsets.only(left: 20, right: 10),
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              items: extraServiceType
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                // Do Smoething here
                                setState(() {
                                  selectedOptionForExtraService =
                                      value.toString();
                                });
                              },
                              onSaved: (value) {
                                selectedOptionForExtraService =
                                    value.toString();
                                _request['extraServicesRequired'] =
                                    selectedOptionForExtraService;
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Request SHIFT Submit Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: GestureDetector(
                            onTap: () {
                              getUser_info();
                              loadRequestData();
                            },
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Request SHIFT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
