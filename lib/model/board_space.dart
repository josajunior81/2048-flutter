import 'block.dart';

class BoardSpace {
  final int x;
  final int y;
  bool isFree = true;
  Block? block;

  BoardSpace(this.x, this.y);
}