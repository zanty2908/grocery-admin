import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_admin/views/main/users/users.dart';
import '../../controllers/route_manager.dart';
import '../widgets/loading_widget.dart';
import 'products/products.dart';
import 'vendors/vendors.dart';
import '../../resources/assets_manager.dart';
import '../../resources/styles_manager.dart';
import '../widgets/are_you_sure_dialog.dart';
import 'carousel_banners/carousel_banners.dart';
import 'cash_outs/cash_outs.dart';
import 'categories/categories.dart';
import 'orders/orders.dart';
import '../../constants/color.dart';

import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.index = 0});

  final int index;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _pageCode = 'category';
  // bool isExtended = false;
  bool isLoading = true;

  final user = FirebaseAuth.instance.currentUser!;

  final Map<String, Widget> _pageList = const {
    'home': HomeScreen(),
    'product': ProductScreen(),
    'order': OrdersScreen(),
    'category': CategoriesScreen(),
    'vendor': VendorsScreen(),
    'carousel': CarouselBanners(),
    'cashout': CashOutScreen(),
    'user': UsersScreen(),
  };

  void setNewPage(String index) {
    setState(() {
      _pageCode = index;
    });
  }

  // for navigation rail
  // toggleIsExtended() {
  //   setState(() {
  //     isExtended = !isExtended;
  //   });
  // }

  // logout
  logout() async {
    await FirebaseAuth.instance.signOut();
    Timer(
      const Duration(seconds: 2),
      () => Navigator.of(context).pushNamedAndRemoveUntil(
        RouteManager.entryScreen,
        (route) => false,
      ),
    );
  }

  // logout dialog
  logoutDialog() {
    areYouSureDialog(
      title: 'Đăng xuất',
      content: 'Bạn đã có chắc muốn đăng xuất không?',
      context: context,
      action: logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildNavMenu(),
          Expanded(
            child: _buildBody(),
          )
        ],
      ),
    );
  }

  BoxShadow _baseShadow() => BoxShadow(
        color: Colors.grey.shade300,
        blurRadius: 3,
        offset: const Offset(0.5, 0),
        spreadRadius: 3,
      );

  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraint) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraint.maxHeight,
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 14, bottom: 14, right: 24),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [_baseShadow()],
          ),
          child: _pageList[_pageCode],
        ),
      );
    });
  }

  Widget _buildNavMenu() {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraint.maxHeight,
            maxWidth: 220,
          ),
          child: _buildLeftMenu(),
        ),
      );
    });
  }

  Widget _buildLeftMenu() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [_baseShadow()],
      ),
      child: Column(
        children: [
          // _buildItemOfLeftMenu("Dashboard", 'home', Icons.dashboard_outlined),
          _buildItemOfLeftMenu("Danh mục", 'category', Icons.category_outlined),
          _buildItemOfLeftMenu("Sản phẩm", 'product', Icons.shopping_bag_outlined),
          _buildItemOfLeftMenu("Đơn hàng", 'order', Icons.shopping_cart_checkout),
          // _buildItemOfLeftMenu("Vendors", 'vendor', Icons.group_outlined),
          // _buildItemOfLeftMenu("Carousels", 'carousel', Icons.view_carousel),
          // _buildItemOfLeftMenu("Cash outs", 'cashout', Icons.monetization_on_outlined),
          // _buildItemOfLeftMenu("Users", 'user', Icons.group),
          // _buildItemOfLeftMenu("Logout", 'logout', Icons.logout),
        ],
      ),
    );
  }

  Widget _buildItemOfLeftMenu(String title, String index, IconData icon) {
    var selected = _pageCode == index;
    var textColor = selected ? Colors.white : Colors.grey.shade600;
    var bgColor = selected ? primaryColor : Colors.transparent;
    return InkWell(
      onTap: () {
        setState(() {
          _pageCode = index;
        });
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          )),
    );
  }
}
