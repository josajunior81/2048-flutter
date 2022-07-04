import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:game_2048/game_logic.dart';
import 'package:game_2048/game_widget.dart';
import 'package:game_2048/model/game_model.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(ChangeNotifierProvider(
            create: (context) => GameModel(),
            child: const Game(),
          )));
}
