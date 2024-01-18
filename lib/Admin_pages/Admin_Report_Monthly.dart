import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:hotel_billing_app/Admin_pages/1st_page_admin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:permission_handler/permission_handler.dart';

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
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _loading = false;

  @override

  void initState() {
    super.initState();
    // Set selectedDate to the current date when the page is opened
    selectedDate = DateTime.now();
    // Fetch data for the current month
    fetchAllReportData();
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
      List<dynamic> tableData = await fetchAllReportData();

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
          'Date: ${item['created'].split(' ')[1]}\n'
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



  // Future<void> fetchAllReportData() async {
  //   final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=allrep';
  //
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     body: {
  //       'RestoId': widget.RestoId,
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     try {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       setState(() {
  //         allReportData = data;
  //         filterMonthlyReport();
  //       });
  //     } catch (e) {
  //       print('Failed to decode JSON: $e');
  //       setState(() {
  //         allReportData = [];
  //       });
  //     }
  //   } else {
  //     print('Failed to load all report data: ${response.statusCode}');
  //     setState(() {
  //       allReportData = [];
  //     });
  //   }
  // }
  Future<List<dynamic>> fetchAllReportData() async {
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
        return data; // Return the fetched data
      } catch (e) {
        print('Failed to decode JSON: $e');
        setState(() {
          allReportData = [];
        });
        return []; // Return an empty list in case of an error
      }
    } else {
      print('Failed to load all report data: ${response.statusCode}');
      setState(() {
        allReportData = [];
      });
      return []; // Return an empty list in case of an HTTP error
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
        title: Text("Monthly Report "),
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
              await fetchRestaurantData();
            }
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [

                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      ElevatedButton(
                        onPressed: () => _printData(),
                        child: Text("Print"),
                      ),
                    ],
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
                  //   SingleChildScrollView(
                  //     child:
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
                    // ),
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