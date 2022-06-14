import 'package:flutter/cupertino.dart';
import 'package:game_2048/model/board_space.dart';

import 'enum_block.dart';

class Block {
  late final String id;
  ValueNotifier<BlockNumber> blockNumber;
  int x;
  int y;
  int value = 0;
  Color color = Color(0xffcec0b2);
  bool isFree = true;
  bool canMerge = true;
  bool get available => isFree && canMerge;
  Widget widget = Container();

  void free() {
    this.isFree = true;
    this.blockNumber.value = BlockNumber.ZERO;
  }

  void alloc(BlockNumber value) {
    this.isFree = false;
    this.blockNumber.value = value;
  }

  num merge() {
    var total = blockNumber.value.value * 2;
    blockNumber.value = BlockNumber.next(blockNumber.value.value);
    canMerge = false;
    return total;
  }

  Block(this.id, this.x, this.y, this.blockNumber);
}
