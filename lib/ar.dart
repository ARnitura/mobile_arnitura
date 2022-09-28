import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:arnituramobile/loadingModels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:http/http.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'bottomNavbar.dart';

import 'package:dio/dio.dart';
import 'dart:async';
import 'package:file_utils/file_utils.dart';

import 'globals.dart';

Offset position = Offset(0, 0);

class ArWidget extends StatefulWidget {
  final String id_texture;
  final String id_post;
  final ArWidgetController ArChildController;
  final Function setStatePosts;

  ArWidget({
    required this.id_texture,
    required this.id_post,
    required this.ArChildController,
    required this.setStatePosts,
  });

  @override
  ArWidgetState createState() =>
      ArWidgetState(ArChildController, this.setStatePosts);
}

class ArWidgetState extends State<ArWidget> {
  ArWidgetState(ArWidgetController ArChildController, Function setStatePosts) {
    ArChildController.downloadModel = downloadModel;
    ArChildController.downloadTextureToModel = downloadTextureToModel;
  }

  var cartInfo;
  var inCart = true;

  var progress_download = "0";
  var downloaded_texture = '';
  var max_textures = '';
  var max_maps = '';
  var model_path = "No Data";

  void LockBlindPosition() async {
    setState(() {});
  }

  late UnityWidgetController _unityWidgetController;
  final BlindWidgetController BlindController = BlindWidgetController();
  final MainWidgetController MainController = MainWidgetController();
  late LoadingPageController Loading = LoadingController;
  late BlindWidget blind;
  late UnityWidget UnityScreen;

  Dio dio = Dio();

  @override
  Future<void> deactivate() async {
    super.deactivate();
    unityWidgetController
        .postMessage('_FlutterMessageHandler', 'ClearAR', '')
        ?.then((value) => Navigator.pop(context));
  } // При выходе с экрана ар, происходит полный сброс сцены внутри юнити

  @override
  void initState() {
    super.initState();
    this.UnityScreen = UnityWidget(
        onUnityCreated: onUnityCreated,
        onUnityMessage: onUnityMessage,
        enablePlaceholder: false,
        fullscreen: false);
    this.blind = BlindWidget(
        id_texture: idTextureUnityModel,
        id_post: idPostUnityModel,
        controller: BlindController);
    initCartInfo();
    initPosition();
  }

