import 'package:flutter/material.dart';

import 'globals.dart';

class LoadingWidget extends StatefulWidget {
  LoadingWidget();

  @override
  LoadingWidgetState createState() => LoadingWidgetState(LoadingController);
}

class LoadingWidgetState extends State<LoadingWidget> {
  LoadingWidgetState(LoadingPageController _controller) {
    _controller.setPercentModelLoading = setPercentModelLoading;
    _controller.setPercentMapLoading = setPercentMapLoading;
    _controller.setCountMaxTexture = setCountMaxTexture;
    _controller.setCountMaxMap = setCountMaxMap;
    _controller.setCountMapLoading = setCountMapLoading;
    _controller.setCountTextureLoading = setCountTextureLoading;
    _controller.setPercentLoadingMemoryModel = setPercentLoadingMemoryModel;
  }

  void setPercentModelLoading() {
    setState(() {
      percentModelLoading = percentModelLoading;
    });
  }

  void setPercentMapLoading() {
    setState(() {
      percentMapLoading = percentMapLoading;
    });
  }

  void setCountMaxTexture() {
    setState(() {
      countMaxTexture = countMaxTexture;
    });
  }

  void setCountMaxMap() {
    setState(() {
      countMaxMap = countMaxMap;
    });
  }

  void setCountMapLoading() {
    setState(() {
      countMapLoading = countMapLoading;
    });
  }

  void setCountTextureLoading() {
    setState(() {
      countTextureLoading = countTextureLoading;
    });
  }

  void setStateScreen() {
    setState(() {});
  }

  void setPercentLoadingMemoryModel() {
    setState(() {
      percentLoadingMemoryModel = percentLoadingMemoryModel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: stateLoading == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Скачивание модели - ' + percentModelLoading),
                  Text('Скачивание текстуры - ' +
                      countTextureLoading +
                      ' / ' +
                      countMaxTexture),
                  Text('Скачивание карты - ' +
                      countMapLoading +
                      ' / ' +
                      countMaxMap),
                  Text('Скачалось: ' + percentMapLoading),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Загрузка модели в память - ' + percentLoadingMemoryModel.toString()),
                ],
              ));
  }
}

class LoadingPageController {
  late void Function() setPercentModelLoading;
  late void Function() setPercentMapLoading;
  late void Function() setCountMaxTexture;
  late void Function() setCountMaxMap;
  late void Function() setCountMapLoading;
  late void Function() setCountTextureLoading;
  late void Function() setPercentLoadingMemoryModel;
}
