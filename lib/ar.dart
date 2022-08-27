import 'dart:convert';
import 'dart:io';
import 'dart:ui';

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

  ArWidget({
    Key? key,
    required this.id_texture,
    required this.id_post,
  }) : super(key: key);

  final ArWidgetState myAppState=new ArWidgetState();
  @override
  ArWidgetState createState() => ArWidgetState();

  void getPath(){
    myAppState.getPath();
  }

  void downloadModel(id_post) {
    myAppState.downloadModel(id_post);
  }

  void downloadTextureToModel() {
    downloadTextureToModel();
  }
}

class ArWidgetState extends State<ArWidget> {
  var cartInfo;
  var inCart = true;

  var progress_download = "0";
  var downloaded_texture = '';
  var max_textures = '';
  var downloaded_maps = '';
  var max_maps = '';
  var model_path = "No Data";

  late UnityWidgetController _unityWidgetController;
  late BlindWidget blind;
  late UnityWidget UnityScreen;

  Dio dio = Dio();

  @override
  Future<void> deactivate() async {
    super.deactivate();
    print('cleararerr');
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
        enablePlaceholder: false, fullscreen: false);
    this.blind = BlindWidget(
        id_texture: idTextureUnityModel,
        id_post: idPostUnityModel,
        lockBlindPosition: LockBlindPosition);
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

