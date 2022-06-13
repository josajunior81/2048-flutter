import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:game_2048/model/block.dart';
import 'package:game_2048/model/enum_block.dart';

void main() {
  runApp(const Game());
}

enum Direction {
  left,
  right,
  up,
  down;
}

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        backgroundColor: Color.fromARGB(255, 253, 247, 240),
      ),
      home: const GameBoard(title: '2048'),
    );
  }
}

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key, required this.title}) : super(key: key);

  final String title;
  final int blocksPerLine = 4;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(microseconds: 100),
    vsync: this,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  ));

  double verticalSwipeMaxWidthThreshold = 50.0;
  double verticalSwipeMinDisplacement = 100.0;
  double verticalSwipeMinVelocity = 300.0;

  //Horizontal swipe configuration options
  double horizontalSwipeMaxHeightThreshold = 50.0;
  double horizontalSwipeMinDisplacement = 100.0;
  double horizontalSwipeMinVelocity = 300.0;

  final _random = new Random();
  double? swipeDir;

  late final totalBlocks = widget.blocksPerLine * widget.blocksPerLine;
  late final boardSize = MediaQuery.of(context).size.width - 10;
  late final cellSize = (boardSize / widget.blocksPerLine) - 12.0;

  late final tiles = <Widget>[];

  late final grid = <List<Block>>[];
  late final blocksList = <Block>[];

  @override
  void didChangeDependencies() {
    initGame();
    initPositions();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int next() => _random.nextInt(widget.blocksPerLine);

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
        found = true;
        for (int i = 0; i < widget.blocksPerLine; i++) {
          for (int j = 0; j < widget.blocksPerLine; j++) {
            if (i == row && j == col) {
              var block = grid[i][j];
              block.isFree = false;
              block.blockNumber.value = BlockNumber.ONE;
            }
          }
        }
      }
    }
  }

  Widget createBlock(Block block) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: SizedBox(
          height: cellSize,
          width: cellSize,
          child: ValueListenableBuilder(
            valueListenable: block.blockNumber,
            builder: (context, value, child) {
              var blockNumber = (value as BlockNumber);
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: blockNumber.color),
                child: Center(
                  child: Text(
                    blockNumber.value == 0 ? "" : "${blockNumber.value}",
                    style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      );

  initGame() {
    for (int i = 0; i < widget.blocksPerLine; i++) {
      var bw = <Widget>[];
      var bl = <Block>[];
      for (int j = 0; j < widget.blocksPerLine; j++) {
        var block =
            Block("$i$j", i, j, ValueNotifier<BlockNumber>(BlockNumber.ZERO));
        bl.add(block);
        bw.add(createBlock(block));
      }
      grid.add(bl);
      tiles.add(Row(
        children: bw,
      ));
    }
  }

  bool canMerge(Block target, Block block) {
    return block.canMerge && target.canMerge;
  }

  merge(Block target, Block block) {
    if (target.blockNumber.value.value == block.blockNumber.value.value) {
      target.merge();
      block.free();
    }
  }

  // moveHorizontally(List<Block> row) {
  //   row.forEach((r) {
  //     for (var i = 0; i < widget.blocksPerLine; i++) {
  //       if (i + 1 == widget.blocksPerLine) break;
  //       var block = grid[r.x][i];
  //       var next = grid[r.x][i + 1];
  //       if (block.isFree && !next.isFree) {
  //         block.alloc(next.blockNumber.value);
  //         next.free();
  //       } else if (!block.isFree) {
  //         if (block.canMerge &&
  //             next.canMerge &&
  //             next.blockNumber.value.value == block.blockNumber.value.value) {
  //           block.merge();
  //           next.free();
  //         }
  //       }
  //     }
  //   });
  // }

  moveRight(int x) {
    for (var i = widget.blocksPerLine - 1; i >= 0; i--) {
      if (i - 1 == -1) break;
      var block = grid[x][i];
      var next = grid[x][i - 1];
      if (block.isFree && !next.isFree) {
        block.alloc(next.blockNumber.value);
        next.free();
      } else if (!block.isFree) {
        if (block.canMerge &&
            next.canMerge &&
            next.blockNumber.value.value == block.blockNumber.value.value) {
          block.merge();
          next.free();
        }
      }
    }
  }

  moveLeft(int x) {
    for (var i = 0; i < widget.blocksPerLine; i++) {
      if (i + 1 == widget.blocksPerLine) break;
      var block = grid[x][i];
      var next = grid[x][i + 1];
      if (block.isFree && !next.isFree) {
        block.alloc(next.blockNumber.value);
        next.free();
      } else if (!block.isFree) {
        if (block.canMerge &&
            next.canMerge &&
            next.blockNumber.value.value == block.blockNumber.value.value) {
          block.merge();
          next.free();
        }
      }
    }
  }

  moveUp() {
    // var rev = grid.reversed.toList();
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = widget.blocksPerLine - 1; j >= 0; j--) {
        if (j - 1 == -1) break;
        var block = grid[j][i];
        var next = grid[j - 1][i];
        if (next.isFree && !block.isFree) {
          next.alloc(block.blockNumber.value);
          block.free();
        } else if (!next.isFree && !block.isFree) {
          if (block.canMerge &&
              next.canMerge &&
              next.blockNumber.value.value == block.blockNumber.value.value) {
            next.merge();
            block.free();
          }
        }
      }
    }
  }

  moveDown() {
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = 0; j < widget.blocksPerLine; j++) {
        if (j + 1 >= widget.blocksPerLine) break;
        var block = grid[j][i];
        var next = grid[j + 1][i];
        if (next.isFree && !block.isFree) {
          next.alloc(block.blockNumber.value);
          block.free();
        } else if (!next.isFree && !block.isFree) {
          if (block.canMerge &&
              next.canMerge &&
              next.blockNumber.value.value == block.blockNumber.value.value) {
            next.merge();
            block.free();
          }
        }
      }
    }
  }

  swipe(Direction direction) async {
    if (direction == Direction.right) {
      grid.reversed.forEach((row) {
        row.forEach((col) {
          debugPrint("${col.x} : ${col.y}");
          moveRight(col.x);
        });
      });
    } else if (direction == Direction.left) {
      grid.forEach((row) {
        row.forEach((col) {
          debugPrint("${col.x} : ${col.y}");
          moveLeft(col.x);
        });
      });
    } else if (direction == Direction.up) {
      moveUp();
    } else if (direction == Direction.down) {
      moveDown();
    }
    await Future.delayed(const Duration(seconds: 1), () {
      setNextPosition();
    });
    grid.forEach((element) {
      element.forEach((element) {
        element.canMerge = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var sensitivity = 3.0;

    //Vertical drag details
    DragStartDetails? startVerticalDragDetails;
    DragUpdateDetails? updateVerticalDragDetails;

    //Horizontal drag details
    DragStartDetails? startHorizontalDragDetails;
    DragUpdateDetails? updateHorizontalDragDetails;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 247, 240),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          width: boardSize,
          height: boardSize,
          child: GestureDetector(
            onVerticalDragStart: (dragDetails) {
              startVerticalDragDetails = dragDetails;
            },
            onVerticalDragUpdate: (dragDetails) {
              updateVerticalDragDetails = dragDetails;
            },
            onVerticalDragEnd: (endDetails) {
              double dx = updateVerticalDragDetails!.globalPosition.dx -
                  startVerticalDragDetails!.globalPosition.dx;
              double dy = updateVerticalDragDetails!.globalPosition.dy -
                  startVerticalDragDetails!.globalPosition.dy;
              double velocity = endDetails.primaryVelocity!;
              //Convert values to be positive
              if (dx < 0) dx = -dx;
              if (dy < 0) dy = -dy;
              double positiveVelocity = velocity < 0 ? -velocity : velocity;
              if (dx > verticalSwipeMaxWidthThreshold) return;
              if (dy < verticalSwipeMinDisplacement) return;
              if (positiveVelocity < verticalSwipeMinVelocity) return;
              if (velocity < 0) {
                swipe(Direction.up);
              } else {
                swipe(Direction.down);
              }
            },
            onHorizontalDragStart: (dragDetails) {
              startHorizontalDragDetails = dragDetails;
            },
            onHorizontalDragUpdate: (dragDetails) {
              updateHorizontalDragDetails = dragDetails;
            },
            onHorizontalDragEnd: (endDetails) {
              double dx = updateHorizontalDragDetails!.globalPosition.dx -
                  startHorizontalDragDetails!.globalPosition.dx;

              double dy = updateHorizontalDragDetails!.globalPosition.dy -
                  startHorizontalDragDetails!.globalPosition.dy;

              double velocity = endDetails.primaryVelocity!.toDouble();

              if (dx < 0) dx = -dx;
              if (dy < 0) dy = -dy;
              double positiveVelocity = velocity < 0 ? -velocity : velocity;

              if (dx < horizontalSwipeMinDisplacement) return;
              if (dy > horizontalSwipeMaxHeightThreshold) return;
              if (positiveVelocity < horizontalSwipeMinVelocity) return;

              if (velocity < 0) {
                swipe(Direction.left);
              } else {
                swipe(Direction.right);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Color(0xffb9aea0)),
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: tiles,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
