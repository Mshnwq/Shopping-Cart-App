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

  // static const List<Item> products = [
  //   Item(
  //       name: 'Apple',
  //       unit: 'Kg',
  //       price: 20,
  //       image:
  //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  //   Item(
  //       name: 'Mango',
  //       unit: 'Doz',
  //       price: 30,
  //       image:
  //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  //   Item(
  //       name: 'Banana',
  //       unit: 'Doz',
  //       price: 10,
  //       image:
  //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  //   Item(
  //       barcode: '123',
  //       name: 'Organg',
  //       unit: 'Kg',
  //       price: 15,
  //       image:
  //           'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
  // ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      floatingActionButton: InkWell(
        splashColor: Colors.blue,
        onLongPress: () {
          // cart.addItem(products[cart.getCounter()]);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floating action button position to center
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
                  return ListView.builder(
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
                                image:
                                    NetworkImage(cart.getItems()[index].image),
                                // MemoryImage(cart.getItems()[index].image),
                              ),
                              SizedBox(
                                width: 130,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: 'Unit: ',
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade800,
                                              fontSize: 16.0),
                                          children: [
                                            TextSpan(
                                                text:
                                                    '${cart.getItems()[index].unit}\n',
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
                              IconButton(
                                onPressed: () {
                                  // cart.removeItem(cart.getItems()[index]);
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
                            ],
                          ),
                        ),
                      );
                    },
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
