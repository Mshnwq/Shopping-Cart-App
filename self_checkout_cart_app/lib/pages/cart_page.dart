import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:self_checkout_cart_app/providers/mqtt_provider.dart';
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
    final mqtt = ref.watch(mqttProvider);
    final penet_completer = Completer<String>();
    final item_completer = Completer<String>();
    return Scaffold(
      floatingActionButton: InkWell(
        splashColor: Colors.lightGreen,
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          hoverColor:
              Theme.of(context).colorScheme.secondary, //icon inside button
          child: Icon(
            Icons.queue,
            color: Theme.of(context).colorScheme.background,
          ),
        ),
      ),
      //floating action button position to center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 420));
          http.Response httpRes = await auth.getAuthReq(
            '/api/v1/item/items',
          );
          // if (true) {
          devtools.log("items ${httpRes.statusCode}");
          if (httpRes.statusCode == 200) {
            if (httpRes.body != null) {
              devtools.log("items ${httpRes.body}");
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
              // var items = json.decode(receiptBodyJson)['items'];
              var items = json.decode(httpRes.body)['items'];
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
            }
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
                              borderOnForeground: true,
                              color: Color.fromARGB(255, 255, 255, 255),
                              shadowColor: Color.fromARGB(255, 255, 255, 255),
                              surfaceTintColor:
                                  Color.fromARGB(255, 255, 255, 255),
                              // surfaceTintColor: Color(0xFF2ECC71),
                              // elevation: 1.0,
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
                                          maxLines: 2,
                                          text: TextSpan(
                                            text: 'Name: ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${cart.getItems()[index].name}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Count: ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${cart.getItems()[index].count}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          maxLines: 1,
                                          text: TextSpan(
                                            text: 'Price: ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${cart.getItems()[index].price}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                              ),
                                              WidgetSpan(
                                                child: Transform.translate(
                                                  offset: const Offset(1.0,
                                                      -4.0), // Adjust the vertical position as needed
                                                  child: Text(
                                                    'SAR',
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      GoRouter.of(context).push(
                                          '/prod_detail/${cart.getItems()[index].name}');
                                    },
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  InkWell(
                                    onLongPress: () => {
                                      cart.removeItem(cart.getItems()[index])
                                    },
                                    child: IconButton(
                                      onPressed: () async {
                                        // cart.setCartState("weighing");
                                        // context.pushNamed(
                                        //   barcodeRoute,
                                        //   extra: {
                                        //     'action': 'remove',
                                        //     'index': '$index',
                                        //     'barcodeToRead':
                                        //         cart.getItems()[index].barcode,
                                        //   },
                                        // );
                                        final removeItem =
                                            await showCustomBoolDialog(
                                          context,
                                          "Item removement",
                                          "Are you sure, you want to remove ${cart.getItems()[index].name}",
                                          "Yes",
                                        );
                                        if (removeItem) {
                                          var publishBody = <String, dynamic>{
                                            'mqtt_type':
                                                'request_start_remove_item',
                                            'sender': mqtt.clientId,
                                            'barcode':
                                                cart.getItems()[index].barcode,
                                            'timestamp': DateTime.now()
                                                .millisecondsSinceEpoch
                                          };
                                          // Publish the request
                                          mqtt.publish(
                                              json.encode(publishBody));
                                          // Wait for the scale response message
                                          showCustomLoadingDialog(
                                            context,
                                            'Move item to scale area!',
                                            'Please keep only one hand in the cart',
                                          );
                                          StreamSubscription penetSubscription =
                                              mqtt.onPenetMessage
                                                  .listen((message) {
                                            penet_completer.complete(message);
                                            devtools.log("penet waiting done");
                                          });
                                          // Wait for the penet completer to complete
                                          final mqttResponsePenet = json.decode(
                                              await penet_completer.future);
                                          // Handle the message as desired
                                          penetSubscription.cancel();
                                          context.pop();
                                          devtools.log("penet completed done");
                                          // devtools.log("RESPONSE: $mqttResponse");
                                          if (mqttResponsePenet['status']
                                                  .toString() ==
                                              '0') {
                                            // Delay
                                            showCustomLoadingDialog(
                                              context,
                                              'Place item on scale!',
                                              'Please keep only one hand in the cart',
                                              durationInSeconds: 5,
                                            );
                                            var timestamp;
                                            Future.delayed(
                                              Duration(seconds: 5),
                                            ).then(
                                              (_) {
                                                timestamp = DateTime.now()
                                                    .millisecondsSinceEpoch;
                                                var publishBody =
                                                    <String, dynamic>{
                                                  'mqtt_type':
                                                      'request_remove_item',
                                                  'sender': mqtt.clientId,
                                                  'barcode': cart
                                                      .getItems()[index]
                                                      .barcode,
                                                  'timestamp': timestamp
                                                };
                                                // Publish the request
                                                mqtt.publish(
                                                    json.encode(publishBody));
                                                context.pop();
                                                showLoadingDialog(context);
                                              },
                                            );
                                            // Wait for the item completer to complete
                                            StreamSubscription subscription =
                                                mqtt.onItemMessage
                                                    .listen((message) {
                                              item_completer.complete(message);
                                              devtools.log("item waiting done");
                                            });
                                            final mqttResponseItem =
                                                json.decode(await item_completer
                                                    .future);
                                            // Handle the message as desired
                                            subscription.cancel();
                                            context.pop();
                                            devtools.log("item completed done");
                                            // on item success
                                            if (mqttResponseItem['status'] ==
                                                'success') {
                                              // devtools.log("HERE_11");
                                              Completer<void> completer1 =
                                                  Completer<void>();
                                              showCustomLoadingDialog(
                                                context,
                                                'Remove item from scale!',
                                                'Please keep only one hand in the cart',
                                                durationInSeconds: 5,
                                              );
                                              Future.delayed(
                                                Duration(seconds: 5),
                                              ).then(
                                                (_) {
                                                  cart.setCartState("active");
                                                  context.pop();
                                                  completer1.complete();
                                                  showLoadingDialog(context);
                                                },
                                              );
                                              Future.wait([completer1.future])
                                                  .then((_) {
                                                Completer<void> completer2 =
                                                    Completer<void>();
                                                Future.delayed(
                                                  Duration(seconds: 3),
                                                ).then(
                                                  (_) async {
                                                    try {
                                                      http.Response httpRes =
                                                          await auth
                                                              .postAuthReq(
                                                        '/api/v1/item/remove',
                                                        body: <String, String>{
                                                          'barcode': cart
                                                              .getItems()[index]
                                                              .barcode,
                                                          'process_id':
                                                              timestamp
                                                                  .toString(),
                                                        },
                                                      );
                                                      devtools.log(
                                                          "code: ${httpRes.statusCode}");
                                                      // if success, add remove item from cart
                                                      if (httpRes.statusCode ==
                                                          200) {
                                                        cart.removeItem(cart
                                                            .getItems()[index]);
                                                      }
                                                    } catch (e) {
                                                      devtools.log(
                                                          "${e.toString()}");
                                                    }
                                                    completer2.complete();
                                                  },
                                                );
                                                Future.wait([completer2.future])
                                                    .then((_) {
                                                  context.pop();
                                                });
                                              });
                                            }
                                          }
                                        }
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                  ),
                                ],
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        ],
      ),
    );
  }
}
