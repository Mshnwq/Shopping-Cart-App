import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';
import 'dart:developer' as devtools;

final cartProvider = ChangeNotifierProvider.autoDispose((ref) => Cart());

enum CartState {
  locked,
  initial,
  active,
  weighing,
  alarm,
  error,
  checkout,
  paid,
}

extension CartStateExtension on CartState {
  String get stateString {
    switch (this) {
      case CartState.initial:
        // return 'Initial';
        return '-1';
      case CartState.locked:
        // return 'Locked';
        return '0';
      case CartState.active:
        // return 'Active';
        return '1';
      case CartState.weighing:
        // return 'Weighing';
        return '2';
      case CartState.alarm:
        // return 'Alarm';
        return 'Alarm';
      case CartState.paid:
        // return 'Paid';
        return 'Paid';
      case CartState.checkout:
        // return 'Checkout';
        return '3';
      case CartState.error:
        // return 'Error';
        return 'Error';
      default:
        // return 'Unknown';
        return 'Unknown';
    }
  }
}

class Cart with ChangeNotifier {
  final List<Item> _items = [];
  List<Item> get items => _items;

  int _counter = 0;
  int get counter => _counter;

  double _totalPrice = 0.0;
  double get totalPrice => _totalPrice;

  CartState _state = CartState.initial;
  CartState get state => _state;

  String _id = 'doe';
  String get id => _id;
  void setID(String id) => _id = id;

  void addItem(Item item) {
    // Check if an item with the same count is already in the list
    bool itemExists = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].barcode == item.barcode) {
        // Item with the same barcode already exists
        itemExists = true;
        // Increase the count of the existing item
        _items[i].count += item.count;
        break;
      }
    }
    if (!itemExists) {
      // Item with the same count does not exist, add a new item
      _items.add(item);
      _counter++;
    }
    _totalPrice += item.price * item.count;
    notifyListeners();
  }

  void removeItem(Item item) {
    if (item.count > 1) {
      // item has duplicates
      item.count--;
    } else {
      _items.remove(
          _items.firstWhere((element) => element.barcode == item.barcode));
      _counter--;
    }
    _totalPrice -= item.price;
    notifyListeners();
  }

  List<Item> getItems() {
    return _items;
  }

  void clearItems() {
    _items.clear();
    _counter = 0;
    _totalPrice = 0.0;
  }

  int getCounter() {
    return _counter;
  }

  double? getTotalPrice() {
    return _totalPrice;
  }

  bool isOnline() {
    return true; // TODO
  }

  String getCartState() {
    return _state.stateString;
  }

  void setCartState(String state) {
    switch (state) {
      case 'locked':
        _state = CartState.locked;
        notifyListeners();
        break;
      case 'initial':
        _state = CartState.initial;
        notifyListeners();
        break;
      case 'active':
        _state = CartState.active;
        notifyListeners();
        break;
      case 'weighing':
        _state = CartState.weighing;
        notifyListeners();
        break;
      case 'alarm':
        _state = CartState.alarm;
        notifyListeners();
        break;
      case 'paid':
        _state = CartState.paid;
        notifyListeners();
        break;
      case 'checkout':
        _state = CartState.checkout;
        notifyListeners();
        break;
      default:
        _state = CartState.error;
        notifyListeners();
        break;
    }
  }

  bool isEmpty() {
    return _counter == 0;
  }

  @override
  void dispose() {
    devtools.log('Disconnecting Cart');
    super.dispose();
  }
}
