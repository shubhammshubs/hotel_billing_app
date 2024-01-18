class Product {
  final String restoId;
  final String productName;
  final String productPrice;

  Product({required this.restoId, required this.productName, required this.productPrice});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      restoId: json['RestoId'],
      productName: json['product_name'],
      productPrice: json['product_price'],
    );
  }
}
