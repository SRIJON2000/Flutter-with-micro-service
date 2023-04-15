// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_shift/screens/auth_page.dart';
import 'package:quick_shift/screens/DashboardPages/driver_scaffold.dart';
import 'package:quick_shift/screens/DashboardPages/user_scaffold.dart';
import 'package:quick_shift/screens/DashboardPages/dashboard_loader.dart';

class CheckLoginStatus extends StatelessWidget {
  const CheckLoginStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: StreamBuilder<User?>(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       return DashboardLoader(
        //         userScaffold: UserScaffold(),
        //         driverScaffold: DriverScaffold(),
        //       );
        //     } else {
        //       return const AuthPage();
        //     }
        //   },
        // ),
        );
  }
}
