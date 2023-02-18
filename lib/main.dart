import 'dart:convert';

import 'package:arnituramobile/loadingModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arnituramobile/globals.dart';
import 'app_bar_drawer_list.dart';
import 'ar.dart';
import 'bottomNavbar.dart';
import 'main_drawer.dart';
import 'post.dart';
import 'first_screen.dart';

Future<void> main() async {
  return runApp(MaterialApp(home: FScreen(), debugShowCheckedModeBanner: false));
  // await SentryFlutter.init(
  //   (options) {
  //     debugPaintSizeEnabled = false;
  //     options.dsn =
  //         'https://c8c4539554e84fefb9819c2a44c31074@o402412.ingest.sentry.io/6132266';
  //     options.tracesSampleRate = 1.0;
  //   },
  //   appRunner: () =>
  //       runApp(MaterialApp(home: FScreen(), debugShowCheckedModeBanner: false)),
  // );
}

class MyApp extends StatefulWidget {
  final String data;

  MyApp({required this.data});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var posts = [];
  var lasts_posts = '{}';
  var index = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    getPostsFromMemory(widget.data);
  }

  void setStatePosts() {
    setState(() {});
  } // Обновление ленты с помощью дочернего элемента

  void getPostsFromMemory(postsInfo) async {
    var prefs = await SharedPreferences.getInstance();
    if (postsInfo != 'null') {
      prefs.setString('postsInfo', postsInfo);
      lasts_posts = postsInfo;
    } else {
      postsInfo = prefs.getString('postsInfo');
      lasts_posts = postsInfo;
    }
    setState(() {});
  } // Получение постов из памяти

  @override
  Widget build(BuildContext context) {
    var s1 = Builder(
      builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          drawer: DrawerKreslo(setStatePosts: this.setStatePosts),
          appBar: AppBarDrawerList(''),
          body: FutureBuilder<String>(
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return ListView.builder(
                  shrinkWrap: false,
                  itemBuilder: (BuildContext context, int index) {
                    // debugPrint(data[index.toString()].toString());
                    return Post(
                        id: jsonDecode(lasts_posts)[index.toString()]['id']
                            .toString(),
                        manufacturer_id:
                            jsonDecode(lasts_posts)[index.toString()]
                                    ['manufacturer_id']
                                .toString(),
                        setStatePosts: setStatePosts);
                  },
                  itemCount: jsonDecode(lasts_posts).length);
            },
          ),
          bottomNavigationBar: arniturabottomNavBar(currentIndex: 0)),
    );
    var s0 = ArWidget(
        id_texture: idTextureUnityModel,
        id_post: idPostUnityModel,
        ArChildController: ArController,
        setStatePosts: this.setStatePosts);
    var loading = LoadingWidget();
    var listWidgets = [s1, s0, loading];
    return MaterialApp(
      home: Scaffold(
        backgroundColor: indexUnityPageLayer == 1 ? Colors.black : Colors.white,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: indexUnityPageLayer,
            children: listWidgets,
          ),
        ),
      ),
    );
  }
}
