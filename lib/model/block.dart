import 'package:flutter/cupertino.dart';
import 'package:game_2048/model/board_space.dart';

import 'enum_block.dart';

class Block {
  final String id;
  ValueNotifier<BlockNumber> blockNumber;
  int x;
  int y;
  int value = 0;
  Color color = Color(0xffcec0b2);
  bool isFree = true;
  bool canMerge = true;

  bool get available => isFree && canMerge;

  void free() {
    this.isFree = true;
    this.blockNumber.value = BlockNumber.ZERO;
  }

  void alloc(BlockNumber value) {
    this.isFree = false;
    this.blockNumber.value = value;
  }

  void merge() {
    blockNumber.value = BlockNumber.next(blockNumber.value.value);
    canMerge = false;
  }


  Block(this.id, this.x, this.y, this.blockNumber);
}
