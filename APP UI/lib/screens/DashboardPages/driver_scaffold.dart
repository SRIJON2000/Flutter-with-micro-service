// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:quick_shift/constants.dart';
import 'package:quick_shift/data_getter.dart';
import 'package:quick_shift/screens/DashboardPages/driver_booking.dart';
import 'package:http/http.dart' as http;
import '../auth_page.dart';

class DriverScaffold extends StatefulWidget {
  const DriverScaffold({super.key});

  @override
  State<DriverScaffold> createState() => _UserBookingState();
}

class _UserBookingState extends State<DriverScaffold> {
  List requests = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch_pending_requests();
  }

  Future<void> fetch_pending_requests() async {
    final response =
        await http.get(Uri.parse('http://localhost:8001/pendingrequest/'));
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
                'M Y  S H I F T S',
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
                // FirebaseAuth.instance.signOut();
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
                                    AssetImage("assets/images/destination.png"),
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
                                      await FlutterPhoneDirectCaller.callNumber(
                                          request['userPhoneNo'].toString());
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
                    SizedBox(height: 6),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              onPressed: () async {
                                final data = {
                                  'driverName': details[0]['firstname'] +
                                      " " +
                                      details[0]['lastname'],
                                  'driverEmail': details[0]['email'],
                                  'driverPhoneNo': details[0]['phoneNumber'],
                                  'status': "Accepted",
                                };
                                final response = await http.put(
                                  Uri.parse(
                                      'http://localhost:8001/updaterequest/' +
                                          request['id'].toString()),
                                  headers: {
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(data),
                                );
                                setState(() {});
                              },
                              child: Text(
                                "Accept",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 40),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              onPressed: () {},
                              child: Text(
                                "Decline",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
