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
      title: 'Hotel Billing App',
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

/* Admin Report Commented file here */
// import 'package:flutter/material.dart';
// import 'package:hotel_billing_app/Admin_pages/1st_page_admin.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';
//
// class DailyReportAdmin extends StatefulWidget {
//   final String mobileNumber;
//   final String RestoId;
//
//   DailyReportAdmin({
//     Key? key,
//     required this.mobileNumber,
//     required this.RestoId,
//   }) : super(key: key);
//
//   @override
//   _DailyReportAdminState createState() => _DailyReportAdminState();
// }
//
// class _DailyReportAdminState extends State<DailyReportAdmin> {
//   DateTime selectedDate = DateTime.now();
//   List<dynamic> dailyReportData = [];
//   List<dynamic> allReportData = [];
//   List<dynamic> monthlyReportData = [];
//   bool isMonthlyData = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDailyReportData(); // Fetch initial data
//     fetchAllReportData();
//   }
//
//   Future<void> fetchDailyReportData() async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readdailyrep';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'RestoId': widget.RestoId,
//         'curdate': DateFormat('yyyy-MM-dd').format(selectedDate),
//       },
//     );
//
//     if (response.statusCode == 200) {
//       try {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           dailyReportData = data;
//         });
//       } catch (e) {
//         print('Failed to decode JSON: $e');
//         setState(() {
//           dailyReportData = [];
//         });
//       }
//     } else {
//       print('Failed to load daily report data: ${response.statusCode}');
//       setState(() {
//         dailyReportData = [];
//       });
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2024),
//       lastDate: DateTime(2025),
//     );
//
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//
//       await fetchDailyReportData();
//     }
//   }
//
//   Future<void> fetchAllReportData() async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=allrep';
//
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {
//         'RestoId': widget.RestoId,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       try {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           allReportData = data;
//           filterMonthlyReport();
//         });
//       } catch (e) {
//         print('Failed to decode JSON: $e');
//         setState(() {
//           allReportData = [];
//         });
//       }
//     } else {
//       print('Failed to load all report data: ${response.statusCode}');
//       setState(() {
//         allReportData = [];
//       });
//     }
//   }
//
//   void filterMonthlyReport() {
//     final String selectedMonth = DateFormat('MM').format(selectedDate);
//     monthlyReportData = allReportData.where((report) {
//       final String reportMonth = DateFormat('MM').format(DateTime.parse(report['created']));
//       return reportMonth == selectedMonth;
//     }).toList();
//   }
//
//   Future<void> _selectMonth(BuildContext context) async {
//     DateTime pickedMonth = DateTime.now();
//     pickedMonth = await showMonthPicker(
//       context: context,
//       firstDate: DateTime(2024, 1),
//       lastDate: DateTime(2025, 12),
//       initialDate: selectedDate,
//     ) ?? selectedDate;
//
//     if (pickedMonth != selectedDate) {
//       setState(() {
//         selectedDate = pickedMonth;
//         filterMonthlyReport();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text("Daily Report "),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => FirstPageAdmin(
//                   mobileNumber: widget.mobileNumber,
//                   RestoId: widget.RestoId,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       body: WillPopScope(
//         onWillPop: () async {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FirstPageAdmin(
//                 mobileNumber: widget.mobileNumber,
//                 RestoId: widget.RestoId,
//               ),
//             ),
//           );
//           return false;
//         },
//         child: RefreshIndicator(
//           onRefresh: () async {
//             if (isMonthlyData) {
//               await fetchAllReportData();
//             } else {
//               await fetchDailyReportData();
//             }
//           },
//           child: SingleChildScrollView(
//             child: Center(
//               child: Column(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         isMonthlyData = false;
//                       });
//                       _selectDate(context);
//                     },
//                     child: Text("Select Date"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         isMonthlyData = true;
//                       });
//                       _selectMonth(context);
//                     },
//                     child: Text("Select Month"),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     "Selected ${isMonthlyData ? 'Month' : 'Date'}: ${isMonthlyData ? DateFormat('MM/yyyy').format(selectedDate) : DateFormat('dd/MM/yyyy').format(selectedDate)}",
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//
//                   if (isMonthlyData && monthlyReportData.isEmpty)
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 100,),
//                         Card(
//                           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 Icon(Icons.report_gmailerrorred,color: Colors.red,),
//                                 SizedBox(height: 10,),
//                                 Text(
//                                   "No data available for the selected month.",
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (!isMonthlyData && dailyReportData.isEmpty)
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         SizedBox(height: 100,),
//                         Card(
//                           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               children: [
//                                 Icon(Icons.report_gmailerrorred,color: Colors.red,),
//                                 SizedBox(height: 10,),
//                                 Text(
//                                   "No data available for the selected date.",
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (isMonthlyData && monthlyReportData.isNotEmpty)
//                   // Display monthly report data
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: monthlyReportData.length,
//                       itemBuilder: (context, index) {
//                         String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(monthlyReportData[index]['created']));
//
//                         String formattedTime = DateFormat.Hm().format(DateTime.parse(monthlyReportData[index]['created']));
//
//                         return Card(
//                           elevation: 5,
//                           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           child: ListTile(
//                             title: Column(
//                               children: [
//                                 if (isMonthlyData) Text("$formattedDate"), // Display Date only for Select Month
//                                 SizedBox(height: 10,),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       "Inv ID: ${monthlyReportData[index]['inv_id']}",
//                                       style: TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     Text("Time: $formattedTime"),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             subtitle: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Table No: ${monthlyReportData[index]['table_no']}"),
//                                 Text("Bill Amount: ₹${monthlyReportData[index]['bill_amt']}"),
//
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   if (!isMonthlyData && dailyReportData.isNotEmpty)
//                   // Display daily report data
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: dailyReportData.length,
//                       itemBuilder: (context, index) {
//                         String formattedTime = DateFormat.Hm().format(DateTime.parse(dailyReportData[index]['created']));
//
//                         return Card(
//                           elevation: 5,
//                           margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                           child: ListTile(
//                             title: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Inv ID: ${dailyReportData[index]['inv_id']}",
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 Text("Time: $formattedTime"),
//                               ],
//                             ),
//                             subtitle: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text("Table No: ${dailyReportData[index]['table_no']}"),
//                                 Text("Bill Amount: ₹${dailyReportData[index]['bill_amt']}"),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

