// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hotel_billing_app/User_Page/page1User.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
//
// class DailyReportPage extends StatefulWidget {
//   final String mobileNumber;
//   final String RestoId;
//
//   DailyReportPage({
//     Key? key,
//     required this.mobileNumber,
//     required this.RestoId,
//   }) : super(key: key);
//
//   @override
//   _DailyReportPageState createState() => _DailyReportPageState();
// }
//
// class _DailyReportPageState extends State<DailyReportPage> {
//   List<Map<String, String>> dailyReportData =
//       []; // Variable to store the daily report data
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDailyReportData(); // Fetch daily report data
//   }
//
//   Future<void> fetchDailyReportData() async {
//     final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readrep';
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       body: {'RestoId': widget.RestoId},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       setState(() {
//         dailyReportData = List<Map<String, String>>.from(data.map((item) => {
//               'inv_id': item['inv_id'].toString(),
//               // Ensure 'inv_id' is a String
//               'table_no': item['table_no'].toString(),
//               // Ensure 'table_no' is a String
//               'bill_amt': item['bill_amt'].toString(),
//               // Ensure 'bill_amt' is a String
//               'created': item['created'].toString(),
//               // Ensure 'created' is a String
//             }));
//       });
//     } else {
//       // Handle error
//       print('Failed to load daily report data: ${response.statusCode}');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:AppBar(
//         centerTitle: true,
//         title: Text("Daily Report"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => FirstPage(
//                   mobileNumber: widget.mobileNumber,
//                   RestoId: widget.RestoId,
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//
//       body: WillPopScope(
//         onWillPop: () async {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FirstPage(
//                 mobileNumber: widget.mobileNumber,
//                 RestoId: widget.RestoId,
//               ),
//             ),
//           );
//           return false; // Returning false to prevent the back navigation
//         },
//         child: ListView.builder(
//           itemCount: dailyReportData.length,
//           itemBuilder: (context, index) {
//             String? dateTimeString = dailyReportData[index]['created'];
//             DateTime dateTime = DateTime.parse(dateTimeString!);
//             String formattedTime = "${DateFormat.Hm().format(dateTime)}";
//
//             return Card(
//               elevation: 5,
//               margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: ListTile(
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Inv ID: ${dailyReportData[index]['inv_id']}",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//
//
//                     Text("Time: $formattedTime"),
//
//                   ],
//                 ),
//                 subtitle: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Table No: ${dailyReportData[index]['table_no']}",
//                     ),
//                     Text("Bill Amount: ₹${dailyReportData[index]['bill_amt']}"),
//
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }





import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:hotel_billing_app/Admin_pages/1st_page_admin.dart';
import 'package:hotel_billing_app/User_Page/page1User.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class DailyReportPage extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;

  DailyReportPage({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
  }) : super(key: key);

  @override
  _DailyReportAdminState createState() => _DailyReportAdminState();
}

class _DailyReportAdminState extends State<DailyReportPage> {
  DateTime selectedDate = DateTime.now();
  List<dynamic> dailyReportData = [];
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _loading = false;



  @override
  void initState() {
    super.initState();
    fetchRestaurantData();
    fetchDailyReportData(); // Fetch initial data
    fetchRestoName();
  }


  // Here we check the status of the Bluetooth Connection.

  Future<void> fetchRestoName() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readhotel';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        setState(() {
          String restoName = data[0]['resto_name'];
          String printerName = data[0]['p_name'];
          String printerAddress = data[0]['mac_name'];

