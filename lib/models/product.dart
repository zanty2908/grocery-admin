import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_admin/constants/utils.dart';

class Product {
  String? id;
  String? name;
  int? price;
  int? quantity;
  String? image;
  String? category;
  String? categoryName;
  int? createdAt;

  Product(
      {this.id,
      this.name,
      this.price,
      this.quantity,
      this.image,
      this.category,
      this.categoryName,
      this.createdAt});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    image = json['image'];
    category = json['category'];
    categoryName = json['category_name'];
    createdAt = json['created_at'];
  }

  Product.fromFirebase(QueryDocumentSnapshot<Object?> json) {
    id = json.id;
    name = json['name'];
    price = json['price'];
    quantity = json['quantity'];
    image = json['image'];
    try {
      category = json['category'];
    } catch (_) {}
    try {
      categoryName = json['category_name'];
    } catch (_) {}
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['image'] = image;
    data['category'] = category;
    data['category_name'] = categoryName;
    data['created_at'] = createdAt;
    return data;
  }
}
