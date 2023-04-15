// // ignore_for_file: unrelated_type_equality_checks, prefer_const_constructors

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
// import 'package:quick_shift/data_getter.dart';
// import 'package:http/http.dart' as http;
// import 'package:quick_shift/screens/signin_page.dart';

// class DashboardLoader extends StatelessWidget {
//   const DashboardLoader(
//       {super.key,
//       required this.userScaffold,
//       required this.driverScaffold,
//       required this.email});

//   final Widget userScaffold;
//   final Widget driverScaffold;
//   final String email;

//   @override
//   Future<Widget> build(BuildContext context) async {
//     // return FutureBuilder(
//     //     future: getUser_type(),
//     //     builder: (context, snapshot) {
//     //       if (snapshot.connectionState == ConnectionState.done) {
//     //         if (type == 'User') {
//     //           return userScaffold;
//     //         } else {
//     //           return driverScaffold;
//     //         }
//     //       } else {
//     //         return Center(child: CircularProgressIndicator());
//     //       }
//     //     });
//     final response =
//         await http.post(Uri.parse('http://localhost:8000/authorize/$email'));
//     if (response.statusCode == 200) {
//       List result = [];
//       result = jsonDecode(response.body);
//       if (result[0]['type'] == "User") {
//         return userScaffold;
//       } else {
//         return driverScaffold;
//       }
//     }
//     return driverScaffold;
//   }
// }
