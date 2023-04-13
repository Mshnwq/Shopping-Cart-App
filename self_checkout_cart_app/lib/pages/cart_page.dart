import 'package:badges/badges.dart';
import 'package:go_router/go_router.dart';
import '../models/item_model.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../constants/routes.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as devtools;

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static List<Item> products = [
    Item(
      barcode: '100',
      name: 'Apple',
      unit: 'Kg',
      price: 20,
      count: 1,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
    Item(
      barcode: '123',
      name: 'Organg',
      unit: 'Kg',
      price: 15,
      count: 1,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
    Item(
      barcode: '100',
      name: 'Apple',
      unit: 'Kg',
      price: 20,
      count: 2,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      floatingActionButton: InkWell(
        splashColor: Colors.blue,
        onLongPress: () {
          cart.addItem(products[cart.getCounter()]);
        },
        child: FloatingActionButton(
          //Floating action button on Scaffold
          onPressed: () => {
            cart.setCartState("weighing"),
            context.pushNamed(
              barcodeRoute,
              extra: {
                'action': 'add',
                'index': '-1',
                'barcodeToRead': 'null',
              },
            ),
          },
          backgroundColor:
              const Color.fromARGB(255, 10, 119, 14), //icon inside button
          child: const Icon(Icons.queue),
        ),
      ),
      //floating action button position to center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Column(
        children: [
          Expanded(
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                if (cart.isEmpty()) {
                  return const Center(
                      child: Text(
                    'Your Cart is Empty',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ));
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Add your refresh logic here, for example, you can fetch new data or reset the cart state
                      // Once the refresh logic is complete, you can return a Future.delayed() to simulate a delay before hiding the indicator
                      await Future.delayed(const Duration(seconds: 1));
                      devtools.log("refreshing");
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cart.getCounter(),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5.0,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Image(
                                  height: 80,
                                  width: 80,
                                  image: NetworkImage(
                                      cart.getItems()[index].image),
                                  // MemoryImage(cart.getItems()[index].image),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Name: ',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${cart.getItems()[index].name}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Count: ',
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${cart.getItems()[index].count}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                      RichText(
                                        maxLines: 1,
                                        text: TextSpan(
                                            text: 'Price: ' r"SAR",
                                            style: TextStyle(
                                                color: Colors.blueGrey.shade800,
                                                fontSize: 16.0),
                                            children: [
                                              TextSpan(
                                                  text:
                                                      '${cart.getItems()[index].price}\n',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    GoRouter.of(context).push(
                                        '/prod_detail/${cart.getItems()[index].name}');
                                  },
                                  icon: const Icon(Icons.more_vert),
                                ),
                                InkWell(
                                  onLongPress: () =>
                                      {cart.removeItem(cart.getItems()[index])},
                                  child: IconButton(
                                    onPressed: () {
                                      // cart.removeItem(cart.getItems()[index]);
                                      cart.setCartState("weighing");
                                      context.pushNamed(
                                        barcodeRoute,
                                        extra: {
                                          'action': 'remove',
                                          'index': '$index',
                                          'barcodeToRead':
                                              cart.getItems()[index].barcode,
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Column(
            children: [
              ReusableWidget(
                  title: 'Sub-Total',
                  value: r'SAR' +
                      (cart.getTotalPrice()?.toStringAsFixed(2) ?? '0')),
            ],
          ),
        ],
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title, value;
  // ignore: use_key_in_widget_constructors
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
