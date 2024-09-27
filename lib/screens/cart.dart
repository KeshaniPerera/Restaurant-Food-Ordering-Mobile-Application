import 'package:flutter/material.dart';
import 'item_model.dart';

class Cart with ChangeNotifier {
  Map<String, Item> _items = {};

  Map<String, Item> get items {
    return {..._items};
  }

  void addItem(Item item) {
    if (_items.containsKey(item.name)) {
      // Increase the quantity if the item is already in the cart
      _items.update(
        item.name,
            (existingItem) => Item(
          name: existingItem.name,
          price: existingItem.price,
          imageUrl: existingItem.imageUrl,
          quantity: existingItem.quantity + item.quantity, // Update quantity
          subtotal: existingItem.subtotal + (item.quantity * item.price), // Update subtotal
        ),
      );
    } else {
      // Add new item to the cart
      _items.putIfAbsent(
        item.name,
            () => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity,
          subtotal: item.quantity * item.price, // Calculate subtotal for new item
        ),
      );
    }
    notifyListeners();
  }

  void increaseQuantity(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.update(
        itemName,
            (item) => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity + 1, // Increase quantity by 1
          subtotal: (item.quantity + 1) * item.price, // Update subtotal
        ),
      );
      notifyListeners();
    }
  }

  void decreaseQuantity(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.update(
        itemName,
            (item) => Item(
          name: item.name,
          price: item.price,
          imageUrl: item.imageUrl,
          quantity: item.quantity > 1 ? item.quantity - 1 : 1, // Decrease quantity by 1, but keep it at least 1
          subtotal: (item.quantity > 1 ? item.quantity - 1 : 1) * item.price, // Update subtotal
        ),
      );
      notifyListeners();
    }
  }

  void removeItem(String itemName) {
    if (_items.containsKey(itemName)) {
      _items.remove(itemName);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
