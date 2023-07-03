import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_admin/constants/utils.dart';

class Category {
  String? id;
  String? category;
  String? imgUrl;
  int? createdAt;

  Category({this.id, this.category, this.imgUrl, this.createdAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    imgUrl = json['img_url'];
    createdAt = json['created_at'];
  }

  Category.fromFirebase(QueryDocumentSnapshot<Object?> json) {
    id = json.id;
    category = json['category'];
    imgUrl = json['img_url'];
    try {
      createdAt = json['created_at'];
    } catch (_) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category'] = category;
    data['img_url'] = imgUrl;
    data['created_at'] = createdAt;
    return data;
  }
}
