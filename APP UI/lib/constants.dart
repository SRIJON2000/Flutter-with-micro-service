// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_shift/screens/auth_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'data_getter.dart';

var user = FirebaseAuth
    .instance.currentUser; // Get User Data from Firebase Auth Database

var defaultBackgroundColor = Colors.grey[300];
var tilePadding = const EdgeInsets.only(left: 8.0, right: 8, top: 8);
var drawerTextColor = TextStyle(
  color: Colors.grey[600],
);

var myAppBar = AppBar(
  backgroundColor: Colors.grey[900],
  title: Text('WELCOME ${details[0]["firstname"]}'),
  centerTitle: false,
);

var myDrawer = Drawer(
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
        onTap: (() {}),
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
        onTap: () {},
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
          FirebaseAuth.instance.signOut();
          // final response = await http.post(
          //     Uri.parse('http://localhost:8000/logout/' + details[0]["email"]));
          // if (response.statusCode == 200) {
          //   Navigator.pushReplacement(context,
          //       MaterialPageRoute(builder: (BuildContext context) {
          //     return AuthPage();
          //   }));
          // }
        },
      ),
    )
  ]),
);
