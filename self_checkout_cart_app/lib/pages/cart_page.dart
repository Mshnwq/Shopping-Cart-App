import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../widgets/all_widgets.dart';
import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/routes.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../services/env.dart' as env;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as devtools;

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static List<Item> products = [
    Item(
      barcode: '0100',
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
    Item(
      barcode: '100222',
      name: 'Appxle',
      unit: 'Kg',
      price: 20,
      count: 1,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
    Item(
      barcode: '1200',
      name: 'Applze',
      unit: 'Kg',
      price: 20,
      count: 2,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
    Item(
      barcode: '100q',
      name: 'Applee',
      unit: 'Kg',
      price: 20,
      count: 2,
      image:
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
    ),
    Item(
      barcode: 'w1020',
      name: 'Appwle',
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
    final auth = ref.watch(authProvider);
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
      body: RefreshIndicator(
        onRefresh: () async {
          // await Future.delayed(const Duration(milliseconds: 420));
          // http.Response httpRes = await auth.getAuthReq(
          //   '/api/v1/item/items',
          // );
          if (true) {
            // devtools.log("items ${httpRes.statusCode}");
            // if (httpRes.statusCode == 200) {
            // if (httpRes.body != null) {
            // devtools.log("items ${httpRes.body}");
            cart.clearItems();
            String receiptBodyJson = '''{
                "bill": {
                  "status": "unpaid",
                  "created_at": "2023-03-31T21:14:45.539142",
                  "num_of_items": 4,
                  "total_price": 70.0,
                  "user_id": 1
                },
                "items": [
                  {
                    "1231231": {
                      "ar_name": "\\u062a\\u0628\\u063a",
                      "en_name": "snus",
                      "count": 3,
                      "unit_price": 20.0
                    }
                  },
                  {
                    "12312ssssssssssssssssssssss38": {
                      "ar_name": "\\u062a\\u0628\\u063a",
                      "en_name": "saanus",
                      "count": 1,
                      "unit_price": 10.0
                    }
                  }
                ]
              }''';
            var items = json.decode(receiptBodyJson)['items'];
            // var items = json.decode(httpRes.body)['items'];
            // devtools.log("$items");
            for (int i = 0; i < items.length; i++) {
              // extract item info
              Map itemMap = items[i];
              String itemId = itemMap.keys.first;
              Map itemDetails = itemMap.values.first;
              // create item object
              Item item = Item(
                barcode: itemId,
                name: itemDetails['en_name'],
                unit: 'Kg',
                price: itemDetails['unit_price'],
                count: itemDetails['count'],
                // image: "http://${env.baseURL}${itemDetails['img_path']}",
                image:
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
              );
              // add to cart
              cart.addItem(item);
            }
            // }
            devtools.log("refreshing");
          } else {
            devtools.log("Refresh Failed");
          }
        },
        child: Stack(
          children: <Widget>[
            ListView(),
            Column(
              children: [
                Expanded(
                  child: Consumer(
                    builder:
                        (BuildContext context, WidgetRef ref, Widget? child) {
                      if (cart.isEmpty()) {
                        return const Center(
                          child: Text(
                            'Your Cart is Empty',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          // physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cart.getCounter(),
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5.0,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                                    color: Colors
                                                        .blueGrey.shade800,
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
                                                    color: Colors
                                                        .blueGrey.shade800,
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
                                                    color: Colors
                                                        .blueGrey.shade800,
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
                                      onLongPress: () => {
                                        cart.removeItem(cart.getItems()[index])
                                      },
                                      child: IconButton(
                                        onPressed: () {
                                          // cart.removeItem(cart.getItems()[index]);
                                          cart.setCartState("weighing");
                                          context.pushNamed(
                                            barcodeRoute,
                                            extra: {
                                              'action': 'remove',
                                              'index': '$index',
                                              'barcodeToRead': cart
                                                  .getItems()[index]
                                                  .barcode,
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
                        );
                        // ),
                        // );
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
          ],
        ),
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
