import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'model/block.dart';
import 'model/enum_block.dart';

Widget blockWidget(Block block, double cellSize) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
  child: ValueListenableBuilder(
      valueListenable: block.blockNumber,
      builder: (context, value, child) {
        var blockNumber = block.blockNumber.value;
        var colorAnimation = blockNumber.value == 0
            ? blockNumber.backAnimation.animate(block.animationController)
            : blockNumber.animation.animate(block.animationController);
        var fontSize = 50.0;
        var variation = block.canMerge ? 0 : 20;
        var sizeAnimation = TweenSequence<double>([
          TweenSequenceItem(
              tween: Tween(begin: fontSize, end: fontSize + variation),
              weight: 20),
          TweenSequenceItem(
              tween: Tween(
                  begin: fontSize + variation, end: fontSize - variation),
              weight: 20),
          TweenSequenceItem(
              tween: Tween(begin: fontSize, end: fontSize), weight: 60),
        ]).animate(block.animationController);

        block.canMerge = true;

        return AnimatedBuilder(
          animation: block.animationController,
          builder: (context, wid) => Container(
            height: cellSize - 20,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: colorAnimation.value),
            child: Center(
              child: AutoSizeText(
                blockNumber.value == 0 ? "" : "${blockNumber.value}",
                style: TextStyle(
                    fontSize: sizeAnimation.value,
                    color: blockNumber.value < 8
                        ? Colors.black54
                        : Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }),
);