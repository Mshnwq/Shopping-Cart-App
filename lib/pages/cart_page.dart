import 'package:badges/badges.dart';
import 'package:go_router/go_router.dart';
// import 'package:anim_search_bar/anim_search_bar.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/db_helper.dart';
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
// import '../theme/themes.dart';
import '../constants/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as devtools;

class CartPage extends ConsumerWidget {
  CartPage({super.key});

//   @override
//   State<CartPage> createState() => _CartPageState();
// }

// class _CartPageState extends State<CartPage> {
  DBHelper? dbHelper = DBHelper();
  List<bool> tapped = [];
  final ValueNotifier<int?> totalPrice = ValueNotifier(null);
  // late final TextEditingController _searchText;

  // @override
  // void initState() {
  // super.initState();
  // _searchText = TextEditingController();
  // context.read<CartProvider>().getData();
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.read(cartListProvider.notifier).getData();
    // AppTheme appTheme = Provider.of<ThemeProvider>(context).getAppTheme();
    // final cart = Provider.of<CartProvider>(context);
    final cart = ref.watch(cartListProvider);
    return Scaffold(
      // drawer: MenuBar(),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(60), //height of appbar
      //   child: AppBar(
      //     centerTitle: true,
      //     // backgroundColor: appTheme.green,
      //     title: Text(
      //       'Cart State cart.State',
      //       // style: appTheme.setButtonTextStyle(18, 1),
      //     ),
      //     actions: [
      //       Badge(
      //         // badgeContent: Consumer<CartProvider>(
      //         // builder: (context, value, child) {
      //         badgeContent: Text(
      //           cart.getCounter().toString(),
      //           // "d",
      //           style: const TextStyle(
      //               color: Colors.white, fontWeight: FontWeight.bold),
      //         ),
      //         // },
      //         // ),
      //         position: const BadgePosition(start: 30, bottom: 30),
      //         child: Container(
      //           margin: const EdgeInsets.only(top: 5, right: 5),
      //           alignment: Alignment.topRight,
      //           child: const CartMenu(),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        //Floating action button on Scaffold
        onPressed: () => GoRouter.of(context).pushNamed(barcodeRoute),
        backgroundColor: Color.fromARGB(255, 10, 119, 14), //icon inside button
        child: Icon(Icons.queue),
        // child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floating action button position to center
      body: Column(
        children: [
          // Expanded(
          //   child: Consumer<CartProvider>(
          //     builder: (BuildContext context, provider, widget) {
          //       // if (provider.cart.isEmpty) {
          //       if (cart.getCounter() == 0) {
          //         return const Center(
          //             child: Text(
          //           'Your Cart is Empty',
          //           style:
          //               TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          //         ));
          //       } else {
          //         return ListView.builder(
          //             shrinkWrap: true,
          //             itemCount: provider.cart.length,
          //             itemBuilder: (context, index) {
          //               return Card(
          //                 color: Colors.blueGrey.shade200,
          //                 elevation: 5.0,
          //                 child: Padding(
          //                   padding: const EdgeInsets.all(4.0),
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //                     mainAxisSize: MainAxisSize.max,
          //                     children: [
          //                       // Image(
          //                       //   height: 80,
          //                       //   width: 80,
          //                       //   image:
          //                       //       AssetImage(provider.cart[index].image!),
          //                       // ),
          //                       SizedBox(
          //                         width: 130,
          //                         child: Column(
          //                           crossAxisAlignment:
          //                               CrossAxisAlignment.start,
          //                           children: [
          //                             const SizedBox(
          //                               height: 5.0,
          //                             ),
          //                             RichText(
          //                               overflow: TextOverflow.ellipsis,
          //                               maxLines: 1,
          //                               text: TextSpan(
          //                                   text: 'Name: ',
          //                                   style: TextStyle(
          //                                       color: Colors.blueGrey.shade800,
          //                                       fontSize: 16.0),
          //                                   children: [
          //                                     TextSpan(
          //                                         text:
          //                                             '${provider.cart[index].productName!}\n',
          //                                         style: const TextStyle(
          //                                             fontWeight:
          //                                                 FontWeight.bold)),
          //                                   ]),
          //                             ),
          //                             RichText(
          //                               maxLines: 1,
          //                               text: TextSpan(
          //                                   text: 'Unit: ',
          //                                   style: TextStyle(
          //                                       color: Colors.blueGrey.shade800,
          //                                       fontSize: 16.0),
          //                                   children: [
          //                                     TextSpan(
          //                                         text:
          //                                             '${provider.cart[index].unitTag!}\n',
          //                                         style: const TextStyle(
          //                                             fontWeight:
          //                                                 FontWeight.bold)),
          //                                   ]),
          //                             ),
          //                             RichText(
          //                               maxLines: 1,
          //                               text: TextSpan(
          //                                   text: 'Price: ' r"$",
          //                                   style: TextStyle(
          //                                       color: Colors.blueGrey.shade800,
          //                                       fontSize: 16.0),
          //                                   children: [
          //                                     TextSpan(
          //                                         text:
          //                                             '${provider.cart[index].productPrice!}\n',
          //                                         style: const TextStyle(
          //                                             fontWeight:
          //                                                 FontWeight.bold)),
          //                                   ]),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                       ValueListenableBuilder<int>(
          //                           valueListenable:
          //                               provider.cart[index].quantity!,
          //                           builder: (context, val, child) {
          //                             return PlusMinusButtons(
          //                               addQuantity: () {
          //                                 cart.addQuantity(
          //                                     provider.cart[index].id!);
          //                                 dbHelper!
          //                                     .updateQuantity(Cart(
          //                                         id: index,
          //                                         productId: index.toString(),
          //                                         productName: provider
          //                                             .cart[index].productName,
          //                                         initialPrice: provider
          //                                             .cart[index].initialPrice,
          //                                         productPrice: provider
          //                                             .cart[index].productPrice,
          //                                         quantity: ValueNotifier(
          //                                             provider.cart[index]
          //                                                 .quantity!.value),
          //                                         unitTag: provider
          //                                             .cart[index].unitTag,
          //                                         image: provider
          //                                             .cart[index].image))
          //                                     .then((value) {
          //                                   setState(() {
          //                                     cart.addTotalPrice(double.parse(
          //                                         provider
          //                                             .cart[index].productPrice
          //                                             .toString()));
          //                                   });
          //                                 });
          //                               },
          //                               deleteQuantity: () {
          //                                 cart.deleteQuantity(
          //                                     provider.cart[index].id!);
          //                                 cart.removeTotalPrice(double.parse(
          //                                     provider.cart[index].productPrice
          //                                         .toString()));
          //                               },
          //                               text: val.toString(),
          //                             );
          //                           }),
          //                       IconButton(
          //                           onPressed: () {
          //                             dbHelper!.deleteCartItem(
          //                                 provider.cart[index].id!);
          //                             provider
          //                                 .removeItem(provider.cart[index].id!);
          //                             provider.removeCounter();
          //                           },
          //                           icon: Icon(
          //                             Icons.delete,
          //                             color: Colors.red.shade800,
          //                           )),
          //                     ],
          //                   ),
          //                 ),
          //               );
          //             });
          //       }
          //     },
          //   ),
          // ),
          // Consumer<CartProvider>(
          // builder: (BuildContext context, value, Widget? child) {
          //   final ValueNotifier<int?> totalPrice = ValueNotifier(null);
          //   for (var element in value.cart) {
          //     totalPrice.value =
          //         (element.productPrice! * element.quantity!.value) +
          //             (totalPrice.value ?? 0);
          //   }
          // return Column(
          Column(
            // final ValueNotifier<int?> totalPrice = ValueNotifier(null);
            children: [
              ValueListenableBuilder<int?>(
                  valueListenable: totalPrice,
                  builder: (context, val, child) {
                    return ReusableWidget(
                        title: 'Sub-Total',
                        value: r'$' + (val?.toStringAsFixed(2) ?? '0'));
                  }),
            ],
          ),
          // },
          // )
        ],
      ),
      // bottomNavigationBar: BottomNavBar(),
    );
  }
}

class PlusMinusButtons extends StatelessWidget {
  final VoidCallback deleteQuantity;
  final VoidCallback addQuantity;
  final String text;
  const PlusMinusButtons(
      {Key? key,
      required this.addQuantity,
      required this.deleteQuantity,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: deleteQuantity, icon: const Icon(Icons.remove)),
        Text(text),
        IconButton(onPressed: addQuantity, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  const ReusableWidget({Key? key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ],
      ),
    );
  }
}
