import 'package:badges/badges.dart';
import 'package:go_router/go_router.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
// import '../theme/themes.dart';
import 'package:provider/provider.dart';
import '../constants/routes.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'dart:developer' as devtools;
import '../providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDirectoryPage extends ConsumerWidget {
  ProductDirectoryPage({super.key});

  // DBHelper? dbHelper = DBHelper();
  // List<bool> tapped = [];
  late final TextEditingController searchText = TextEditingController();

  // @override
  // void initState() {
  // super.initState();
  // _searchText = TextEditingController();
  // context.read<CartProvider>().getData();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartListProvider);
    // final searchText = ref.watch(searchTextProvider);
    return Scaffold(
      // drawer: const MenuBar(),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(60), //height of appbar
      //   child: AppBar(
      //     centerTitle: true,
      //     backgroundColor: Colors.green,
      //     title: Text(
      //       // 'Cart State ${cart.getCounter().toString()}',
      //       'Cart State ${cart.getCounter().toString()}',
      //       // style: appTheme.setButtonTextStyle(18, 1),
      //     ),
      // actions: [
      //   Badge(
      //     badgeContent: Consumer<CartProvider>(
      //       builder: (context, value, child) {
      //         return Text(
      //           value.getCounter().toString(),
      //           // "d",
      //           style: const TextStyle(
      //               color: Colors.white, fontWeight: FontWeight.bold),
      //         );
      //       },
      //     ),
      //     position: const BadgePosition(start: 30, bottom: 30),
      //     child: Container(
      //       margin: const EdgeInsets.only(top: 5, right: 5),
      //       alignment: Alignment.topRight,
      //       child: const CartMenu(),
      //     ),
      //   ),
      // ],
      // ),
      // ),
      floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () => GoRouter.of(context).pushNamed(barcodeRoute),
        child: Icon(Icons.queue),
        // child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 10, 119, 14), //icon inside button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floating action button position to center
      body: Padding(
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        child: AnimSearchBar(
          color: Colors.green,
          searchIconColor: Colors.white,
          width: 400,
          textController: searchText,
          onSuffixTap: () {
            devtools.log("submitted ${searchText.text}\n");
            searchText.clear();
            devtools.log("submitted ${searchText.text}\n");
          },
          onSubmitted: (String value) {
            devtools.log("submitted ${searchText.text}\n");
          },
        ),
      ),
    );
  }
}

final searchTextProvider = StateNotifierProvider<searchText, String>(
  (ref) {
    return searchText();
  },
);

class searchText extends StateNotifier<String> {
  searchText() : super('');

  void changeText(String text) {
    state = text;
  }

  void clear() {
    state = '';
  }

  String text() {
    return state;
  }
}
