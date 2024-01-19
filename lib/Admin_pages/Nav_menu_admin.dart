
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hotel_billing_app/Admin_pages/Signup_Screen.dart';
import 'package:hotel_billing_app/LandingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Add_Product.dart';
import 'Admin_Report_Daily.dart';
import 'Admin_Report_Monthly.dart';
import 'Forgot_Pass_for_user.dart';
// import 'draft.dart';


class NavBarAdmin extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;


  NavBarAdmin({
    required this.mobileNumber,
    required this.RestoId});

  @override
  State<NavBarAdmin> createState() => _NavBarState();
}
class _NavBarState extends State<NavBarAdmin> {
  late Map<String, dynamic> userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userData = {};
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: buildDrawer(),
    );
  }

  Widget buildDrawer() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          color: Colors.white60,
          height: 190,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/image/img.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10,),
        // ListTile(
        //   title:
        //   Container(
        //     width: 50.0,
        //     height: 100.0,
        //     child: Image.network(
        //       'https://apip.trifrnd.com/fruits/${userData['userImage']}',
        //       errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        //         return Container(
        //           color: Colors.white70,
        //           child: Icon(
        //             Icons.error,
        //             color: Colors.red,
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
        ListTile(
          title: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Name: ${userData?['username']}" ?? '',style: TextStyle(fontWeight: FontWeight.bold),),
                Text("Email: ${userData?['email']}" ?? ''),
                Text("Mobile: ${widget.mobileNumber}"),
                Text("Gender: ${userData?['gender']}" ?? ''),
              ],
            ),
          ),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.menu_book),

          title: const Text('Add Menu'),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddProductPage(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );
          },
        ),
        // ListTile(
        //   leading: const Icon(Icons.arrow_right),
        //
        //   title: const Text('ProductListWidget'),
        //   onTap: () {
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => ProductListWidget(
        //           mobileNumber: widget.mobileNumber,
        //           RestoId: widget.RestoId,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        // ListTile(
        //   leading: Icon(Icons.person),
        //   title: const Text("User Registration"),
        //   onTap: () {
        //     // Navigator.pushReplacement(
        //     //   context,
        //     //   MaterialPageRoute(
        //     //     builder: (context) => SignUpScreen(
        //     //       mobileNumber: widget.mobileNumber,
        //     //       RestoId: widget.RestoId,
        //     //     ),
        //     //   ),
        //     // );
        //
        //   },
        // ),
        ListTile(
          leading: Icon(Icons.lock_reset),
          title: const Text("Change User Password"),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ForgetPassforUSer(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );

          },
        ),
        // ListTile(
        //   leading: Icon(FontAwesomeIcons.sheetPlastic),
        //
        //   // leading: Icon(Icons.report_gmailerrorred),
        //   title: Text("Daily Report"),
        //   onTap: () {
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => DailyReportAdmin(
        //           mobileNumber: widget.mobileNumber,
        //           RestoId: widget.RestoId,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        ExpansionTile(
          // textColor: Colors.teal,
          // iconColor: Colors.teal,
          leading: Icon(FontAwesomeIcons.sheetPlastic),
          title: const Text('Report'),
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.arrow_right),
              title: const Text('Daily Report'),
              onTap: () {

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DailyReportAdmin(
                      mobileNumber: widget.mobileNumber,
                      RestoId: widget.RestoId,
                    ),
                  ),
                );

              },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_right),

              title: const Text('Monthly Report'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectMonthPage(
                      mobileNumber: widget.mobileNumber,
                      RestoId: widget.RestoId,
                    ),
                  ),
                );
              },
            ),



          ],
        ),

        ListTile(
          leading: Icon(Icons.logout),
          title: Text("Log Out"),
          onTap: () async {
            // Handle tap
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LandingPage(
                  // latestInvoiceId: submittedInvoiceId
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=profile';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'mobile': widget.mobileNumber,
          'RestoId': widget.RestoId
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
        print('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
