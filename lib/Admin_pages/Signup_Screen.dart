import 'dart:convert';
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hotel_billing_app/User_Page/page1User.dart';
import 'package:http/http.dart' as http;

import 'Admin_Login_Screen.dart';

class SignUpScreen extends StatefulWidget {

  @override
  State<SignUpScreen> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _mobileController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  TextEditingController countrycode = TextEditingController();


  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female'];

  @override
  void initState() {
    countrycode.text = "+91";
    // _mobileController = TextEditingController(text: widget.mobileNumber); // Initialize _mobileController with the provided mobile number

    super.initState();
  }

  Future<void> _signUp(BuildContext context) async {
    final String apiUrl =
        'https://trifrnd.in/api/inv.php?apicall=signup';

    // Simulate a delay of 1 second
    await Future.delayed(const Duration(seconds: 1));

    final response = await http.post(Uri.parse(apiUrl), body: {
      "username": _nameController.text,
      "email": _emailController.text,
      "mobile": _mobileController.text,
      "password": _passwordController.text,
      "gender": selectedGender,
    });
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Response body: ${response.body}");

      print("Decoded data: $responseData");

      if (responseData == "User registered successfully") {
        // Login successful, you can navigate to the next screen
        print("Register successful");
        final user = json.decode(response.body)[0];

        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Use Navigator to push HomePage onto the stack
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => FirstPage(
                mobileNumber: _mobileController.text,
              )),
        );
      } else {
        // Login failed, show an error message
        print("Login failed");
        Fluttertoast.showToast(
          msg: "You Are Already Registered, Please Login to Continue",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginAdminScreen()
            //     HomePage(
            //   mobileNumber: _mobileController.text,
            //       // product: widget.product,
            // ),
          ),
        );
      }
    } else {
      // Handle error if the API call was not successful
      print("API call failed");
      Fluttertoast.showToast(
        msg: "Server Connction Error!",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the SignInPage when the back button is pressed
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => LoginScreen()),
        // );
        // Return false to prevent the default back button behavior
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Register Screen',
              style: TextStyle(fontWeight: FontWeight.bold,
                // fontSize: 30,
              ),
            ),
            // backgroundColor: Colors.blueAccent,
            centerTitle: true,
            automaticallyImplyLeading:
            false, // Set this to false to hide the back button
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                // Text(
                //   'Register',
                //   style: TextStyle(color: Colors.black,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 30,
                //   ),
                //   // style: TextStyle(
                //   //     fontSize: 35,
                //   //     color: Colors.teal.shade300,
                //   //     fontWeight: FontWeight.bold
                //   // ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Code for Entering Name
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                hintText: 'Enter Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          // Code for Entering Email

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter Email',
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                                // Code for Entering Mobile Number
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                border:
                                Border.all(width: 1, color: Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.mobile_friendly,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: TextFormField(
                                      readOnly: true,
                                      // Set the field to read-only
                                      controller: countrycode,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "|",
                                    style: TextStyle(
                                        fontSize: 33, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      maxLength: 10,  // Set the maximum length

                                      // readOnly: true, // Set the field to read-only
                                      // readOnly: true, // Set the field to read-only
                                      keyboardType: TextInputType.number,
                                      controller: _mobileController,
                                      // Use the _mobileController to display the mobile number
                                      // keyboardType: TextInputType.number,
                                      // controller: _mobileController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Phone',

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(FontAwesomeIcons.venusMars),
                                border: OutlineInputBorder(),
                              ),
                              value: selectedGender,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedGender = newValue;
                                });
                              },
                              items: genderOptions.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // Code for Entering Password

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter Password ',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),

                          // Code for Submit button

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              onPressed: () async {
                                // Handle login logic here
                                if (_formKey.currentState!.validate()) {
                                  // Perform the login
                                  await _signUp(context);
                                }
                              },
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginAdminScreen(),
                                  ));
                            },
                            child: const Text(
                              "Go TO Login",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
