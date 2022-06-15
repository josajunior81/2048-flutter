import 'dart:math';

import 'package:flutter/material.dart';

enum BlockNumber {
  ZERO,
  ONE,
  TWO,
  THREE,
  FOUR,
  FIVE,
  SIX,
  SEVEN,
  EIGHT,
  NINE,
  TEN,
  ELEVEN,
  TWELVE,
  THIRTEEN,
  FOURTEEN,
  FIFTEEN,
  SIXTEEN,
  SEVENTEEN;

  static BlockNumber next(num value) {
    if (value == 0) return BlockNumber.ONE;
    if (value == pow(2, 1)) return BlockNumber.TWO;
    if (value == pow(2, 2)) return BlockNumber.THREE;
    if (value == pow(2, 3)) return BlockNumber.FOUR;
    if (value == pow(2, 4)) return BlockNumber.FIVE;
    if (value == pow(2, 5)) return BlockNumber.SIX;
    if (value == pow(2, 6)) return BlockNumber.SEVEN;
    if (value == pow(2, 7)) return BlockNumber.EIGHT;
    if (value == pow(2, 8)) return BlockNumber.NINE;
    if (value == pow(2, 9)) return BlockNumber.TEN;
    if (value == pow(2, 10)) return BlockNumber.ELEVEN;
    if (value == pow(2, 11)) return BlockNumber.TWELVE;
    if (value == pow(2, 12)) return BlockNumber.THIRTEEN;
    if (value == pow(2, 13)) return BlockNumber.FOURTEEN;
    if (value == pow(2, 14)) return BlockNumber.FIFTEEN;
    if (value == pow(2, 15)) return BlockNumber.SIXTEEN;
    if (value == pow(2, 16)) return BlockNumber.SEVENTEEN;
    return BlockNumber.ZERO;
  }

  static BlockNumber previous(num value) {
    if (value == pow(2, 1)) return BlockNumber.ZERO;
    if (value == pow(2, 2)) return BlockNumber.ONE;
    if (value == pow(2, 3)) return BlockNumber.TWO;
    if (value == pow(2, 4)) return BlockNumber.THREE;
    if (value == pow(2, 5)) return BlockNumber.FOUR;
    if (value == pow(2, 6)) return BlockNumber.FIVE;
    if (value == pow(2, 7)) return BlockNumber.SIX;
    if (value == pow(2, 8)) return BlockNumber.SEVEN;
    if (value == pow(2, 9)) return BlockNumber.EIGHT;
    if (value == pow(2, 10)) return BlockNumber.NINE;
    if (value == pow(2, 11)) return BlockNumber.TEN;
    if (value == pow(2, 12)) return BlockNumber.ELEVEN;
    if (value == pow(2, 13)) return BlockNumber.TWELVE;
    if (value == pow(2, 14)) return BlockNumber.THIRTEEN;
    if (value == pow(2, 15)) return BlockNumber.FOURTEEN;
    if (value == pow(2, 16)) return BlockNumber.FIFTEEN;
    if (value == pow(2, 17)) return BlockNumber.SIXTEEN;
    return BlockNumber.ZERO;
  }
}

extension BlockNumberExtension on BlockNumber {
  num get value {
    switch (this) {
      case BlockNumber.ONE:
        return pow(2, 1);
      case BlockNumber.TWO:
        return pow(2, 2);
      case BlockNumber.THREE:
        return pow(2, 3);
      case BlockNumber.FOUR:
        return pow(2, 4);
      case BlockNumber.FIVE:
        return pow(2, 5);
      case BlockNumber.SIX:
        return pow(2, 6);
      case BlockNumber.SEVEN:
        return pow(2, 7);
      case BlockNumber.EIGHT:
        return pow(2, 8);
      case BlockNumber.NINE:
        return pow(2, 9);
      case BlockNumber.TEN:
        return pow(2, 10);
      case BlockNumber.ELEVEN:
        return pow(2, 11);
      case BlockNumber.TWELVE:
        return pow(2, 12);
      case BlockNumber.THIRTEEN:
        return pow(2, 13);
      case BlockNumber.FOURTEEN:
        return pow(2, 14);
      case BlockNumber.FIFTEEN:
        return pow(2, 15);
      case BlockNumber.SIXTEEN:
        return pow(2, 16);
      case BlockNumber.SEVENTEEN:
        return pow(2, 17);
      default:
        return 0;
    }
  }