  Future<String> getPath() async {
    if (Platform.isAndroid) {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      return appDocumentsDirectory.path;
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  } // Путь до папки документов на устройстве пользователя

  Future<void> downloadModel() async {
    var res = await post(Uri.parse('${url_server}/api/get_info_post'),
        body: {'id_post': idPostUnityModel}); // Получаем информацию о посте
    var manufacturer_id = jsonDecode(res.body)['0']['manufacturer_id'];
    var model_id = jsonDecode(res.body)['0']['model_id'];
    var model_path =
        '${dirloc}/files/${manufacturer_id.toString()}/models/${model_id.toString()}.fbx';
    print('--------------------' + dirloc);
    if (File(model_path).existsSync() != true) {
      // Если модели нет, то она скачивается
      // try {
      final DownloadUrl =
          "${url_server}/api/download_model?manufacturer_id=${manufacturer_id.toString()}&model_id=${model_id.toString()}";
      FileUtils.mkdir([dirloc]); // Если папка отсутсвует, то создается новая
      await dio.download(DownloadUrl, model_path,
          onReceiveProgress: (receivedBytes, totalBytes) {
        percentModelLoading =
            "${((receivedBytes / totalBytes) * 100).toStringAsFixed(0)}%";
        Loading.setPercentModelLoading(); // Изменение переменной загрузки
        setState(() {});
      });
      // });
      // } catch (e) {
      //   print(e);
      // }
      // setState(() {
    } else {
      percentModelLoading = '100%';
      Loading.setPercentModelLoading();
      setState(() {});
    }
    this.model_path = model_path;
  }

  Future<void> downloadTextureToModel() async {
    maps = [];
    var textures = idTextureUnityModel.split(', ');
    var res = await post(Uri.parse('${url_server}/api/get_info_post'),
        body: {'id_post': idPostUnityModel}); // Получаем информацию о посте
    var manufacturer_id = jsonDecode(res.body)['0']['manufacturer_id'];
    this.max_textures = textures.length.toString(); // Количество текстур
    countMaxTexture = max_textures;
    Loading.setCountMaxTexture(); // Выводим количествово текстур
    for (int i = 0; i < textures.length; i++) {
      var texture_info =
          await post(Uri.parse('${url_server}/api/maps_info'), body: {
        'id_texture': idTextureUnityModel.split(', ')[i].toString(),
        'id_manufacturer': manufacturer_id.toString()
      }); // Получаем список карт для модели
      var maps = jsonDecode(texture_info.body)['maps'].split(', ');
      max_maps = maps.length.toString(); // Количество карт в этой текстуре
      countMaxMap = max_maps;
      Loading.setCountMaxMap(); // Выводим количество карт в текстуре
      for (int j = 0; j < maps.length; j++) {
        checkMap(maps[j], manufacturer_id, textures[i]);
        var map_path =
            '${dirloc}/files/${manufacturer_id.toString()}/models/textures/${textures[i].toString()}/${maps[j]}';
        if (File(map_path).existsSync() != true) {
          // Если файла нет, то он скачивается
          try {
            final DownloadUrl =
                "${url_server}/api/download_texture?manufacturer_id=${manufacturer_id.toString()}&texture_id=${textures[i].toString()}&selected_texture=${maps[j].toString()}";
            FileUtils.mkdir([dirloc]); // Создание папки
            await dio.download(DownloadUrl, map_path.toString(),
                onReceiveProgress: (receivedBytes, totalBytes) {
              var progress_download_map =
                  "${((receivedBytes / totalBytes) * 100).toStringAsFixed(0)}%";
              print(progress_download_map);
              percentMapLoading = progress_download_map;
              Loading.setPercentMapLoading();
            });
          } catch (e) {
            print(e);
          }
        }
        countMapLoading = (j + 1).toString();
        Loading.setCountMapLoading();
      }
      countTextureLoading = (i + 1).toString();
      Loading.setCountTextureLoading();
    }
    print('installed');
    stateLoading = 1;
    addModel(model_path);
  }

  void checkMap(String map_name, manufacturer_id, textures_selected) async {
    maps.add(
        '${dirloc}/files/${manufacturer_id.toString()}/models/textures/${textures_selected.toString()}/${map_name}');
  } // Только в состоянии

  void initPosition() async {
    var screenHeight =
        (window.physicalSize.longestSide / window.devicePixelRatio);
    position = Offset(0, screenHeight - 80 - screenHeight * 0.1);
  } // Только в состоянии

  void initAddButton() async {
    var jsoncart = '{"id": "' +
        idPostUnityModel.toString() +
        '", "count": "1", "Material": "' +
        idTextureUnityModel.toString() +
        '" }'; // Генерируется json
    var jsoncartv2 =
        '{"id": "${idPostUnityModel.toString()}", "count": "1", "Material": "${idTextureUnityModel.toString()}" }'; // Генерируется json
    // todo: проверить роботоспособность варианта 2, если работает оставить его
    var objectToCart = jsonDecode(
        jsoncart); // Объект товара который будет добавлятся в корзину
    var object = Map<String, dynamic>.from(this.cartInfo); // Объект корзины
    for (int i = 0; i < object.keys.length; i++) {
      if (cartInfo[object.keys.elementAt(i)]['id'] == objectToCart['id']) {
        setState(() {
          inCart = true;
        });
        return;
      } // если товар уже добавлен при повторном обращении он убирается и корзина сохраняется
    }
    setState(() {
      inCart = false;
    });
  } // Инициализация кнопки добавления товара в корзину

  void initCartInfo() async {
    dirloc = await getPath();
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('cart_info').toString() != 'null') {
      cartInfo =
          jsonDecode(prefs.getString('cart_info')!); // Объект корзины в памяти
      print(cartInfo.toString());
    } else {
      prefs.setString('cart_info', '{}');
      cartInfo = jsonDecode('{}');
    }
    initAddButton();
  }

