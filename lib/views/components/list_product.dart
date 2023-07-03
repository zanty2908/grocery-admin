import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/helpers/screen_size.dart';
import '../../constants/color.dart';
import '../../constants/utils.dart';
import '../../helpers/responsive.dart';
import '../../models/product.dart';
import '../../resources/assets_manager.dart';
import '../widgets/loading_widget.dart';

class ProductList extends StatelessWidget {
  const ProductList({
    Key? key,
    required this.deleteDialog,
    required this.cxt,
  }) : super(key: key);

  final Function deleteDialog;
  final BuildContext cxt;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> productStream =
        FirebaseFirestore.instance.collection('products').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: productStream,
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

        var data = snapshot.data;

        if (!snapshot.hasData || data == null) {
          ErrorWidget.builder = (FlutterErrorDetails details) => const Center(
                child: LoadingWidget(),
              );
          return const Center(child: Text('No Data Available'));
        }

        if (data.docs.isEmpty == true) {
          return Center(
            child: Image.asset(AssetManager.empty),
          );
        }

        // Mapping model
        List<Product> productList =
            data.docs.map((e) => Product.fromFirebase(e)).toList();

        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: productList.length,
            itemBuilder: (context, index) {
              var item = productList[index];

              return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              child: Image.network(
                                'https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510_1280.jpg', //item['img_url'],
                                alignment: Alignment.centerLeft,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              item.name ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              VNCurrency.format(item.price ?? '0'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () => deleteDialog(id: item.id),
                                child: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.redAccent,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: boxBg, thickness: 1.5),
                    ],
                  ));
            },
          );
        });
      },
    );
  }
}
