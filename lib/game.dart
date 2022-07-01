import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:game_2048/model/block.dart';
import 'package:game_2048/model/enum_block.dart';

import 'consts.dart';

class Game extends StatelessWidget {
  const Game({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xF0D479, color),
        backgroundColor: const Color.fromARGB(255, 253, 247, 240),
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
  //Vertical swipe configuration options
  double verticalSwipeMaxWidthThreshold = 50.0;
  double verticalSwipeMinDisplacement = 100.0;
  double verticalSwipeMinVelocity = 300.0;

  //Horizontal swipe configuration options
  double horizontalSwipeMaxHeightThreshold = 50.0;
  double horizontalSwipeMinDisplacement = 100.0;
  double horizontalSwipeMinVelocity = 300.0;

  final _random = Random();

  late final totalBlocks = widget.blocksPerLine * widget.blocksPerLine;
  late final boardSize = MediaQuery.of(context).size.width - 10;
  late final cellSize = (boardSize / widget.blocksPerLine) - 12.0;
  late List<List<Block>> grid;

  ValueNotifier<num> points = ValueNotifier(0);
  int movesCounter = 0;
  bool hasMoved = false;
  bool gameOver = false;

  @override
  void didChangeDependencies() {
    newGame();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var element in grid) {
      for (var element in element) {
        element.animationController.dispose();
      }
    }
    super.dispose();
  }

  newGame() {
    initGrid();
    initPositions();
    setState(() {});
    points.value = 0;
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
              block.alloc(BlockNumber.ONE);
            }
          }
        }
      }
    }
  }

  Widget createBlock(Block block) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: ValueListenableBuilder(
            valueListenable: block.blockNumber,
            builder: (context, value, child) {
              var blockNumber = block.blockNumber.value;
              var colorAnimation = blockNumber.value == 0
                  ? blockNumber.backAnimation.animate(block.animationController)
                  : blockNumber.animation.animate(block.animationController);

              var fontSize = blockNumber.value < 100 ? 50.0 : 40.0;
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
                  height: cellSize,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: colorAnimation.value),
                  child: Center(
                    child: Text(
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

  initGrid() {
    grid = List.generate(
        widget.blocksPerLine,
        (_) => List.filled(
            widget.blocksPerLine,
            Block("", 0, 0, ValueNotifier<BlockNumber>(BlockNumber.ZERO),
                AnimationController(vsync: this))),
        growable: false);

    for (int i = 0; i < totalBlocks; i++) {
      var x = (i / widget.blocksPerLine).floor();
      var y = i % widget.blocksPerLine;
      var controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      var block = Block("$x$y", x, y,
          ValueNotifier<BlockNumber>(BlockNumber.ZERO), controller);
      block.widget = createBlock(block);
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
    points.value += target.merge();
    block.free();
    hasMoved = true;
  }

  moveRight(int x) {
    for (var i = widget.blocksPerLine - 1; i >= 0; i--) {
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
    for (var i = 0; i < widget.blocksPerLine; i++) {
      if (i + 1 == widget.blocksPerLine) break;
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
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = 0; j < widget.blocksPerLine; j++) {
        if (j + 1 >= widget.blocksPerLine) break;
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
    for (var i = 0; i < widget.blocksPerLine; i++) {
      for (var j = widget.blocksPerLine - 1; j >= 0; j--) {
        if (j - 1 < 0) break;
        for (var y = j - 1; y < widget.blocksPerLine; y++) {
          if (y + 1 >= widget.blocksPerLine) break;
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

  swipe(Direction direction) async {
    if (direction == Direction.right) {
      for (var row in grid) {
        for (var col in row) {
          moveRight(col.x);
        }
      }
    } else if (direction == Direction.left) {
      for (var row in grid) {
        for (var col in row) {
          moveLeft(col.x);
        }
      }
    } else if (direction == Direction.up) {
      moveUp();
    } else if (direction == Direction.down) {
      moveDown();
    }

    if (hasMoved) {
      movesCounter++;
      hasMoved = false;
      setNextPosition();
    }

    isGameOver();
  }

  isGameOver() {
    setState(() => {
      gameOver = !checkAvalibleMoves()
    });
  }

  bool checkAvalibleMoves() {
    for (var x = 0; x < widget.blocksPerLine; x++) {
      for (var y = 0; y < widget.blocksPerLine; y++) {
        var block = grid[x][y];
        if (block.isFree) return true;
        if (x - 1 >= 0) {
          return canMoveOrMerge(grid[x - 1][y], block);
        }
        if (x + 1 < widget.blocksPerLine) {
          return canMoveOrMerge(grid[x + 1][y], block);
        }
        if (y + 1 < widget.blocksPerLine) {
          return canMoveOrMerge(grid[x][y + 1], block);
        }
        if (y - 1 >= 0) {
          return canMoveOrMerge(grid[x][y - 1], block);
        }
      }
    }
    return false;
  }

  // showGameOver() {
  //   Widget newGameButton = TextButton(
  //     child: Text("New Game"),
  //     onPressed: () => newGame(),
  //   );
  //   Widget finishGameButton = TextButton(
  //     child: Text("Finish"),
  //     onPressed: () {},
  //   );
  //
  //   AlertDialog alert = AlertDialog(
  //     title: Text("Game Over"),
  //     content: Text("Create a new game?"),
  //     actions: [
  //       newGameButton,
  //       finishGameButton,
  //     ],
  //   );
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return alert;
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    //Vertical drag details
    DragStartDetails? startVerticalDragDetails;
    DragUpdateDetails? updateVerticalDragDetails;

    //Horizontal drag details
    DragStartDetails? startHorizontalDragDetails;
    DragUpdateDetails? updateHorizontalDragDetails;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 247, 240),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: BlockNumber.NINE.color),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "2048",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 240, 228, 218)),
                          child: Column(
                            children: [
                              const Text(
                                "Points",
                                style: TextStyle(fontSize: 20),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: ValueListenableBuilder(
                                  valueListenable: points,
                                  builder: (context, value, child) => Text(
                                    "${points.value}",
                                    style: const TextStyle(
                                        fontSize: 40,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          BlockNumber.ELEVEN.color),
                                ),
                                onPressed: () => newGame(),
                                child: const Text("New Game")),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: boardSize,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: const Color(0xffb9aea0)),
                margin: const EdgeInsets.symmetric(horizontal: 10),
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
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.blocksPerLine,
                      childAspectRatio: 1.0,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 0),
                    itemCount: widget.blocksPerLine * widget.blocksPerLine,
                    itemBuilder: (context, index) {
                      var x = (index / widget.blocksPerLine).floor();
                      var y = index % widget.blocksPerLine;
                      return grid[x][y].widget;
                    },
                  ),
                ),
              ),
              const Text("Monetization"),
            ],
          ),
          gameOver
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    alignment: Alignment.center,
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: const Color.fromRGBO(0, 0, 0, 0.5)),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child: const Text("Game Over",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          BlockNumber.ELEVEN.color),
                                ),
                                onPressed: () => newGame(),
                                child: const Text("New Game")),
                            TextButton(
                                style: ButtonStyle(
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.white),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.red),
                                ),
                                onPressed: () => SystemNavigator.pop(),
                                child: const Text("Finish")),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