  void updateCartInfo() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('cart_info', jsonEncode(cartInfo));
  }

  void onUnityCreated(controller) {
    unityWidgetController = controller;
    unityWidgetController.postMessage('_FlutterMessageHandler', 'StartAR', '');
    this._unityWidgetController = controller;
    this._unityWidgetController.pause();
    this._unityWidgetController.resume();
    // Пауза и запуск, нужны для решения бага
  }

  void onUnityMessage(message) {
    if (message == 'ar_model_loaded') {
      indexUnityPageLayer = 1;
      widget.setStatePosts();
      setTexture();
      BlindController.setTexture();
      resetLoadingStats();
    }
    else {
      print(jsonDecode(message)['percentLoading']);
      percentLoadingMemoryModel = jsonDecode(message)['percentLoading'];
      Loading.setPercentLoadingMemoryModel();
    }
  }

  void addModel(path) {
    unityWidgetController.postMessage(
        '_FlutterMessageHandler', 'LoadModel', path);
    print('Модель загружена');
  }

  Future<void> setTexture() async {
    Future.delayed(Duration(seconds: 0)).then((value) => unityWidgetController
        .postMessage('_FlutterMessageHandler', 'LoadTexture', maps.join(", ")));
  }

  // EXAMPLE: LoadTexture("baseColorPath, normalMapPath, heightMapPath, MetallicGlossMap, OcclusionMapPath, EmissionMapPath, GlossinessMapPath")

  @override
  Widget build(BuildContext context) {
    var blockSwipe = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.bottom -
        30;
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/animation/loader.gif",
              height: 200.0,
              width: 200.0,
            ),
          ],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: arniturabottomNavBar(currentIndex: -1),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              color: Colors.black,
              child: UnityScreen,
            ),
            Positioned(
              top: position.dy - 50,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  setState(() {
                    if (blockSwipe >= details.globalPosition.dy + 50 &&
                        details.globalPosition.dy >=
                            details.globalPosition.dy +
                                50 +
                                (MediaQuery.of(context).size.width / 3) *
                                    (countBlind ~/ 3)) {
                      position = Offset(0, details.globalPosition.dy);
                    }
                  });
                  // print(details.globalPosition);
                },
                child: blind,
              ),
            ),
            Positioned(
              right: 20,
              bottom: 70,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                    icon:
                        inCart == false ? Icon(Icons.add) : Icon(Icons.remove),
                    onPressed: () {
                      var jsoncart = '{"id": "' +
                          idPostUnityModel.toString() +
                          '", "count": "1", "Material": "' +
                          idTextureUnityModel.toString() +
                          '" }'; // Генерируется json
                      var objectToCart = jsonDecode(
                          jsoncart); // Объект товара который будет добавлятся в корзину
                      var object =
                          Map<String, dynamic>.from(cartInfo); // Объект корзины
                      for (int i = 0; i < object.keys.length; i++) {
                        if (cartInfo[object.keys.elementAt(i)]['id'] ==
                            objectToCart['id']) {
                          object.remove(object.keys.elementAt(i));
                          cartInfo = jsonDecode(JsonEncoder().convert(object));
                          setState(() {
                            inCart = false;
                          });
                          updateCartInfo();
                          return;
                        } // если товар уже добавлен при повторном обращении он убирается и корзина сохраняется
                      } // В другом случае товар добавляется в корзину
                      var index = Map<String, dynamic>.from(cartInfo)
                                  .keys
                                  .length ==
                              0
                          ? '0'
                          : (int.parse(Map<String, dynamic>.from(cartInfo)
                                      .keys
                                      .last) +
                                  1)
                              .toString(); // Получение последнего индекса в словаре
                      this.cartInfo[index] =
                          objectToCart; // Добавение товара в корзину
                      setState(() {
                        inCart = true;
                      });
                      print(this.cartInfo.toString());
                      updateCartInfo();
                    },
                    splashRadius: 1,
                    color: Colors.black,
                    splashColor: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlindWidget extends StatefulWidget {
  final String id_texture;
  final String id_post;
  final BlindWidgetController controller;

  BlindWidget(
      {required this.id_texture,
      required this.id_post,
      required this.controller});

  @override
  BlindWidgetState createState() => BlindWidgetState(controller);
}

class BlindWidgetState extends State<BlindWidget> {
  var textures = idTextureUnityModel.split(', ');
  var clearBlind = Expanded(
    child: Container(color: Colors.grey),
    flex: 1,
  );

  BlindWidgetState(BlindWidgetController _controller) {
    _controller.setTexture = setTexture;
  }

  @override
  void initState() {
    super.initState();
    calculateBlindCount();
  }

  void calculateBlindCount() {
    if (idTextureUnityModel != 'None') {
      if (0 < textures.length && textures.length < 3) {
        countBlind = 1;
      } else if (textures.length % 3 == 0 || textures.length % 3 == 1) {
        countBlind = (textures.length ~/ 3) + 1;
      } else {
        countBlind = textures.length;
      }
    }
  }

  void setTexture() {
    setState(() {
      textures = idTextureUnityModel.split(', ');
      calculateBlindCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 140,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: countBlind,
        itemBuilder: (BuildContext buildContext, int index) {
          return Row(children: [
            index * 3 < textures.length
                ? Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: Image.network(
                          '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3)]).toString()}',
                          fit: BoxFit.fitWidth),
                    ),
                  )
                : clearBlind,
            (index * 3) + 1 < textures.length
                ? Container(color: Colors.black, width: 1, height: 125)
                : SizedBox(width: 1),
            (index * 3) + 1 < textures.length
                ? Expanded(
                    child: GestureDetector(
                    onTap: () {},
                    child: Image.network(
                        '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3) + 1]).toString()}',
                        fit: BoxFit.fitWidth),
                  ))
                : clearBlind,
            (index * 3) + 2 < textures.length
                ? Container(color: Colors.black, width: 1, height: 125)
                : SizedBox(width: 1),
            (index * 3) + 2 < textures.length
                ? Expanded(
                    child: Image.network(
                        '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3) + 2]).toString()}',
                        fit: BoxFit.fitWidth))
                : clearBlind
          ]);
        },
      ),
    );
  }
}

class BlindWidgetController {
  late void Function() setTexture;
}

class MainWidgetController {
  late void Function() setStatePosts;
}

class LoadingWidgetController {
  late void Function() setPercentModelLoading;
}