  Future<void> downloadModel(id_post) async {
    var res = await post(Uri.parse('${url_server}/api/get_info_post'),
        body: {'id_post': id_post}); // Получаем информацию о посте
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
          // // setState(() {
            progress_download =
                "${((receivedBytes / totalBytes) * 100).toStringAsFixed(0)}%";
            print(progress_download);
          });
        // });
      // } catch (e) {
      //   print(e);
      // }
      // setState(() {
        progress_download = "Complete - 100%";
      // });
    }
    downloadTextureToModel();
    this.model_path = model_path;
  }

  Future<void> downloadTextureToModel() async {
    var textures = idTextureUnityModel.split(', ');
    var res = await post(Uri.parse('${url_server}/api/get_info_post'),
        body: {'id_post': idPostUnityModel}); // Получаем информацию о посте
    var manufacturer_id = jsonDecode(res.body)['0']['manufacturer_id'];
    max_textures = textures.length.toString(); // Количество текстур
    for (int i = 0; i < textures.length; i++) {
      var texture_info =
          await post(Uri.parse('${url_server}/api/maps_info'), body: {
        'id_texture': idTextureUnityModel.split(', ')[i].toString(),
        'id_manufacturer': manufacturer_id.toString()
      }); // Получаем список карт для модели
      var maps = jsonDecode(texture_info.body)['maps'].split(', ');
      max_maps = maps.length.toString(); // Количество карт в этой текстуре
      print(textures[i]);
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
            });
          } catch (e) {
            print(e);
          }
        }
          downloaded_maps = (j + 1).toString();
      }
        downloaded_texture = (i + 1).toString();
    }
    print('installed');
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
    print('11221');
    unityWidgetController = controller;
    unityWidgetController
        .postMessage('_FlutterMessageHandler', 'StartAR', '');
    this._unityWidgetController = controller;
    this._unityWidgetController.pause();
    this._unityWidgetController.resume();
    if (idPostUnityModel != 'None') {
      downloadModel(idPostUnityModel);
    }
    // Пауза и запуск, нужны для решения бага
  }

  void onUnityMessage(message) {
    if (message == 'ar_model_loaded') {
      setTexture();
    }
  }

  // todo: На данный момент никак не регулируется разделение потока данных
  // по этому если приходит любое сообщение из юнити сразу назначается текстура

  void LockBlindPosition() async {
    setState(() {
      position = Offset(0, MediaQuery.of(context).size.height - 200);
    });
  }

  void addModel(path) {
    unityWidgetController.postMessage(
      '_FlutterMessageHandler',
      'LoadModel',
      path,
    );
    print('Модель загружена');
  }

  Future<void> setTexture() async {
    Future.delayed(Duration(seconds: 5)).then((value) => unityWidgetController.postMessage(
        '_FlutterMessageHandler', 'LoadTexture', maps.join(", ")));
  }

  // EXAMPLE: LoadTexture("baseColorPath, normalMapPath, heightMapPath, MetallicGlossMap, OcclusionMapPath, EmissionMapPath, GlossinessMapPath")

  @override
  Widget build(BuildContext context) {
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
            Text("Model: ${progress_download}%/100%",
                style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontSize: 30)),
            Text(
              "Textures: ${downloaded_texture}/${max_textures}",
              style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 30),
            ),
            Text(
              "Maps: ${downloaded_maps}/${max_maps}",
              style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 30),
            ),
          ],
        ),
      ),
      child: Scaffold(
        bottomNavigationBar: arniturabottomNavBar(currentIndex: -1),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                color: Colors.black,
                child: UnityScreen,
              ),
              Positioned(
                top: position.dy,
                child: GestureDetector(
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
                    setState(() {
                      if (details.globalPosition.dy >= 400) {
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
                      icon: inCart == false
                          ? Icon(Icons.add)
                          : Icon(Icons.remove),
                      onPressed: () {
                        var jsoncart = '{"id": "' +
                            idPostUnityModel.toString() +
                            '", "count": "1", "Material": "' +
                            idTextureUnityModel.toString() +
                            '" }'; // Генерируется json
                        var objectToCart = jsonDecode(
                            jsoncart); // Объект товара который будет добавлятся в корзину
                        var object = Map<String, dynamic>.from(
                            cartInfo); // Объект корзины
                        for (int i = 0; i < object.keys.length; i++) {
                          if (cartInfo[object.keys.elementAt(i)]['id'] ==
                              objectToCart['id']) {
                            object.remove(object.keys.elementAt(i));
                            cartInfo =
                                jsonDecode(JsonEncoder().convert(object));
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
      ),
    );
  }
}

class BlindWidget extends StatefulWidget {
  final String id_texture;
  final String id_post;
  final VoidCallback lockBlindPosition;

  BlindWidget(
      {Key? key,
      required this.id_texture,
      required this.id_post,
      required this.lockBlindPosition})
      : super(key: key);

  @override
  _BlindWidgetState createState() => _BlindWidgetState();
}

class _BlindWidgetState extends State<BlindWidget> {
  var countBlind = 0;
  var textures;

  @override
  void initState() {
    super.initState();
    if (idTextureUnityModel != 'None') {
      idTextureUnityModel = idTextureUnityModel.split(', ');
      if (0 < textures.length && textures.length < 3) {
        countBlind = 1;
      } else if (textures.length % 3 == 0 || textures.length % 3 == 1) {
        countBlind = (textures.length ~/ 3) + 1;
      } else {
        countBlind = textures.length;
      }
    }
  }

  void myFunction(){
    print('hello dart');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 300,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: countBlind,
        itemBuilder: (BuildContext buildContext, int index) {
          return Row(children: [
            // Container(color: Colors.black, width: 100, height: 100)
            index * 3 < textures.length
                ? Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: Image.network(
                          '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3)]).toString()}',
                          fit: BoxFit.fitWidth),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                  ),
            Container(color: Colors.black, width: 10, height: double.infinity),
            (index * 3) + 1 < textures.length
                ? Expanded(
                    child: Image.network(
                        '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3) + 1]).toString()}',
                        fit: BoxFit.fitWidth))
                : Container(width: 100, height: 100),
            (index * 3) + 2 < textures.length
                ? Expanded(
                    child: Image.network(
                        '${url_server}/api/get_photo_texture?post_id=${idPostUnityModel}&texture_id=${(textures[(index * 3) + 2]).toString()}',
                        fit: BoxFit.fitWidth))
                : Container(
                    width: 100,
                    height: 100,
                  )
          ]);
        },
      ),
    );
  }
}
