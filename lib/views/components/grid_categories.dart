import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/helpers/screen_size.dart';
import '../../constants/color.dart';
import '../../helpers/responsive.dart';
import '../../resources/assets_manager.dart';
import '../widgets/loading_widget.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    Key? key,
    required this.deleteDialog,
    required this.cxt,
  }) : super(key: key);

  final Function deleteDialog;
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

        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final screenWidth = constraints.maxWidth;
          const minWidth = 180;
          final crossAxisCount = (screenWidth / minWidth).floor();

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: crossAxisCount,
            //   crossAxisSpacing: 10,
            // ),
            itemBuilder: (context, index) {
              var item = snapshot.data!.docs[index];

              return Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ClipRRect(
                              child: Image.network(
                                'https://cdn.pixabay.com/photo/2015/04/19/08/32/marguerite-729510_1280.jpg', //item['img_url'],
                                width: 50,
                                height: 50,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.id,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  item['category'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
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
