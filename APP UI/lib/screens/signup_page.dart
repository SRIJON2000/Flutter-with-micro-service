// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Text Controllers for the sign-up form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNoController = TextEditingController();
  final _veichleNameController = TextEditingController();
  final _veichleNoController = TextEditingController();
  // Validators for the sign-up form
  final _formEmailValidatorKey = GlobalKey<FormState>();
  final _formPasswordValidatorKey = GlobalKey<FormState>();
  final _formFnameValidatorKey = GlobalKey<FormState>();
  final _formLnameValidatorKey = GlobalKey<FormState>();
  final _formPhoneValidatorKey = GlobalKey<FormState>();
  final _formTypeValidatorKey = GlobalKey<FormState>();

  final List<String> typeItems = [
    'User',
    'Driver',
  ];

  final List<String> veichleTypes = [
    'Small',
    'Medium',
    'Large',
  ];

  String? selectedRegtype;
  String? selectedVeichletype;

  @override
  // To free the memory after Use
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _licenseNoController.dispose();
    _veichleNameController.dispose();
    _veichleNoController.dispose();

    super.dispose();
  }

  Future signUp() async {
    if (_formFnameValidatorKey.currentState!.validate() &&
        _formLnameValidatorKey.currentState!.validate() &&
        _formEmailValidatorKey.currentState!.validate() &&
        _formPhoneValidatorKey.currentState!.validate() &&
        _formPasswordValidatorKey.currentState!.validate() &&
        _formTypeValidatorKey.currentState!.validate()) {
      if (passwordConfirmed()) {
        // Create User
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        add_userType();

        // Add User Details
        if (selectedRegtype == "User") {
          addUserDetails();
        } else {
          // Add Driver Details
          addDriverDetails();
        }
      }
    }
  }

  // Adding Type of User
  Future add_userType() async {
    await FirebaseFirestore.instance.collection('userType').add({
      'email': _emailController.text.trim(),
      'type': selectedRegtype,
    });
  }

  // Depending on the Registration Type Add data to User or Driver Database in Firebase

  Future addUserDetails() async {
    await FirebaseFirestore.instance.collection('users').add({
      'email': _emailController.text.trim(),
      'firstname': _fnameController.text.trim(),
      'lastname': _lnameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
    });
  }

  Future addDriverDetails() async {
    await FirebaseFirestore.instance.collection('drivers').add({
      'email': _emailController.text.trim(),
      'firstname': _fnameController.text.trim(),
      'lastname': _lnameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'licenseNumber': _licenseNoController.text.trim(),
      'veichleName': _veichleNameController.text.trim(),
      'veichleNumber': _veichleNoController.text.trim(),
      'veichleType': selectedVeichletype,
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
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
                // Hello again Message!
                Text(
                  'Hello There',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 52,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Register below with your details!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 25),

                // First Name Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formFnameValidatorKey,
                    child: TextFormField(
                      controller: _fnameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'First Name',
                        contentPadding: EdgeInsets.all(20.0),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      validator: (fname) {
                        if (fname == null || fname.isEmpty) {
                          return 'Please enter your First Name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Last Name Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formLnameValidatorKey,
                    child: TextFormField(
                      controller: _lnameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Last Name',
                        contentPadding: EdgeInsets.all(20.0),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      validator: (lname) {
                        if (lname == null || lname.isEmpty) {
                          return 'Please enter your Last Name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Phone Number Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formPhoneValidatorKey,
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                        contentPadding: EdgeInsets.all(20.0),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (phone) {
                        if (phone == null || phone.isEmpty) {
                          return 'Please enter your Phone Number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

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

                // Confirm Password Text Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _confirmPasswordController,
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
                      hintText: 'Confirm Password',
                      prefixIcon: Icon(Icons.password),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // User Type Dropdown Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formTypeValidatorKey,
                    child: DropdownButtonFormField2(
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
                        hintText: 'Enter Registration Type',
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black45,
                      ),
                      buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      items: typeItems
                          .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                ),
                              ))
                          .toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select Registration Type.';
                        }
                      },
                      onChanged: (value) {
                        // This will reload page after selecting a Registration Type, It will reload based on the state of selectedValue
                        setState(() {
                          selectedRegtype = value;
                        });
                      },
                      onSaved: (value) {
                        selectedRegtype = value.toString();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Based on User Type (If Driver Then Show This Below Fields else Do not Show)
                // License Number
                Column(
                  children: <Widget>[
                    // Only Visible when Driver is selected from Dropdown
                    if (selectedRegtype == "Driver") ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Form(
                          child: TextFormField(
                            controller: _licenseNoController,
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
                              hintText: 'License Number',
                              contentPadding: EdgeInsets.all(20.0),
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),

                SizedBox(height: 10),

                // Veichle Name Text Field
                Column(
                  children: <Widget>[
                    // Only Visible when Driver is selected from Dropdown
                    if (selectedRegtype == "Driver") ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Form(
                          child: TextFormField(
                            controller: _veichleNameController,
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
                              hintText: 'Veichle Name',
                              contentPadding: EdgeInsets.all(20.0),
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),

                SizedBox(height: 10),

                // Veichle Type Dropdown Field
                Column(
                  children: <Widget>[
                    // Only Visible when Driver is selected from Dropdown
                    if (selectedRegtype == "Driver") ...[
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
                              contentPadding: EdgeInsets.all(20.0),
                              hintText: 'Enter Veichle Type',
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
                            },
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
                SizedBox(height: 10),

                // Veichle Number Text Field
                Column(
                  children: <Widget>[
                    // Only Visible when Driver is selected from Dropdown
                    if (selectedRegtype == "Driver") ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Form(
                          child: TextFormField(
                            controller: _veichleNoController,
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
                              hintText: 'Veichle Number',
                              contentPadding: EdgeInsets.all(20.0),
                              fillColor: Colors.grey[200],
                              filled: true,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),

                SizedBox(height: 10),

                // Sign Up Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: InkWell(
                    onTap: signUp,
                    child: Ink(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Up',
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
                      'I am a member',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }
}
