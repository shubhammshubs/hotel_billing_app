// import 'package:flutter/material.dart';
// import 'package:hotel_billing_app/User_Page/page1User.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'Admin_pages/1st_page_admin.dart';
// import 'Home_Screen.dart';
// import 'LandingPage.dart';
// import 'Admin_pages/Admin_Login_Screen.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       // Check login status and get mobile number
//       future: checkLoginStatus(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Still waiting for the check to complete
//           return CircularProgressIndicator(); // or some loading indicator
//         } else {
//           if (snapshot.data!['isLoggedIn']) {
//             // User is logged in, navigate to HomeScreen
//             return MaterialApp(
//               title: 'Grocery App',
//               theme: ThemeData(
//                 primarySwatch: Colors.green,
//               ),
//               home: FirstPageAdmin(
//                 mobileNumber: snapshot.data!['mobileNumber'],
//               ),
//         // HomePage(
//               //   mobileNumber: snapshot.data!['mobileNumber'],
//               // ),
//             );
//           } else {
//             // User is not logged in, navigate to LoginScreen
//             return MaterialApp(
//               title: 'Grocery App',
//               theme: ThemeData(
//                 primarySwatch: Colors.green,
//               ),
//               home: LandingPage(),
//             );
//           }
//         }
//       },
//     );
//   }
//
//   // Function to check login status and get mobile number
//   Future<Map<String, dynamic>> checkLoginStatus() async {
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
//     String? mobileNumber = sharedPreferences.getString('mobile');
//
//     return {
//       'isLoggedIn': isLoggedIn,
//       'mobileNumber': mobileNumber,
//     };
//   }
// }
//
//
//


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Admin_pages/1st_page_admin.dart';
import 'LandingPage.dart';
import 'User_Page/page1User.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        // Check login status and get user type
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Still waiting for the check to complete
            return CircularProgressIndicator(); // or some loading indicator
          } else {
            if (snapshot.data!['isLoggedIn']) {
              // User is logged in
              if (snapshot.data!['userType'] == 'admin') {
                // Redirect to FirstPageAdmin for admin
                return FirstPageAdmin(mobileNumber: snapshot.data!['mobileNumber'], RestoId: snapshot.data!['RestoId'],);
              } else {
                // Redirect to FirstPage for user
                return FirstPage(mobileNumber: snapshot.data!['mobileNumber'], RestoId: snapshot.data!['RestoId'],);
              }
            } else {
              // User is not logged in, redirect to LandingPage
              return LandingPage();
            }
          }
        },
      ),
    );
  }

  // Function to check login status and get user type
  Future<Map<String, dynamic>> checkLoginStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    String? mobileNumber = sharedPreferences.getString('mobile');
    String? RestoId = sharedPreferences.getString('RestoId');
    String? userType = sharedPreferences.getString('userType');

    // Check if RestoId is null and provide a default value if needed
    // RestoId ??= ""; // Replace "" with the default value you want to assign
    print('RestoId from SharedPreferences: $RestoId');

    return {
      'isLoggedIn': isLoggedIn,
      'mobileNumber': mobileNumber,
      'RestoId': RestoId,
      'userType': userType,
    };
  }
}
