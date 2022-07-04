import 'package:flutter/foundation.dart';

class GameModel extends ChangeNotifier {
  num points = 0;
  late num record = 0;

  addPoints(num amount) {
    points += amount;
    notifyListeners();
  }
}