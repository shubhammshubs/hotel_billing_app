
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hotel_billing_app/LandingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Admin_pages/Admin_Login_Screen.dart';
import 'User_Report.dart';

class NavBar extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;


  NavBar({
    required this.mobileNumber,
    required this.RestoId});

  @override
  State<NavBar> createState() => _NavBarState();
}
class _NavBarState extends State<NavBar> {
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
          leading: Icon(FontAwesomeIcons.sheetPlastic),
          title: const Text("Daily Report"),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DailyReportPage(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );
          },
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
        body: {'mobile': widget.mobileNumber,
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
