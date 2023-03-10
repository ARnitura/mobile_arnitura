import 'package:arnituramobile/loadingModels.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

var percentModelLoading = "0%"; // Скачано процентов модели
var countTextureLoading = "0"; // Номер скачивающейся текстуры
var countMaxTexture = "0"; // Номер скачивающейся карты
var countMaxMap = "0"; // Максимальное количество карт в текстуре
var countMapLoading = "0"; // Скачано карт
var percentMapLoading = "0%"; // Процент скачивания карты
var countBlind = 0;
var percentLoadingMemoryModel = 0; // Процент загрузки модели в память
var stateLoading = 0;

late StateSetter internalSetter;
var list_to_buy = {}; // TODO: убрать это ненужный словарь

resetLoadingStats() {
  percentModelLoading = "0%";
  countTextureLoading = "0";
  countMaxTexture = "0";
  countMaxMap = "0";
  countMapLoading = "0";
  percentMapLoading = "0%";
  percentLoadingMemoryModel = 0;
}


LoadingPageController LoadingController = LoadingPageController();
final ArWidgetController ArController = ArWidgetController();
var url_server = 'https://api.arnitura.ru';
var indexUnityPageLayer = 0;
dynamic idTextureUnityModel = 'None';
var idPost = '';
var idPostUnityModel = 'None';
late UnityWidgetController unityWidgetController;
String dirloc = "";
var maps = [];
var materials = [];


class ArWidgetController {
  late void Function() downloadModel;
  late void Function() downloadTextureToModel;
}

class MainWidgetController {
  late void Function() setStatePosts;
}