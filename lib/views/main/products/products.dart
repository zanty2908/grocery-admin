import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:grocery_admin/constants/color.dart';
import 'package:grocery_admin/helpers/screen_size.dart';
import 'package:grocery_admin/models/category.dart';
import 'package:grocery_admin/models/product.dart';
import 'package:grocery_admin/views/components/list_category.dart';
import 'package:grocery_admin/views/components/list_product.dart';

import '../../../resources/assets_manager.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/loading_widget.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sản phẩm",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Expanded(
                flex: 8,
                child: SizedBox(
                  height:
                      context.screenSize ? size.height / 2.5 : size.height / 2,
                  child: ProductList(
                    deleteDialog: deleteDialog,
                    cxt: context,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildInputProduct(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final pName = TextEditingController();
  final pPrice = TextEditingController();
  final pQuantity = TextEditingController();
  var validateMessage = "";
  Widget _buildInputProduct(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: isImgSelected
                    ? Image.memory(
                        fileBytes!,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        AssetManager.placeholderImg,
                      ),
              ),
              Positioned(
                bottom: 5,
                right: 5,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () => selectImage(),
                    child: CircleAvatar(
                      backgroundColor: gridBg,
                      child: const Icon(
                        Icons.photo,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pName,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tên sản phẩm',
              hintText: 'Tên sản phẩm',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pPrice,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Giá',
              hintText: 'Giá',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pQuantity,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Số lượng',
              hintText: 'Số lượng',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
            ),
            onPressed: () => _showCategoryDialog(context),
            icon: const Icon(Icons.category, color: Colors.white),
            label: Text(cateSelected != null
                ? cateSelected?.category ?? ''
                : "Chọn danh mục"),
          ),
          const SizedBox(height: 16),
          validateMessage.isNotEmpty ? Text(validateMessage) : const SizedBox(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: _addProduct,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Thêm"),
          ),
        ],
      ),
    );
  }

  String? fileName;
  Uint8List? fileBytes;
  bool isImgSelected = false;
  Category? cateSelected;

  void _addProduct() async {
    var name = pName.text.trim();
    var price = pPrice.text.trim();
    var quantity = pQuantity.text.trim();

    var priceValue = int.tryParse(price);
    if (priceValue == null) {
      setState(() {
        validateMessage = "Giá sản phẩm sai!";
      });
      return;
    }

    var quantityValue = int.tryParse(quantity);
    if (quantityValue == null) {
      setState(() {
        validateMessage = "Số lượng sản phẩm sai!";
      });
      return;
    }

    if (name.isEmpty) {
      setState(() {
        validateMessage = "Tên sản phẩm trống!";
      });
      return;
    }

    EasyLoading.show(status: 'loading...');

    String? downloadLink;
    try {
      final Reference ref = _firebaseStorage.ref('pruducts/$fileName');
      await ref.putData(fileBytes!).whenComplete(() async {
        downloadLink = await ref.getDownloadURL();
      });

      var req = Product(
        name: name,
        price: priceValue,
        quantity: quantityValue,
        image: downloadLink,
        category: cateSelected?.id ?? '',
        categoryName: cateSelected?.category ?? '',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _firebase
          .collection('products')
          .doc()
          .set(req.toJson())
          .whenComplete(() {
        EasyLoading.dismiss();

        _uploadDone();

        kCoolAlert(
            message: 'Category deleted successfully',
            context: context,
            alert: CoolAlertType.success,
            action: () {
              setState(() {});
            });
      });
    } catch (e) {
      kCoolAlert(
        message: 'Category not deleted successfully',
        context: context,
        alert: CoolAlertType.error,
      );
    }
  }

  void _uploadDone() {
    setState(() {
      isImgSelected = false;
      pName.clear();
      pPrice.clear();
      pQuantity.clear();
    });
  }

  // pick image
  Future selectImage() async {
    FilePickerResult? pickedImage = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        isImgSelected = true;
      });
    }

    setState(() {
      fileBytes = pickedImage.files.first.bytes;
      fileName = pickedImage.files.first.name;
    });
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Danh mục sản phẩm'),
        content: SizedBox(
          height: 300.0, // Change as per your requirement
          width: 300.0, // Change as per your requirement
          child: CategoryList(
            select: (Category item) {
              setState(() {
                cateSelected = item;
              });
              Navigator.pop(context, 'OK');
            },
            cxt: context,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void deleteDialog({required String id}) {
    areYouSureDialog(
      title: 'Xóa',
      content: 'Bạn có muốn xóa sản phẩm này?',
      context: context,
      action: deleteProduct,
      isIdInvolved: true,
      id: id,
    );
  }

  Future<void> deleteProduct(String id) async {
    // Navigator.of(context).pop();
    EasyLoading.show(status: 'loading...');

    try {
      await _firebase.collection('products').doc(id).delete().whenComplete(() {
        EasyLoading.dismiss();
        kCoolAlert(
          message: 'Xóa thành công',
          context: context,
          alert: CoolAlertType.success,
        );
      });
    } catch (e) {
      kCoolAlert(
        message: 'Xóa thất bại',
        context: context,
        alert: CoolAlertType.error,
      );
    }
  }
}
