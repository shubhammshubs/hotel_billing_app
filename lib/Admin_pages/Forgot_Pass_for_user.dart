import 'dart:convert';
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '1st_page_admin.dart';



class ForgetPassforUSer extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;


  ForgetPassforUSer({required this.mobileNumber,
    required this.RestoId});

  @override
  State<ForgetPassforUSer> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPassforUSer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  // final TextEditingController _mobileController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController countrycode = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _passwordVisible = false;


  @override
  void initState() {
    // TODO: implement initState
    countrycode.text="+91";
    // _mobileController = TextEditingController(); // Initialize _mobileController with the provided mobile number

    super.initState();
  }
  Future<void> _resetpassword(BuildContext context) async {


    final String apiUrl =
        'https://trifrnd.in/api/inv.php?apicall=updatepwd';

    // Simulate a delay of 1 second
    await Future.delayed(const Duration(seconds: 1));

    final response = await http.post(Uri.parse(apiUrl),
        body: {
          "RestoId": widget.RestoId,
          "mobile": _mobileController.text,
          "password": _confirmPasswordController.text,

        });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Response body: ${response.body}");

      print("Decoded data: $responseData");
      // Fluttertoast.showToast(
      //   msg: "Password reset successful \n Out SIde the IF",
      //   toastLength: Toast.LENGTH_SHORT,
      //   backgroundColor: Colors.green,
      //   textColor: Colors.white,
      // );
      if (responseData == "Done") {
        // Login successful, you can navigate to the next screen
        print("Password reset successful");
        final user = json.decode(response.body)[0];

        Fluttertoast.showToast(
          msg: "Password reset successful",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        // Use Navigator to push HomePage onto the stack
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>FirstPageAdmin(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                )));

      } else {
        // Login failed, show an error message
        print("Password Reset failed");
        Fluttertoast.showToast(
          msg: response.body,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
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
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>FirstPageAdmin(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                )));
        // Return false to prevent the default back button behavior
        return false;
      },
      child: MaterialApp(
        home: Scaffold(
          // appBar: AppBar(
          //   title: const Text('Register Screen'),
          //   backgroundColor: Colors.teal,
          //   centerTitle: true,
          // ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const SizedBox(height: 160,),

                // const SizedBox(height: 30,),

                const Text(
                  'Reset Password',
                  style: TextStyle(
                      fontSize: 35,
                      // color: Colors.green,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Code for Entering Name

                          // const SizedBox(height: 30,),

                          // Code for Entering Email


                          const SizedBox(height: 30,),


                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller: _mobileController,
                              decoration: const InputDecoration(
                                labelText: 'Mobile',
                                hintText: 'Enter Mobile Number',
                                prefixIcon: Icon(Icons.mobile_friendly),
                                border: OutlineInputBorder(),
                              ),
                              maxLength: 10,  // Set the maximum length
                              // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                              onChanged: (String value) {},
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter a mobile';
                                } else if (value.length < 10) {
                                  return 'Mobile number must be 10 Digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10,),



                          // Code for Entering Password
                          //  Password 1
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter Password',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                                // Password visibility toggle
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
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
                          const SizedBox(height: 30,),
                          //  Password 2
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Enter Password Again',
                                hintText: 'Enter Password Again',
                                prefixIcon: Icon(Icons.password),
                                border: OutlineInputBorder(),
                                // Password visibility toggle
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
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
                          const SizedBox(height: 30,),

                          // Code for Submit button

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 35),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              onPressed: () async {
                                // Handle login logic here
                                if (_formKey.currentState!.validate()) {
                                  if (_passwordController.text == _confirmPasswordController.text) {
                                    // await _signUp(context);
                                    _resetpassword(context);

                                    // ('Password reset successful', Colors.green);

                                  }else {
                                    (
                                        Fluttertoast.showToast(
                                          msg: "Passwords do not match !",
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        )
                                    );
                                  }
                                }
                              },
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              child: const Text('Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                ),),
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
