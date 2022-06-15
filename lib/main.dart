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
  ValueNotifier<num> points = ValueNotifier(0);

  late final grid = List.generate(
      widget.blocksPerLine,
      (_) => List.filled(widget.blocksPerLine,
          Block("", 0, 0, ValueNotifier<BlockNumber>(BlockNumber.ZERO), AnimationController(vsync: this))),
      growable: false); //<List<Block>>[];
  late final blocksList = <Block>[];

  @override
  void didChangeDependencies() {
    initGame();
    initPositions();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    grid.forEach((element) {
      element.forEach((element) {
        element.animationController.dispose();
      });
    });
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
              block.animationController.reset();
              block.animationController.forward();
            }
          }
        }
      }
    }
  }

  Widget createBlock(Block block) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: ValueListenableBuilder(
            valueListenable: block.blockNumber,
            builder: (context, value, child) {
              var blockNumber = block.blockNumber.value;

              // var _sizeAnimation = Tween(begin: cellSize, end: cellSize)
              //     .chain(TweenSequence([
              //       TweenSequenceItem(
              //           tween: Tween(begin: cellSize + 10, end: cellSize + 10),
              //           weight: 1),
              //       TweenSequenceItem(
              //           tween: Tween(begin: cellSize - 20, end: cellSize - 10),
              //           weight: 1),
              //       TweenSequenceItem(
              //           tween: Tween(begin: cellSize, end: cellSize),
              //           weight: 1),
              //     ]))
              //     .animate(block.animationController);


              var _colorAnimation =
              blockNumber.value == 0 ?
                blockNumber.backAnimation.animate(block.animationController) :
              blockNumber.animation.animate(block.animationController);

              return AnimatedBuilder(
                animation: block.animationController,
                builder: (context, wid) => Container(
                  height: cellSize,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: _colorAnimation.value),
                  child: Center(
                    child: Text(
                      blockNumber.value == 0 ? "" : "${blockNumber.value}",
                      style: TextStyle(
                          fontSize: 50,
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

  initGame() {
    for (int i = 0; i < totalBlocks; i++) {
      var x = (i / widget.blocksPerLine).floor();
      var y = i % widget.blocksPerLine;
      var controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      var block =
          Block("$x$y", x, y, ValueNotifier<BlockNumber>(BlockNumber.ZERO), controller);
      block.widget = createBlock(block);
      grid[x][y] = block;
      block.animationController.forward();
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
          points.value += block.merge();
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
          points.value += block.merge();
          next.free();
        }
      }
    }
  }

  moveUp() {
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = 0; j < widget.blocksPerLine; j++) {
        if (j + 1 >= widget.blocksPerLine) break;
        for (var y = j + 1; y >= 0; y--) {
          if (y - 1 < 0) break;
          var previous = grid[y - 1][i];
          var next = grid[y][i];
          if (!next.isFree && previous.isFree) {
            previous.alloc(next.blockNumber.value);
            next.free();
          } else if (!next.isFree && !previous.isFree) {
            if (previous.canMerge &&
                next.canMerge &&
                next.blockNumber.value.value ==
                    previous.blockNumber.value.value) {
              points.value += previous.merge();
              next.free();
            }
          }
        }
      }
    }
  }

  moveDown() {
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = widget.blocksPerLine - 1; j >= 0; j--) {
        if (j - 1 < 0) break;
        for (var y = j - 1; y < widget.blocksPerLine; y++) {
          if (y + 1 >= widget.blocksPerLine) break;
          var previous = grid[y][i];
          var next = grid[y + 1][i];
          if (next.isFree && !previous.isFree) {
            next.alloc(previous.blockNumber.value);
            previous.free();
          } else if (!next.isFree && !previous.isFree) {
            if (previous.canMerge &&
                next.canMerge &&
                next.blockNumber.value.value ==
                    previous.blockNumber.value.value) {
              points.value += next.merge();
              previous.free();
            }
          }
        }
      }
    }
  }

  swipe(Direction direction) async {
    if (direction == Direction.right) {
      grid.forEach((row) {
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
    await Future.delayed(const Duration(milliseconds: 200), () {
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
        body: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ValueListenableBuilder(
                    valueListenable: points,
                    builder: (context, value, child) => Text(
                      "${points.value}",
                      style: TextStyle(
                          fontSize: 50,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )),
            Expanded(
              flex: 3,
              child: Container(
                height: boardSize,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Color(0xffb9aea0)),
                margin: EdgeInsets.symmetric(horizontal: 10),
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
                    double positiveVelocity =
                        velocity < 0 ? -velocity : velocity;
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
                    double positiveVelocity =
                        velocity < 0 ? -velocity : velocity;

                    if (dx < horizontalSwipeMinDisplacement) return;
                    if (dy > horizontalSwipeMaxHeightThreshold) return;
                    if (positiveVelocity < horizontalSwipeMinVelocity) return;

                    if (velocity < 0) {
                      swipe(Direction.left);
                    } else {
                      swipe(Direction.right);
                    }
                  },
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.blocksPerLine,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
                    itemCount: widget.blocksPerLine * widget.blocksPerLine,
                    itemBuilder: (context, index) {
                      var x = (index / widget.blocksPerLine).floor();
                      var y = index % widget.blocksPerLine;
                      return grid[x][y].widget;
                    },
                  ),
                ),
              ),
            ),
            Expanded(flex: 1, child: Container())
          ],
        ));
  }
}

// return TweenAnimationBuilder(
// tween: blockNumber.animation,
// duration: Duration(milliseconds: 500),
// builder: (context, value, widget) => Container(
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(5.0),
// color: value as Color),
// child: Center(
// child: Text(
// blockNumber.value == 0 ? "" : "${blockNumber.value}",
// style: TextStyle(
// fontSize: 50,
// color: blockNumber.value < 8
// ? Colors.black54
//     : Colors.white,
// fontWeight: FontWeight.bold),
// ),
// ),
// ),
// );