  Color get color {
    switch (this) {
      case BlockNumber.ONE:
        return Color.fromARGB(255, 240, 228, 218);
      case BlockNumber.TWO:
        return Color.fromARGB(255, 236, 224, 201);
      case BlockNumber.THREE:
        return Color.fromARGB(255, 255, 178, 120);
      case BlockNumber.FOUR:
        return Color.fromARGB(255, 254, 150, 92);
      case BlockNumber.FIVE:
        return Color.fromARGB(255, 247, 123, 97);
      case BlockNumber.SIX:
        return Color.fromARGB(255, 235, 88, 55);
      case BlockNumber.SEVEN:
        return Color.fromARGB(255, 236, 220, 146);
      case BlockNumber.EIGHT:
        return Color.fromARGB(255, 240, 212, 121);
      case BlockNumber.NINE:
        return Color.fromARGB(255, 244, 206, 96);
      case BlockNumber.TEN:
        return Color.fromARGB(255, 248, 200, 71);
      case BlockNumber.ELEVEN:
        return Color.fromARGB(255, 256, 194, 46);
      case BlockNumber.TWELVE:
        return Color.fromARGB(255, 104, 130, 249);
      case BlockNumber.THIRTEEN:
        return Color.fromARGB(255, 51, 85, 247);
      case BlockNumber.FOURTEEN:
        return Color.fromARGB(255, 10, 47, 222);
      case BlockNumber.FIFTEEN:
        return Color.fromARGB(255, 9, 43, 202);
      case BlockNumber.SIXTEEN:
        return Color.fromARGB(255, 181, 37, 188);
      case BlockNumber.SEVENTEEN:
        return Color.fromARGB(255, 166, 34, 172);
      default:
        return Color(0xffcec0b2);
    }
  }

  ColorTween get animation {
    switch (this) {
      case BlockNumber.ONE:
        return ColorTween(begin: BlockNumber.ZERO.color, end: BlockNumber.ONE.color);
      case BlockNumber.TWO:
        return ColorTween(begin: BlockNumber.ONE.color, end:  BlockNumber.TWO.color);
      case BlockNumber.THREE:
        return ColorTween(begin: BlockNumber.TWO.color, end:  BlockNumber.THREE.color);
      case BlockNumber.FOUR:
        return ColorTween(begin: BlockNumber.THREE.color, end:  BlockNumber.FOUR.color);
      case BlockNumber.FIVE:
        return ColorTween(begin: BlockNumber.FOUR.color, end:  BlockNumber.FIVE.color);
      case BlockNumber.SIX:
        return ColorTween(begin: BlockNumber.FIVE.color, end:  BlockNumber.SIX.color);
      case BlockNumber.SEVEN:
        return ColorTween(begin: BlockNumber.SIX.color, end:  BlockNumber.SEVEN.color);
      case BlockNumber.EIGHT:
        return ColorTween(begin: BlockNumber.SEVEN.color, end:  BlockNumber.EIGHT.color);
      case BlockNumber.NINE:
        return ColorTween(begin: BlockNumber.EIGHT.color, end:  BlockNumber.NINE.color);
      case BlockNumber.TEN:
        return ColorTween(begin: BlockNumber.NINE.color, end:  BlockNumber.TEN.color);
      case BlockNumber.ELEVEN:
        return ColorTween(begin: BlockNumber.TEN.color, end:  BlockNumber.ELEVEN.color);
      case BlockNumber.TWELVE:
        return ColorTween(begin: BlockNumber.ELEVEN.color, end:  BlockNumber.TWELVE.color);
      case BlockNumber.THIRTEEN:
        return ColorTween(begin: BlockNumber.TWELVE.color, end:  BlockNumber.THIRTEEN.color);
      case BlockNumber.FOURTEEN:
        return ColorTween(begin: BlockNumber.THIRTEEN.color, end:  BlockNumber.FOURTEEN.color);
      case BlockNumber.FIFTEEN:
        return ColorTween(begin: BlockNumber.FOURTEEN.color, end:  BlockNumber.FIFTEEN.color);
      case BlockNumber.SIXTEEN:
        return ColorTween(begin: BlockNumber.FIFTEEN.color, end:  BlockNumber.SIXTEEN.color);
      case BlockNumber.SEVENTEEN:
        return ColorTween(begin: BlockNumber.SIXTEEN.color, end:  BlockNumber.SEVENTEEN.color);
      default:
        return ColorTween(begin: BlockNumber.ZERO.color, end:  BlockNumber.ONE.color);
    }
  }

  ColorTween get backAnimation {
    switch (this) {
      case BlockNumber.ONE:
        return ColorTween(begin: BlockNumber.ONE.color, end: BlockNumber.ZERO.color);
      default:
        return ColorTween(begin: BlockNumber.ONE.color, end:  BlockNumber.ZERO.color);
    }
  }
}