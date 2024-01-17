import 'package:flutter/material.dart';
import 'package:hotel_billing_app/Admin_pages/1st_page_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class SelectMonthPage extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;

  SelectMonthPage({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
  }) : super(key: key);

  @override
  _DailyReportAdminState createState() => _DailyReportAdminState();
}

class _DailyReportAdminState extends State<SelectMonthPage> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> dailyReportData = [];
  List<dynamic> allReportData = [];
  List<dynamic> monthlyReportData = [];
  bool isMonthlyData = false;

  @override

  void initState() {
    super.initState();
    // Set selectedDate to the current date when the page is opened
    selectedDate = DateTime.now();
    // Fetch data for the current month
    fetchAllReportData();
  }




  Future<void> fetchAllReportData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=allrep';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'RestoId': widget.RestoId,
      },
    );

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allReportData = data;
          filterMonthlyReport();
        });
      } catch (e) {
        print('Failed to decode JSON: $e');
        setState(() {
          allReportData = [];
        });
      }
    } else {
      print('Failed to load all report data: ${response.statusCode}');
      setState(() {
        allReportData = [];
      });
    }
  }

  void filterMonthlyReport() {
    final String selectedMonth = DateFormat('MM').format(selectedDate);
    monthlyReportData = allReportData.where((report) {
      final String reportMonth = DateFormat('MM').format(DateTime.parse(report['created']));
      return reportMonth == selectedMonth;
    }).toList();
  }

  Future<void> _selectMonth(BuildContext context) async {
    DateTime pickedMonth = DateTime.now();
    pickedMonth = await showMonthPicker(
      context: context,
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(2025, 12),
      initialDate: selectedDate,
    ) ?? selectedDate;

    if (pickedMonth != selectedDate) {
      setState(() {
        selectedDate = pickedMonth;
        filterMonthlyReport();
      });
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
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (isMonthlyData) {
              await fetchAllReportData();
            }
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isMonthlyData = true;
                      });
                      _selectMonth(context);
                    },
                    child: Text("Select Month"),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Selected ${isMonthlyData ? 'Month' : 'Date'}: ${isMonthlyData ? DateFormat('MM/yyyy').format(selectedDate) : DateFormat('dd/MM/yyyy').format(selectedDate)}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  if (isMonthlyData && monthlyReportData.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 100,),
                        Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.report_gmailerrorred,color: Colors.red,),
                                SizedBox(height: 10,),
                                Text(
                                  "No data available for the selected month.",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (isMonthlyData && monthlyReportData.isNotEmpty)
                  // Display monthly report data
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: monthlyReportData.length,
                      itemBuilder: (context, index) {
                        String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(monthlyReportData[index]['created']));

                        String formattedTime = DateFormat.Hm().format(DateTime.parse(monthlyReportData[index]['created']));

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Column(
                              children: [
                                if (isMonthlyData) Text("$formattedDate"), // Display Date only for Select Month
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Inv ID: ${monthlyReportData[index]['inv_id']}",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text("Time: $formattedTime"),
                                  ],
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Table No: ${monthlyReportData[index]['table_no']}"),
                                Text("Bill Amount: ₹${monthlyReportData[index]['bill_amt']}"),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  if (!isMonthlyData && dailyReportData.isNotEmpty)
                  // Display daily report data
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