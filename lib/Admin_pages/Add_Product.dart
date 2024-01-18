import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '1st_page_admin.dart';
import 'Product.dart';

class AddProductPage extends StatefulWidget {
  final String RestoId;
  final String mobileNumber;

  AddProductPage({required this.RestoId, required this.mobileNumber});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();

  List<Map<String, String>> products = [];
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    // Fetch products when the page is loaded
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.post(
      Uri.parse('https://trifrnd.in/api/inv.php?apicall=readproducts'),
      body: {
        'RestoId': widget.RestoId,
      }, // Replace 'YOUR_RESTO_ID' with the actual RestoId
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        productList = data.map((item) => Product.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> addProduct() async {
    final apiUrl = 'https://trifrnd.in/api/inv.php?apicall=addprod';

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'RestoId': widget.RestoId,
        'category_name': categoryController.text,
        'product_name': productNameController.text,
        'product_price': productPriceController.text,
      },
    );

    if (response.statusCode == 200) {
      // Product added successfully, reload the products
      fetchProducts();

      // setState(() {
      //   categoryController.text = '';
      //   productNameController.text = '';
      //   productPriceController.text = '';
      // });

      Fluttertoast.showToast(
        msg: 'Product added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      // Failed to add product
      print('Failed to add product: ${response.statusCode}');
      Fluttertoast.showToast(
        msg: 'Failed to add product',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Function to show the add product dialog
  Future<void> _showAddProductDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category Name'),
                ),
                TextField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: productPriceController,
                  decoration: InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                addProduct();
                Navigator.of(context).pop();
              },
              child: Text('Add Product'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updatePrice(String restoId, String categoryName,
      String productName, String productPrice) async {
    final response = await http.post(
      Uri.parse('https://trifrnd.in/api/inv.php?apicall=updateprice'),
      body: {
        'RestoId': widget.RestoId,
        'category_name': categoryName,
        'product_name': productName,
        'product_price': productPrice,
      },
    );

    if (response.statusCode == 200) {
      fetchProducts();

      print('Product price updated successfully');
      // You can optionally update the UI or display a message here
    } else {
      print('Failed to update product price');
      // Handle the error or display a message accordingly
    }
  }

  Future<void> _showUpdateProductDialog(
      BuildContext context, Product product) async {
    // Pre-fill the values for the selected product
    categoryController.text = "Food";
    productNameController.text = product.productName;
    productPriceController.text = product.productPrice;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // TextField(
                //   controller: categoryController,
                //   readOnly: true,
                //   decoration: InputDecoration(labelText: 'Category Name'),
                // ),
                TextField(
                  controller: productNameController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: productPriceController,
                  decoration: InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the updatePrice function with the entered data
                updatePrice(
                  widget.RestoId,
                  // Assuming RestoId is a property of the widget
                  categoryController.text,
                  productNameController.text,
                  productPriceController.text,
                );

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _removeProduct(Product product) async {
    final response = await http.post(
      Uri.parse('https://trifrnd.in/api/inv.php?apicall=removeprod'),
      body: {
        'RestoId': product.restoId,
        // 'category_name': 'CATEGORY_NAME', // Replace with actual category name
        'product_name': product.productName,
      },
    );

    if (response.statusCode == 200) {
      print('Product removed successfully');
      // You can optionally update the UI or display a message here
      _refreshProducts(); // Refresh the product list after removal
    } else {
      print('Failed to remove product');
      // Handle the error or display a message accordingly
    }
  }

  Future<void> _refreshProducts() async {
    // Implement the logic to refresh the products
    await fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    print('Number of products: ${productList.length}'); // Debug print

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Product "),
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
          onRefresh: _refreshProducts,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      _showAddProductDialog(context);
                    },
                    child: Center(child: Text('Add Product')),
                  ),
                  SizedBox(height: 30),
                  Table(
                    defaultColumnWidth:IntrinsicColumnWidth(),
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                              child: Center(child: Text(' Item Name ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                          TableCell(
                              child: Center(child: Text(' Item Price ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                          TableCell(
                              child: Center(child: Text(' Update \n Item ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))),
                          TableCell(
                            child: Center(child: Text(' Remove \n  Item ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ),
                        ],
                      ),
                      for (int i = 0; i < productList.length; i++)
                        TableRow(
                          children: [
                            TableCell(
                                child: Center(
                                    child: Text(productList[i].productName,
                                      // style: TextStyle(fontSize: 13),
                                    ))),
                            TableCell(
                                child: Center(
                                    child: Text(
                              productList[i].productPrice,
                              // style: TextStyle(fontSize: 13),
                            ))),
                            TableCell(
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle update button click
                                    _showUpdateProductDialog(
                                        context, productList[i]);
                                  },
                                  child: Text('Update'),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.remove_circle,color: Colors.redAccent,),
                                  onPressed: () {
                                    // Add your logic to remove the product here
                                    _removeProduct(productList[i]);
                                  },
                                ),
                              ),
                            ),

                          ],
                        ),
                    ],
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
