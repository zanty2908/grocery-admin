import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/helpers/screen_size.dart';
import 'package:grocery_admin/views/widgets/loading_widget.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/status.dart';
import '../../../helpers/responsive.dart';
import '../../../resources/assets_manager.dart';
import '../../../resources/font_manager.dart';
import '../../../resources/styles_manager.dart';
import 'package:file_picker/file_picker.dart';
import '../../components/grid_categories.dart';
import '../../widgets/are_you_sure_dialog.dart';
import '../../widgets/kcool_alert.dart';
import '../../widgets/msg_snackbar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  bool isImgSelected = false;
  Uint8List? fileBytes;
  String? fileName;
  bool isProcessing = false;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  TextEditingController categoryName = TextEditingController();
  TextEditingController categoryCode = TextEditingController();

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

  // reset picked image
  void resetIsImagePicked() {
    setState(() {
      isImgSelected = false;
    });
  }

  // action after uploading category
  uploadDone() {
    // Navigator.of(context).pop();
    setState(() {
      isProcessing = false;
      isImgSelected = false;
      categoryName.clear();
      categoryCode.clear();
    });
  }

  // upload Category
  Future<void> uploadCategory() async {
    //if category name is empty
    if (categoryName.text.isEmpty || categoryName.text.length < 3) {
      displaySnackBar(
        status: Status.error,
        message: categoryName.text.isEmpty
            ? 'Tên danh mục không thể để trống'
            : 'Tên danh mục không đúng',
        context: context,
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });
    String? downloadLink;
    var code = categoryCode.text.trim();
    try {
      final Reference ref = _firebaseStorage.ref('categories/$fileName');
      await ref.putData(fileBytes!).whenComplete(() async {
        downloadLink = await ref.getDownloadURL();
      });
      await _firebase.collection('categories').doc(code).set(
        {
          'img_url': downloadLink,
          'category': categoryName.text.trim(),
        },
      ).whenComplete(() {
        kCoolAlert(
          message: 'Thêm danh mục thành công',
          context: context,
          alert: CoolAlertType.success,
          action: uploadDone,
        );
        categoryName.clear();
        categoryCode.clear();
      });
    } catch (e) {
      kCoolAlert(
        message: 'Thêm danh mục thất bại',
        context: context,
        alert: CoolAlertType.error,
        action: uploadDone,
      );
    }
  }

  // action after deleting
  void doneDeleting() {
    // Navigator.of(context).pop();
  }

  // delete category
  Future<void> deleteCategory(String id) async {
    // Navigator.of(context).pop();
    EasyLoading.show(status: 'loading...');

    try {
      await _firebase
          .collection('categories')
          .doc(id)
          .delete()
          .whenComplete(() {
        EasyLoading.dismiss();
        kCoolAlert(
          message: 'Category deleted successfully',
          context: context,
          alert: CoolAlertType.success,
          action: doneDeleting,
        );
      });
    } catch (e) {
      kCoolAlert(
        message: 'Category not deleted successfully',
        context: context,
        alert: CoolAlertType.error,
        action: doneDeleting,
      );
    }
  }

  // delete dialog
  void deleteDialog({required String id}) {
    areYouSureDialog(
      title: 'Delete Category',
      content: 'Are you sure you want to delete this category?',
      context: context,
      action: deleteCategory,
      isIdInvolved: true,
      id: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: isImgSelected
                          ? Image.memory(
                              fileBytes!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              AssetManager.placeholderImg,
                              width: 100,
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
                            child: !isProcessing
                                ? const Icon(
                                    Icons.photo,
                                    color: accentColor,
                                  )
                                : const LoadingWidget(size: 30),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: TextField(
                    controller: categoryCode,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Code',
                      hintText: 'Code',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 5,
                  child: TextField(
                    controller: categoryName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tên danh mục',
                      hintText: 'Tên danh mục',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                isImgSelected
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                        ),
                        onPressed: () =>
                            !isProcessing ? uploadCategory() : null,
                        icon: const Icon(Icons.save),
                        label: Text(
                          !isProcessing ? 'Upload category' : 'Uploading...',
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: boxBg, thickness: 1.5),
            const SizedBox(height: 5),
            Text(
              'Danh mục sản phẩm',
              style: getMediumStyle(
                color: Colors.black,
                fontSize: FontSize.s18,
              ),
            ),
            SizedBox(
              height: context.screenSize ? size.height / 2.5 : size.height / 2,
              child: CategoryGrid(
                deleteDialog: deleteDialog,
                cxt: context,
              ),
            )
          ],
        ),
      ),
    );
  }
}
