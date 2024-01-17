

import 'package:flutter/material.dart';
import 'package:hotel_billing_app/Admin_pages/1st_page_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DailyReportAdmin extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;

  DailyReportAdmin({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
  }) : super(key: key);

  @override
  _DailyReportAdminState createState() => _DailyReportAdminState();
}

class _DailyReportAdminState extends State<DailyReportAdmin> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> dailyReportData = [];

  @override
  void initState() {
    super.initState();
    fetchDailyReportData(); // Fetch initial data
  }

  Future<void> fetchDailyReportData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readdailyrep';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'RestoId': widget.RestoId,
        'curdate': DateFormat('yyyy-MM-dd').format(selectedDate),
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          dailyReportData = data;
        });
      } catch (e) {
        // Handle JSON decoding error (unexpected content)
        print('Failed to decode JSON: $e');
        setState(() {
          dailyReportData = []; // Set data to an empty list
        });
      }
    } else {
      // Handle HTTP error
      print('Failed to load daily report data: ${response.statusCode}');
      setState(() {
        dailyReportData = []; // Set data to an empty list
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      // Fetch data for the selected date
      await fetchDailyReportData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Daily Report "),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FirstPageAdmin(
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
              builder: (context) => FirstPageAdmin(
                mobileNumber: widget.mobileNumber,
                RestoId: widget.RestoId,
              ),
            ),
          );
          return false; // Returning false to prevent the back navigation
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchDailyReportData();
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text("Select Date"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Display daily report data here
                  if (dailyReportData.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 100,),
                        Card(
                          // elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.report_gmailerrorred,color: Colors.red,),
                                SizedBox(height: 10,),

                                Text(
                                  "No data available for the selected date.",
                                  style: TextStyle(fontSize: 16),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Text("No data available for the selected date."),
                  if (dailyReportData.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: dailyReportData.length,
                      itemBuilder: (context, index) {
                        String formattedTime = DateFormat.Hm().format(DateTime.parse(dailyReportData[index]['created']));

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Inv ID: ${dailyReportData[index]['inv_id']}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text("Time: $formattedTime"),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Table No: ${dailyReportData[index]['table_no']}"),
                                Text("Bill Amount: ₹${dailyReportData[index]['bill_amt']}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}