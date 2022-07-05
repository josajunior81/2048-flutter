import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_2048/helpers/ad_helper.dart';
import 'package:game_2048/game_logic.dart';
import 'package:game_2048/model/block.dart';
import 'package:game_2048/model/enum_block.dart';
import 'package:game_2048/model/game_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../helpers/consts.dart';

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

  late final boardSize = MediaQuery.of(context).size.width * 0.9;
  late final infoSize = MediaQuery.of(context).size.height * 0.1;

  bool gameOver = false;

  bool isBannerAdReady = false;
  late final BannerAd bannerAd = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    request: AdRequest(),
    size: AdSize.banner,
    listener: AdHelper.adListener(),
  );

  late final GameLogic logic = GameLogic(
      widget.blocksPerLine, boardSize, this, Provider.of<GameModel>(context));

  @override
  void initState() {
    bannerAd.load();
    newGame();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var element in logic.grid) {
      for (var element in element) {
        element.animationController.dispose();
      }
    }
    bannerAd.dispose();
    super.dispose();
  }

  Future<InitializationStatus> initGoogleMobileAds() async {
    // final requestConfiguration = RequestConfiguration(
    //     testDeviceIds: ["1EEE4D3585B9B6CF5E2F2A80E029FFD9"]);
    // await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    return MobileAds.instance.initialize();
  }

  newGame() {
    logic.initGrid();
    logic.initPositions();
    setState(() {});
  }

  swipe(Direction direction) {
    if (direction == Direction.right) {
      logic.movesRight();
    } else if (direction == Direction.left) {
      logic.movesLeft();
    } else if (direction == Direction.up) {
      logic.moveUp();
    } else if (direction == Direction.down) {
      logic.moveDown();
    }

    logic.checkMovement();

    isGameOver();
  }

  isGameOver() {
    setState(() => {gameOver = !logic.checkAvalibleMoves()});
  }

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
      body: FutureBuilder<void>(
        future: initGoogleMobileAds(),
        builder: (context, snapshot) {
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: infoSize + 20,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: BlockNumber.NINE.color),
                                child: const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: AutoSizeText(
                                      "2048",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 64,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromRGBO(240, 228, 218, 1)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Row(
                                          children: [
                                            const AutoSizeText(
                                              "Points:  ",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Consumer<GameModel>(
                                                builder: (ctx, model, _) =>
                                                    AutoSizeText(
                                                  "${model.points}",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const AutoSizeText(
                                              "Record: ",
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Consumer<GameModel>(
                                                builder: (ctx, model, _) =>
                                                    AutoSizeText(
                                                  "${model.record}",
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: TextButton(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      BlockNumber.ELEVEN.color),
                                            ),
                                            onPressed: () => newGame(),
                                            child: const AutoSizeText(
                                              "New Game",
                                              style: TextStyle(fontSize: 20),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: boardSize,
                    width: boardSize,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: const Color(0xffb9aea0)),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: GestureDetector(
                      onVerticalDragStart: (dragDetails) {
                        startVerticalDragDetails = dragDetails;
                      },
                      onVerticalDragUpdate: (dragDetails) {
                        updateVerticalDragDetails = dragDetails;
                      },
                      onVerticalDragEnd: (endDetails) {
                        double dx =
                            updateVerticalDragDetails!.globalPosition.dx -
                                startVerticalDragDetails!.globalPosition.dx;
                        double dy =
                            updateVerticalDragDetails!.globalPosition.dy -
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
                        double dx =
                            updateHorizontalDragDetails!.globalPosition.dx -
                                startHorizontalDragDetails!.globalPosition.dx;

                        double dy =
                            updateHorizontalDragDetails!.globalPosition.dy -
                                startHorizontalDragDetails!.globalPosition.dy;

                        double velocity =
                            endDetails.primaryVelocity!.toDouble();

                        if (dx < 0) dx = -dx;
                        if (dy < 0) dy = -dy;
                        double positiveVelocity =
                            velocity < 0 ? -velocity : velocity;

                        if (dx < horizontalSwipeMinDisplacement) return;
                        if (dy > horizontalSwipeMaxHeightThreshold) return;
                        if (positiveVelocity < horizontalSwipeMinVelocity)
                          return;

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
                          return logic.grid[x][y].widget;
                        },
                      ),
                    ),
                  ),
                  if (isBannerAdReady)
                    Container(
                      alignment: Alignment.center,
                      child: AdWidget(ad: bannerAd),
                      width: bannerAd.size.width.toDouble(),
                      height: bannerAd.size.height.toDouble(),
                    ),
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
          );
        },
      ),
    );
  }
}
