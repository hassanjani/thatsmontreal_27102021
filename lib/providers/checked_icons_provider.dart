import 'package:flutter/cupertino.dart';

class CheckedIconsProvider extends ChangeNotifier {
  Map<int, int> selected = Map();

  CheckedIconsProvider();

  void toggle(int id) {
    if (selected.containsKey(id))
      selected.remove(id);
    else
      selected[id] = id;

    notifyListeners();
  }

  bool isChecked(int id) => selected.containsKey(id);

  String get list => selected.keys.join(',');
}
