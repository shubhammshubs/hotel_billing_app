import 'package:flutter/material.dart';
import 'package:hotel_billing_app/Home_Screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Nav_menu.dart';


class FirstPage extends StatefulWidget {
  final String mobileNumber;
  final String RestoId;


  FirstPage({
    Key? key,
    required this.mobileNumber,
    required this.RestoId,
  }) : super(key: key);

  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  List<String> tableNames = [];
  List<dynamic> orderData = [];
  int totalTables = 0;
  int availableTables = 0;
  int occupiedTables = 0;
  String todaysCollection = '0'; // Initial text while data is being fetched
  bool _mounted = false; // Add this variable
  String restoName = ''; // Variable to store the resto_name

  @override
  void initState() {
    super.initState();
    fetchRestoName();
    _mounted = true; // Set _mounted to true when the widget is mounted
    fetchTableData();
    fetchDataAndCheckTableStatus();
    fetchTodaysCollection(); // Fetch today's collection data

  }

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
          restoName = data[0]['resto_name'];
        });
      } else {
        print('No data received from readhotel API');
      }
    } else {
      // Handle error
      print('Failed to load resto_name: ${response.statusCode}');
    }
  }



  Future<void> fetchTableData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readtablename';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // setState(() {
        tableNames = data.map((item) => item['table_name'].toString()).toList();
        totalTables = tableNames.length;
      // });
    } else {
      // Handle error
      print('Failed to load table data: ${response.statusCode}');
    }
  }

  Future<void> fetchTodaysCollection() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=todaycoll';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
      );
      // final response = await http.get(Uri.parse(apiUrl));

      if (_mounted && response.statusCode == 200) {
        final String collection = response.body;
        setState(() {
          todaysCollection = collection;
        });
      } else {
        // Handle error
        print('Failed to load today\'s collection: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception during fetchTodaysCollection: $e');
    }
  }

  Future<void> fetchDataAndCheckTableStatus() async {
    await fetchData();
    await fetchTodaysCollection();

    totalTables = tableNames.length;

    for (int i = 1; i <= totalTables; i++) {
      String tableName = tableNames[i - 1];
      bool isDataAvailable = await checkIfDataAvailable(tableName);

      if (isDataAvailable) {
        occupiedTables++;
      } else {
        availableTables++;
      }
    }

    // Update the state to trigger a rebuild with the new values
    setState(() {});
  }


  Future<void> fetchData() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=readorders';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'RestoId': widget.RestoId}, // Pass RestoId in the request body
    );
    // final response = await http.get(Uri.parse(apiUrl));

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

    List ordersForTable = orderData
        .where((order) =>
    order['order_table'] == parsedTableNumber.toString() &&
        order['order_status'] == 'In Process')
        .toList();

    bool isDataAvailable = ordersForTable.isNotEmpty;
    return isDataAvailable;
  }
  Future<void> _refreshData() async {
    await fetchDataAndCheckTableStatus();
    await fetchTodaysCollection();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(mobileNumber: widget.mobileNumber,
        RestoId: widget.RestoId,),
      appBar: AppBar(
        centerTitle: true,
        title:  Text("$restoName"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 3, // Adjust the aspect ratio as needed
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: const Text(
                                  "Today's Collection:",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5,),

                              RichText(
                                text: TextSpan(
                                  // style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    const TextSpan(
                                      text: '₹ ',
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                    TextSpan(
                                      text: todaysCollection.trim(), // Trim the string here
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.purple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: const Text(
                                  "Total Table ",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5,),

                              RichText(
                                text: TextSpan(
                                  // style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(
                                      text: "${totalTables}", // Trim the string here
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Card(
                    //   elevation: 5, // This controls the shadow depth
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //   ),
                    //   color: Colors.purple,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Center(
                    //       child: Text(
                    //         "Total Table : $totalTables ",
                    //         style: const TextStyle(fontSize: 17, color: Colors.white),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.blueAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: const Text(
                                  "Available table",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5,),
                              RichText(
                                text: TextSpan(
                                  // style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(
                                      text: "${availableTables}", // Trim the string here
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.red.shade400,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: const Text(
                                  "Occupied Table",
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              ),
                              SizedBox(height: 5,),

                              RichText(
                                text: TextSpan(
                                  // style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(
                                      text: "${occupiedTables}", // Trim the string here
                                      style: TextStyle(fontSize: 17, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Card(
                    //   elevation: 5, // This controls the shadow depth
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //   ),
                    //   color: Colors.blueAccent,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Center(
                    //       child: Text(
                    //         "Available table : $availableTables ",
                    //         style: const TextStyle(fontSize: 17, color: Colors.white),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Card(
                    //   elevation: 5, // This controls the shadow depth
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(10.0),
                    //   ),
                    //   color: Colors.red.shade400,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Center(
                    //       child: Text(
                    //         "Occupied Table : $occupiedTables ",
                    //         style: const TextStyle(fontSize: 17, color: Colors.white),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HomePage(mobileNumber: widget.mobileNumber,
                              RestoId: widget.RestoId,
                              isAdmin: false, // Set isAdmin to  false for users
                            ),
                      ),
                    );
                  },
                  color: Colors.green,
                  child: const Text(
                    "Book a Table",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

