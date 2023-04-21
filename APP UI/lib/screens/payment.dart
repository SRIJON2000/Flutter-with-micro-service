import 'dart:convert';
import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:quick_shift/screens/DashboardPages/user_booking.dart';
import 'package:quick_shift/screens/DashboardPages/user_scaffold.dart';

import '../data_getter.dart';

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // By using this first we are setting values user_firstname & user_phoneNumber orelse those values will be pushed as NULL to request collection
  }

  final nameController = TextEditingController();
  final _formValidatorKey = GlobalKey<FormState>();
  final List<String> types = [
    'UPI',
    'Net Banking',
    'Credit Cards',
  ];
  String? selectedtype;
  Future<int> get_next_payment_id() async {
    final response =
        await http.get(Uri.parse('http://localhost:8002/nextpaymentid'));
    if (response.statusCode == 200) {
      //List requests = [];
      int requests = int.parse(response.body);
      if (requests == 1) {
        return 1;
      }
      return requests;
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> pay() async {
    if (_formValidatorKey.currentState!.validate()) {
      int t = await get_next_payment_id();
      // //int Value = Random().nextInt(2);
      // int Value = 1; // Value is >= 0 and < 2
      final request = <String, dynamic>{
        "id": t,
        "name": nameController.text.toString(),
        "amount": "500",
        "type": selectedtype,
        "trans_id": trans_id.toString(),
      };
      final response = await http.put(
        Uri.parse('http://localhost:8002/createpayment/' + trans_id.toString()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );
      int r = int.parse((response.body));
      if (r == 1) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return UserBooking();
        }));
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Container(
                    height: 100,
                    child: Column(children: [
                      const Text(
                        "Payment Failed",
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
                            return UserBooking();
                          }));
                        },
                        child: const Text("Go to Bookings"),
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: Colors.black54, //background color of app bar
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hello again Message!
                Text(
                  'THANK YOU',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 52,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Amount Rs. 500',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'Please select payment method',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 25),

                Text(
                  'Payment Type',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 25),
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
                          borderSide: BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.all(12.0),
                        hintText: 'Enter Payment Type',
                        prefixIcon: Icon(Icons.payment),
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
                      items: types
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
                          selectedtype = value.toString();
                        });
                      },
                      onSaved: (value) {
                        selectedtype = value.toString();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Form(
                    key: _formValidatorKey,
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Enter Name',
                        contentPadding: const EdgeInsets.all(12.0),
                        fillColor: Colors.grey[200],
                        filled: true,
                      ),
                      validator: (breed) {
                        if (breed == null || breed.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: pay,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Pay',
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: (() async {
                      final response = await http.delete(
                        Uri.parse(
                            'http://localhost:8001/deleterequest/request/trans_id/' +
                                trans_id.toString()),
                      );
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return UserScaffold();
                      }));
                    }),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
