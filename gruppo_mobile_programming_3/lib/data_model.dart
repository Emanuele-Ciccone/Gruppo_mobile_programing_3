import 'package:flutter/material.dart';

class SharedData extends ChangeNotifier {
  List<String> shoppingLists = [];

  void addList(String name) {
    shoppingLists.add(name);
    notifyListeners();
  }
}