          // Call the function with the retrieved data
          _connectToBluetoothPrinter(printerName, printerAddress);
          _handleBluetoothPermission(printerName, printerAddress);

        });
      } else {
        print('No data received from readhotel API');
      }
    } else {
      // Handle error
      print('Failed to load resto_name: ${response.statusCode}');
    }
  }


  // In this function connection to Printer code performed
  Future<Map<String, dynamic>> fetchRestaurantData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readhotel';
    // final responce = await http.get(Uri.parse(apiUrl));
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return Map<String, dynamic>.from(data.first);
    } else {
      throw Exception('Failed to load tha Data: ${response.statusCode}');
    }
  }
  Future<void> _handleBluetoothPermission(String printerName, String printerAddress) async {
    var bluetoothPermissionStatus = await Permission.bluetooth.request();
    var bluetoothScanPermissionStatus =
    await Permission.bluetoothScan.request();

    if (bluetoothPermissionStatus.isGranted &&
        bluetoothScanPermissionStatus.isGranted) {
      print("Bluetooth Permission Granted");
      await _checkBluetoothStatus(printerName, printerAddress);
    } else {
      print("Bluetooth Permission Failed");
    }
  }

  Future<void> _checkBluetoothStatus(String printerName, String printerAddress) async {
    bool isBluetoothOn =
    await BluetoothEnable.enableBluetooth.then((result) async {
      print("Bluetooth IS On Stage one");
      // await _connectToBluetoothPrinter();
      await _connectToBluetoothPrinter(printerName, printerAddress);

      return result == "true";
    });

    if (isBluetoothOn) {
      print("Bluetooth IS On");
      // await _connectToBluetoothPrinter();
      await _connectToBluetoothPrinter(printerName, printerAddress);

    } else {
      print("Bluetooth IS Off");
    }
  }

  Future<void> _connectToBluetoothPrinter(String printerName, String printerAddress) async {
    try {
      setState(() {
        _loading = true;
      });

      // String printerName = "BlueTooth Printer";
      // String printerAddress = "DC:0D:30:CA:34:E6";

      BluetoothDevice device = BluetoothDevice();
      device.name = printerName;
      device.address = printerAddress;

      print('Selected Bluetooth Device: ${device.name ?? 'Unknown'}');

      if (await bluetoothPrint.isConnected == true) {
        // print('Already connected to ${device.name}');
        await bluetoothPrint.connect(device);
      } else {
        await bluetoothPrint.connect(device);

        if (bluetoothPrint.state == BluetoothPrint.CONNECTED) {
          print('Connected to ${device.name} successfully.');
        } else {
          print('Connection failed. State: ${bluetoothPrint.state}');
          return;
        }
      }

      // print('Bluetooth connection successful. You can start printing or perform other tasks.');
    } catch (e, stackTrace) {
      print('Bluetooth connection error: $e');
      print('Stack trace: $stackTrace');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }


// ...

  Future<void> _printData() async {
    try {
      // Assuming you have fetched the table data in the widget's state
      List<dynamic> tableData = await fetchDailyReportData();

      // Fetch restaurant data
      final restaurantData = await fetchRestaurantData();

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '${restaurantData['resto_name']}',
          weight: 20,
          size: 20,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'A taste you will remember',
          // weight: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '${restaurantData['resto_address1']}',
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '${restaurantData['resto_city']}',
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
      ));

      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "",
        // Empty content for space
        width: 2,
        // Adjust this value to control the amount of space on the left
        linefeed: 1,
      ));


      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "",
        // Empty content for space
        width: 2,
        // Adjust this value to control the amount of space on the left
        linefeed: 1,
      ));
      // ...


      // Add header
      // list.add(LineText(
      //   type: LineText.TYPE_TEXT,
      //   content: 'Inv ID | Table No | Bill Amount | Created',
      //   align: LineText.ALIGN_LEFT,
      //   linefeed: 1,
      // ));

      // Add separator
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "-----------------------------------",
        width: 2,
        linefeed: 1,
      ));

      // Add items from API response
      for (var item in tableData) {


        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
          'Inv ID: ${item['inv_id']}       Table No: ${item['table_no']}\n'
              'Amount: ${item['bill_amt']}   Time: ${item['created'].split(' ')[1]}\n', // Extracting only the time part
          align: LineText.ALIGN_LEFT,
          linefeed: 1,
        ));
        list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "-------------------------------",
          width: 2,
          linefeed: 1,
        ));
      }

      // ...

      await bluetoothPrint.printReceipt(config, list);

      print('Bluetooth Result is:${bluetoothPrint.state}');
    } catch (e, stackTrace) {
      print('Printing error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<List<dynamic>> fetchDailyReportData() async {
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
        return data;
      } catch (e) {
        // Handle JSON decoding error (unexpected content)
        print('Failed to decode JSON: $e');
        setState(() {
          dailyReportData = []; // Set data to an empty list
        });
        return []; // Return an empty list in case of an error
      }
    } else {
      // Handle HTTP error
      print('Failed to load daily report data: ${response.statusCode}');
      setState(() {
        dailyReportData = []; // Set data to an empty list
      });
      return []; // Return an empty list in case of an error
    }
  }

// ...


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
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchDailyReportData();
            await fetchRestoName();
            // await _connectToBluetoothPrinter();

          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: Text("Select Date"),
                      ),
                      ElevatedButton(
                        onPressed: () => _printData(),
                        child: Text("Print"),
                      ),
                    ],
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

