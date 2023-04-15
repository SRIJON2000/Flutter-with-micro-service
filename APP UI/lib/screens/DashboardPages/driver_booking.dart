// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:quick_shift/constants.dart';
import 'package:quick_shift/screens/DashboardPages/driver_scaffold.dart';
import 'package:http/http.dart' as http;
import '../../data_getter.dart';
import '../auth_page.dart';

class DriverBooking extends StatefulWidget {
  const DriverBooking({super.key});

  @override
  State<DriverBooking> createState() => _DriverBookingState();
}

class _DriverBookingState extends State<DriverBooking> {
  List requests = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch_driver_booking();
  }

  // ignore: non_constant_identifier_names
  Future<void> fetch_driver_booking() async {
    final response = await http.get(Uri.parse(
        'http://localhost:8001/driverrequest/' + details[0]["email"]));
    if (response.statusCode == 200) {
      setState(() {
        requests = jsonDecode(response.body);
      });
    } else {
      throw Exception('Failed to load users');
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
            //child: ImageIcon(AssetImage('assets/images/logo.png'), size: 160)),
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
                    return DriverScaffold();
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
                    return DriverBooking();
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
        body: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (BuildContext context, int index) {
              final request = requests[index];

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[900],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.date_range,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 5),
                            Text(
                              request['date'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ImageIcon(
                                      AssetImage("assets/images/source.png"),
                                      color: Colors.deepPurple,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      request['sourceAddress'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ImageIcon(
                                      AssetImage(
                                          "assets/images/destination.png"),
                                      color: Colors.deepPurple,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      request['destinationAddress'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 30),
                          Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(children: [
                                    ImageIcon(
                                      AssetImage("assets/images/user.png"),
                                      color: Colors.deepPurple,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      request['userName'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ])),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    ImageIcon(
                                      AssetImage("assets/images/userPhone.png"),
                                      color: Colors.deepPurple,
                                    ),
                                    SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () async {
                                        await FlutterPhoneDirectCaller
                                            .callNumber(request['userPhoneNo']
                                                .toString());
                                      },
                                      child: Text(
                                        request['userPhoneNo'].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.deepPurple,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  // "Status: ${request['status']} by you",
                                  "Status: " + request["status"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Text(
                                //   "\nIf Completed then click the below button",
                                //   style: TextStyle(
                                //     color: Colors.white,
                                //     fontSize: 10,
                                //   ),
                                // ),
                                SizedBox(height: 65),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255, 98,
                                          9, 21), //background color of button
                                      side: const BorderSide(
                                          width: 1,
                                          color: Color.fromARGB(255, 98, 10,
                                              10)), //border width and color
                                      elevation: 3, //elevation of button
                                      shape: RoundedRectangleBorder(
                                          //to set border radius to button
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: const EdgeInsets.all(
                                          10) //content padding inside button
                                      ),
                                  onPressed: () async {
                                    final data = {
                                      'status': "Accepted",
                                    };
                                    final response = await http.put(
                                      Uri.parse(
                                          'http://localhost:8001/updaterequest/' +
                                              request['id']),
                                      headers: <String, String>{
                                        'Content-Type':
                                            'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode(data),
                                    );
                                  },
                                  child: const Text("Complete the trip"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }
}
