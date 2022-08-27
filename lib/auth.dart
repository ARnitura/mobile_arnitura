import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  Future<int> isAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final int? counter = prefs.getInt('stateAuth');
    if (counter == 0) {
      prefs.setInt('stateAuth', 0);
      return 0;
    } // Вывести окно регистрации
    else if (counter == 1) {
      return 1;
    } // Вернуть 1
    return 0;
  } // Проверка авторизирован пользователь или нет
}
