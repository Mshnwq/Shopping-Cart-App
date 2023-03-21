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

  late final TextEditingController searchText = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final cart = ref.watch(cartProvider);
    // final searchText = ref.watch(searchTextProvider);
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   //Floating action button on Scaffold
      //   onPressed: () => GoRouter.of(context).pushNamed(barcodeRoute),
      //   // child: Icon(Icons.add),
      //   backgroundColor: const Color.fromARGB(255, 10, 119, 14),
      //   child: const Icon(Icons.queue), //icon inside button
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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

// ignore: camel_case_types
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
