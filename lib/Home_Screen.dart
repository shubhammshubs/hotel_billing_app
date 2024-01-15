import 'dart:convert';

import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:hotel_billing_app/User_Page/page1User.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Menu_List.dart';
import 'Nav_menu.dart';

class HomePage extends StatefulWidget {
  final String mobileNumber;

  HomePage({
    Key? key,
    required this.mobileNumber,
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

  bool _isMounted = false; // Add this line

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchTableData();

    _isMounted = true; // Add this line
    _handleBluetoothPermission();
  }

  Future<void> _handleBluetoothPermission() async {
    var bluetoothPermissionStatus = await Permission.bluetooth.request();
    var bluetoothScanPermissionStatus =
    await Permission.bluetoothScan.request();

    if (bluetoothPermissionStatus.isGranted &&
        bluetoothScanPermissionStatus.isGranted) {
      print("Bluetooth Permission Granted");
      await _checkBluetoothStatus();
    } else {
      print("Bluetooth Permission Failed");
    }
  }

  Future<void> _checkBluetoothStatus() async {
    bool isBluetoothOn =
    await BluetoothEnable.enableBluetooth.then((result) async {
      print("Bluetooth IS On Stage one");
      await _connectToBluetoothPrinter();
      return result == "true";
    });

    if (isBluetoothOn) {
      print("Bluetooth IS On");
      await _connectToBluetoothPrinter();
    } else {
      print("Bluetooth IS Off");
    }
  }

  Future<void> _connectToBluetoothPrinter() async {
    try {
      setState(() {
        _loading = true;
      });

      String printerName = "BlueTooth Printer";
      String printerAddress = "DC:0D:30:CA:34:E6";

      BluetoothDevice device = BluetoothDevice();
      device.name = printerName;
      device.address = printerAddress;

      print('Selected Bluetooth Device: ${device.name ?? 'Unknown'}');

      if (await bluetoothPrint.isConnected == true) {
        print('Already connected to ${device.name}');
        // await bluetoothPrint.connect(device);
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

  Future<void> fetchTableData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readtablename';
    final response = await http.get(Uri.parse(apiUrl));

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

  Future<void> fetchData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
    final response = await http.get(Uri.parse(apiUrl));

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

  Widget build(BuildContext context) {
    bool isTableBooked;

    return WillPopScope(
      onWillPop: () async {
        // Intercept the back button press
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => FirstPage(
              mobileNumber: widget.mobileNumber,
            ),
          ),
        );
        return false; // Do not close the current page
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: NavBar(mobileNumber: widget.mobileNumber),
        appBar: AppBar(
          centerTitle: true,
          title: Text('Order App'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
              setState(() {});
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchTableData();
            await fetchData();
            await _connectToBluetoothPrinter();
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
      
              return FutureBuilder<bool>(
                future: checkIfDataAvailable(tableData[index]['table_name']),
                builder: (context, snapshot) {
                  bool isDataAvailable = snapshot.data ?? false;
      
                  String tableName = tableData[index]['table_name'];
                  String numericPart =
                  tableName.replaceAll(RegExp(r'[^0-9]'), '');
                  int parsedTableNumber = int.tryParse(numericPart) ?? 0;
      
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
