import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Product.dart';



class ProductListWidget extends StatefulWidget {
  final String RestoId;
  final String mobileNumber;

  ProductListWidget({required this.RestoId, required this.mobileNumber});
  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  List<Product> productList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('https://trifrnd.in/api/inv.php?apicall=readproducts'),
      body: {'RestoId': widget.RestoId}, // Replace 'YOUR_RESTO_ID' with the actual RestoId
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

  Future<void> updatePrice(String restoId, String categoryName, String productName, String productPrice) async {
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
      print('Product price updated successfully');
      // You can optionally update the UI or display a message here
    } else {
      print('Failed to update product price');
      // Handle the error or display a message accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: productList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];
          return ListTile(
            title: Text(product.productName),
            subtitle: Text('Price: ${product.productPrice}'),
            trailing: ElevatedButton(
              onPressed: () {
                // Replace 'NEW_PRICE' with the actual updated price
                updatePrice(product.restoId, 'CATEGORY_NAME', product.productName, '1000');
              },
              child: Text('Update'),
            ),
          );
        },
      ),
    );
  }
}
