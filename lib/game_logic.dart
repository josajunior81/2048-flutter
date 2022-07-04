import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:game_2048/block_widget.dart';
import 'package:game_2048/model/game_model.dart';

import 'model/block.dart';
import 'model/enum_block.dart';

class GameLogic {
  final int blocksPerLine;
  final double boardSize;
  final TickerProvider tickerProvider;
  final GameModel gameModel;

  final _random = Random();
  late List<List<Block>> grid;

  late final totalBlocks = blocksPerLine * blocksPerLine;
  late final cellSize = (boardSize / blocksPerLine);

  bool hasMoved = false;
  int movesCounter = 0;

  GameLogic(this.blocksPerLine, this.boardSize, this.tickerProvider, this.gameModel);

  int next() => _random.nextInt(blocksPerLine);

  initPositions() {
    setNextPosition();
    setNextPosition();
  }

  setNextPosition() {
    var found = false;
    while (!found) {
      var row = next();
      var col = next();
      if (grid[row][col].isFree) {
        var block = grid[row][col];
        block.isFree = false;
        block.alloc(BlockNumber.ONE);
        found = true;
        // for (int i = 0; i < blocksPerLine; i++) {
        //   for (int j = 0; j < blocksPerLine; j++) {
        //     if (i == row && j == col) {
        //       var block = grid[i][j];
        //       block.isFree = false;
        //       block.alloc(BlockNumber.ONE);
        //     }
        //   }
        // }
      }
    }
  }

  initGrid() {
    grid = List.generate(
        blocksPerLine,
        (_) => List.filled(
            blocksPerLine,
            Block("", 0, 0, ValueNotifier<BlockNumber>(BlockNumber.ZERO),
                AnimationController(vsync: tickerProvider))),
        growable: false);

    for (int i = 0; i < totalBlocks; i++) {
      var x = (i / blocksPerLine).floor();
      var y = i % blocksPerLine;
      var controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: tickerProvider,
      );
      var block = Block("$x$y", x, y,
          ValueNotifier<BlockNumber>(BlockNumber.ZERO), controller);
      block.widget = blockWidget(block, 12);
      grid[x][y] = block;
      block.animationController.forward();
    }
  }

  bool canMoveOrMerge(Block target, Block block) =>
      target.isFree || canMerge(target, block);

  bool canMerge(Block target, Block block) =>
      block.canMerge &&
      target.canMerge &&
      (target.blockNumber.value.value == block.blockNumber.value.value);

  alloc(Block target, Block block) {
    target.alloc(block.blockNumber.value);
    block.free();
    hasMoved = true;
  }

  merge(Block target, Block block) {
    gameModel.addPoints(target.merge());
    block.free();
    hasMoved = true;
  }

  movesRight() {
    for (var row in grid) {
      for (var col in row) {
        moveRight(col.x);
      }
    }
  }

  movesLeft() {
    for (var row in grid) {
      for (var col in row) {
        moveLeft(col.x);
      }
    }
  }

  moveRight(int x) {
    for (var i = blocksPerLine - 1; i >= 0; i--) {
      if (i - 1 == -1) break;
      var block = grid[x][i];
      var next = grid[x][i - 1];
      if (block.isFree && !next.isFree) {
        alloc(block, next);
      } else if (!block.isFree) {
        if (canMerge(block, next)) merge(block, next);
      }
    }
  }

  moveLeft(int x) {
    for (var i = 0; i < blocksPerLine; i++) {
      if (i + 1 == blocksPerLine) break;
      var block = grid[x][i];
      var next = grid[x][i + 1];
      if (block.isFree && !next.isFree) {
        alloc(block, next);
      } else if (!block.isFree) {
        if (canMerge(block, next)) merge(block, next);
      }
    }
  }

  moveUp() {
    for (var i = 0; i < blocksPerLine; i++) {
      for (var j = 0; j < blocksPerLine; j++) {
        if (j + 1 >= blocksPerLine) break;
        for (var y = j + 1; y >= 0; y--) {
          if (y - 1 < 0) break;
          var previous = grid[y - 1][i];
          var next = grid[y][i];
          if (!next.isFree && previous.isFree) {
            alloc(previous, next);
          } else if (!next.isFree && !previous.isFree) {
            if (canMerge(previous, next)) merge(previous, next);
          }
        }
      }
    }
  }

  moveDown() {
    for (var i = 0; i < blocksPerLine; i++) {
      for (var j = blocksPerLine - 1; j >= 0; j--) {
        if (j - 1 < 0) break;
        for (var y = j - 1; y < blocksPerLine; y++) {
          if (y + 1 >= blocksPerLine) break;
          var previous = grid[y][i];
          var next = grid[y + 1][i];
          if (next.isFree && !previous.isFree) {
            alloc(next, previous);
          } else if (!next.isFree && !previous.isFree) {
            if (canMerge(next, previous)) merge(next, previous);
          }
        }
      }
    }
  }

  bool checkAvalibleMoves() {
    for (var x = 0; x < blocksPerLine; x++) {
      for (var y = 0; y < blocksPerLine; y++) {
        var block = grid[x][y];
        if (block.isFree) return true;
        if (x - 1 >= 0) {
          return canMoveOrMerge(grid[x - 1][y], block);
        }
        if (x + 1 < blocksPerLine) {
          return canMoveOrMerge(grid[x + 1][y], block);
        }
        if (y + 1 < blocksPerLine) {
          return canMoveOrMerge(grid[x][y + 1], block);
        }
        if (y - 1 >= 0) {
          return canMoveOrMerge(grid[x][y - 1], block);
        }
      }
    }
    return false;
  }

  void checkMovement() {
    if (hasMoved) {
      movesCounter++;
      hasMoved = false;
      setNextPosition();
    }
  }
}
