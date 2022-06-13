import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:game_2048/model/enum_block.dart';

class BlockWidget extends StatefulWidget {
  const BlockWidget(
      {Key? key,
      required this.cellSize,
      required this.position,
      required this.blockNumber})
      : super(key: key);

  final double cellSize;
  final int position;
  final BlockNumber blockNumber;

  @override
  State<BlockWidget> createState() => _BlockState();
}

class _BlockState extends State<BlockWidget> {
  ValueNotifier<BlockNumber> blockNumber =
      ValueNotifier<BlockNumber>(BlockNumber.ZERO);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: SizedBox(
          height: widget.cellSize,
          width: widget.cellSize,
          child: ValueListenableBuilder(
            valueListenable: blockNumber,
            builder: (context, value, child) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: (value as BlockNumber).color),
              );
            },
          )),
    );
  }
}
