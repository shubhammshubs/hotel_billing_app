import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hotel_billing_app/User_Page/page1User.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DailyReportPage extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;

  DailyReportPage({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
  }) : super(key: key);

  @override
  _DailyReportPageState createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  List<Map<String, String>> dailyReportData =
      []; // Variable to store the daily report data

  @override
  void initState() {
    super.initState();
    fetchDailyReportData(); // Fetch daily report data
  }

  Future<void> fetchDailyReportData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readrep';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        dailyReportData = List<Map<String, String>>.from(data.map((item) => {
              'inv_id': item['inv_id'].toString(),
              // Ensure 'inv_id' is a String
              'table_no': item['table_no'].toString(),
              // Ensure 'table_no' is a String
              'bill_amt': item['bill_amt'].toString(),
              // Ensure 'bill_amt' is a String
              'created': item['created'].toString(),
              // Ensure 'created' is a String
            }));
      });
    } else {
      // Handle error
      print('Failed to load daily report data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        title: Text("Daily Report"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FirstPage(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );
          },
        ),
      ),

      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FirstPage(
                mobileNumber: widget.mobileNumber,
                RestoId: widget.RestoId,
              ),
            ),
          );
          return false; // Returning false to prevent the back navigation
        },
        child: ListView.builder(
          itemCount: dailyReportData.length,
          itemBuilder: (context, index) {
            String? dateTimeString = dailyReportData[index]['created'];
            DateTime dateTime = DateTime.parse(dateTimeString!);
            String formattedTime = "${DateFormat.Hm().format(dateTime)}";

            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Inv ID: ${dailyReportData[index]['inv_id']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),


                    Text("Time: $formattedTime"),

                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Table No: ${dailyReportData[index]['table_no']}",
                    ),
                    Text("Bill Amount: ₹${dailyReportData[index]['bill_amt']}"),

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
