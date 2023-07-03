import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/models/category.dart';
import '../../constants/color.dart';
import '../../resources/assets_manager.dart';
import '../widgets/loading_widget.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    Key? key,
    required this.select,
    required this.cxt,
  }) : super(key: key);

  final Function select;
  final BuildContext cxt;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> categoryStream =
        FirebaseFirestore.instance.collection('categories').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: categoryStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error occurred!'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: LoadingWidget(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
                child: LoadingWidget(),
              );
          return const Center(
            child: LoadingWidget(),
          );
        }

        if (snapshot.data?.docs.isEmpty == true) {
          return Center(
            child: Image.asset(AssetManager.noImagePlaceholderImg),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No Data Available'));
        }

        var dataList =
            snapshot.data?.docs.map(Category.fromFirebase).toList() ?? [];

        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              var item = dataList[index];

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () => select(item),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      item.category ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }
}
