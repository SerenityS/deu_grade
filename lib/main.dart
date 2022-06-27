import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'screens/login_screen.dart';
import 'screens/score_screen.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  print("A");
  BackgroundFetch.finish(taskId);
}

Future<void> main() async {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return RefreshConfiguration(
      headerTriggerDistance: 50.0, // header trigger refresh trigger distance
      maxOverScrollExtent: 0, //The maximum dragging range of the head. Set this property if a rush out of the view area occurs
      enableScrollWhenRefreshCompleted:
          true, //This property is incompatible with PageView and TabBarView. If you need TabBarView to slide left and right, you need to set it to true.
      enableLoadingWhenFailed: true, //In the case of load failure, users can still trigger more loads by gesture pull-up.
      enableBallisticLoad: true, // trigger load more by BallisticScrollActivity
      enableRefreshVibrate: true,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
          primaryIconTheme: const IconThemeData(
            color: Colors.black,
          ),
          scaffoldBackgroundColor: const Color.fromARGB(255, 244, 244, 244),
        ),
        title: 'DEU Grade',
        initialRoute: '/login',
        getPages: [
          GetPage(name: '/login', page: () => LoginScreen()),
          GetPage(name: '/score', page: () => ScoreListScreen()),
        ],
      ),
    );
  }
}
