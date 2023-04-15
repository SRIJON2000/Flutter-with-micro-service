// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_string_escapes, use_build_context_synchronously

import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quick_shift/screens/signup_page.dart';
import '../data_getter.dart';
import 'DashboardPages/dashboard_loader.dart';
import 'DashboardPages/driver_scaffold.dart';
import 'DashboardPages/user_scaffold.dart';
import 'forgot_pw_page.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const SignInScreen({Key? key, required this.showRegisterPage})
      : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Text Controllers for the sign-in form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formEmailValidatorKey = GlobalKey<FormState>();
  final _formPasswordValidatorKey = GlobalKey<FormState>();

  // Future signIn() async {
  //   if (_formEmailValidatorKey.currentState!.validate() &&
  //       _formPasswordValidatorKey.currentState!.validate()) {
  //     // Loading Circle
  //     showDialog(
  //         context: context,
  //         builder: (context) {
  //           return Center(child: CircularProgressIndicator());
  //         });

  //     try {
  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: _emailController.text.trim(),
  //         password: _passwordController.text.trim(),
  //       );
  //       // Pop the Loading Circle After Succesfull SignIn
  //       Navigator.of(context).pop();
  //     } on FirebaseAuthException {
  //       // POP the Loading Circle If error occurs
  //       Navigator.of(context).pop();
  //       showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AlertDialog(
  //               content: Text(
  //             "Wrong Email or Password",
  //             textAlign: TextAlign.center,
  //           ));
  //         },
  //       );
  //     }
  //   }
  // }

  Future<int> authorize(email, password) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/login/?email=$email&password=$password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    int result = int.parse(response.body);
    if (result == 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Text(
            "Wrong Email or Password",
            textAlign: TextAlign.center,
          ));
        },
      );
    } else {
      return result;
    }
    return 0;
  }

  Future<int> signIn() async {
    if (_formEmailValidatorKey.currentState!.validate() &&
        _formPasswordValidatorKey.currentState!.validate()) {
      int result = await authorize(_emailController.text.trim().toString(),
          _passwordController.text.trim().toString());
      print(result);
      return result;
    }
    return 0;
  }

  @override
  // To free the memory after Use
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Quick Shift Logo here
                Image.asset(
                  "assets/images/logo.png",
                  height: 250,
                  width: 250,
                ),

                // Hello again Message!
                Text(
                  'Hello Again!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 52,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 40),

                // Email Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formEmailValidatorKey,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email), // Adds Email Icon
                        contentPadding: EdgeInsets.all(20.0),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      keyboardType:
                          TextInputType.emailAddress, // Shows .com in keyboard
                      autofillHints: [AutofillHints.email],
                      validator: (email) {
                        if (email == null ||
                            email.isEmpty ||
                            !EmailValidator.validate(email)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Password Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formPasswordValidatorKey,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.all(20.0),
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.password),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ForgotPasswordPage();
                            }),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                // Sign In Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: InkWell(
                    onTap: (() async {
                      int y = await signIn();
                      print(y);
                      if (y == 1) {
                        print(y);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const UserScaffold()));
                      } else {
                        // Navigator.of(context).push(MaterialPageRoute(
                        //     builder: (BuildContext context) =>
                        //         DriverScaffold()));
                      }
                    }),
                    child: Ink(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign In',
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
                SizedBox(height: 25),

                // Register Link Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        ' Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Future<String> get_user_type(String email) async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/usertype/' + email));
    if (response.statusCode == 200) {
      List result = [];
      result = jsonDecode(response.body);
      return result[0]['type'].toString();
    }
    return "";
  }
}
