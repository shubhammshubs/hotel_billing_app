import 'dart:convert';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:hotel_billing_app/User_Page/page1User.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Admin_pages/1st_page_admin.dart';
import 'Menu_List.dart';
import 'User_Page/Nav_menu_User.dart';

class HomePage extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;
  final bool isAdmin; // Add isAdmin property

  HomePage({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tableData = [];
  final List<int> bookedTables = [];
  List<Map<String, dynamic>> orderData = [];
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _loading = false;
  String restoName = ''; // Variable to store the resto_name
  String printerName = ''; // Declare printerName at the class level
  String printerAddress = ''; // Declare


  bool _isMounted = false; // Add this line

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTableData();
    fetchRestoName();
    // _handleBluetoothPermission(printerName, printerAddress);

    _isMounted = true; // Add this line
  }
  // Future<void> fetchRestoName() async {
  //   final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readhotel';
  //   final response = await http.post(
  //     Uri.parse(apiUrl),
  //     body: {'RestoId': widget.RestoId},
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     if (data.isNotEmpty) {
  //       setState(() {
  //         restoName = data[0]['resto_name'];
  //         String printerName = data[0]['p_name'];
  //         String printerAddress = data[0]['mac_name'];
  //       });
  //
  //     } else {
  //       print('No data received from readhotel API');
  //     }
  //   } else {
  //     // Handle error
  //     print('Failed to load resto_name: ${response.statusCode}');
  //   }
  // }
  Future<void> fetchRestoName() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readhotel';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      if (data.isNotEmpty) {
        setState(() async {
          restoName = data[0]['resto_name'];
          String printerName = data[0]['p_name'];
          String printerAddress = data[0]['mac_name'];


          await _handleBluetoothPermission(printerName, printerAddress);
          await _connectToBluetoothPrinter(printerName, printerAddress);


        });
      } else {
        print('No data received from readhotel API');
      }
    } else {
      // Handle error
      print('Failed to load resto_name: ${response.statusCode}');
    }
  }


  //  Check the Permission
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
  // Check if the Bluetooth is on or not
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
  // Connect to BT
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
  // Get the Table Name from api
  Future<void> fetchTableData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readtablename';
    // final response = await http.get(Uri.parse(apiUrl));
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        tableData = List.from(data);
      });
    } else {
      // Handle error
      print('Failed to load table data: ${response.statusCode}');
    }
  }
  // Get the In process orders from the api
  Future<void> fetchData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
    // final response = await http.get(Uri.parse(apiUrl));
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        orderData = List.from(data);
      });
    } else {
      // Handle error
      print('Failed to load data: ${response.statusCode}');
    }
  }
  // Filter all the orders to In process orders
  Future<bool> checkIfDataAvailable(String tableName) async {
    String numericPart = tableName.replaceAll(RegExp(r'[^0-9]'), '');
    int parsedTableNumber = int.tryParse(numericPart) ?? 0;

    List<Map<String, dynamic>> ordersForTable = orderData
        .where((order) =>
    order['order_table'] == parsedTableNumber.toString() &&
        order['order_status'] == 'In Process')
        .toList();

    bool isDataAvailable = ordersForTable.isNotEmpty;
    return isDataAvailable;
  }
  Future<bool> _onWillPop() async {
    if (widget.isAdmin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FirstPageAdmin(
            mobileNumber: widget.mobileNumber,
            RestoId: widget.RestoId,
          ),
        ),
      );
      return false; // Prevents the current page from being popped
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FirstPage(
            mobileNumber: widget.mobileNumber,
            RestoId: widget.RestoId,
          ),
        ),
      );
      return false; // Prevents the current page from being popped
    }
  }



  Widget build(BuildContext context) {
    bool isTableBooked;

    return Scaffold(
      key: _scaffoldKey,
      // drawer: NavBar(mobileNumber: widget.mobileNumber, RestoId: widget.RestoId,),
      appBar: AppBar(
        centerTitle: true,
        title:  Text("$restoName"),
        automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.isAdmin) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstPageAdmin(
                      mobileNumber: widget.mobileNumber,
                      RestoId: widget.RestoId,
                    ),
                  ),
                );
                // return false; // Prevents the current page from being popped
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirstPage(
                      mobileNumber: widget.mobileNumber,
                      RestoId: widget.RestoId,
                    ),
                  ),
                );
                // return false; // Prevents the current page from being popped
              }

            },
          ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (widget.isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FirstPageAdmin(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );
            return false; // Prevents the current page from being popped
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FirstPage(
                  mobileNumber: widget.mobileNumber,
                  RestoId: widget.RestoId,
                ),
              ),
            );
            return false; // Prevents the current page from being popped
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await fetchTableData();
            await fetchData();
            await fetchRestoName();
            // await _connectToBluetoothPrinter();
          },
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
            ),
            itemCount: tableData.length,
            itemBuilder: (context, index) {
              isTableBooked =
                  bookedTables.contains(tableData[index]['table_name']);
        
              List<Map<String, dynamic>> ordersForTable = orderData
                  .where((order) =>
              order['order_table'] ==
                  tableData[index]['table_name'].toString() &&
                  order['order_status'] == 'In Process')
                  .toList();
        
              bool isTableInProcess = ordersForTable.isNotEmpty &&
                  ordersForTable
                      .any((order) => order['order_status'] == 'In Process');
              // Button to show the Tables
              return FutureBuilder<bool>(
                future: checkIfDataAvailable(tableData[index]['table_name']),
                builder: (context, snapshot) {
                  bool isDataAvailable = snapshot.data ?? false;
        
                  String tableName = tableData[index]['table_name'];
                  String numericPart =
                  tableName.replaceAll(RegExp(r'[^0-9]'), '');
                  int parsedTableNumber = int.tryParse(tableName) ?? 0;
        
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MenuListPage(
                                  tableNumber: parsedTableNumber,
                                  mobileNumber: widget.mobileNumber,
                                  RestoId: widget.RestoId,
                                  isAdmin: widget.isAdmin,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: isDataAvailable
                            ? Colors.green
                            : isTableBooked
                            ? Colors.green
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(' ${tableData[index]['table_name']}'),
                          Text('Capacity ${tableData[index]['table_capacity']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
