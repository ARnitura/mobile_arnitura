import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading/loading.dart';
import 'dart:async';
import 'globals.dart';
import 'main.dart';

class FScreen extends StatefulWidget {
  const FScreen({Key? key}) : super(key: key);

  @override
  _FScreenState createState() => _FScreenState();
}

class _FScreenState extends State<FScreen> {
  @override
  void initState() {
    super.initState();
    asyncLoad();
  }

  Future<String> getPosts() async {
    var url = Uri.parse(url_server + '/api/get_posts');
    var response = await post(url);
    return response.body;
  }

  void asyncLoad() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('stateAuth'); // TODO: это что? проверить назначение переменной stateAuth
    final int? counter = prefs.getInt('stateAuth');
    if (counter == null) {
      prefs.setInt('stateAuth', 0);

      prefs.remove('id');
      prefs.remove('firstname');
      prefs.remove('lastname');
      prefs.remove('patronymic');
      prefs.remove('avatar');
      prefs.remove('phone');
      prefs.remove('mail');
      prefs.remove('address');
      prefs.remove('login');
      prefs.remove('list_favourites');
      prefs.remove('list_orders');

      print(prefs.getKeys());
    } // Удаляется вся возможная информация о пользователе
    else if (counter == 1) {
      // TODO: Реализовать подтягивание информации пользователя в память телефона, не нужно запоминать состояние stateAuth

    } // Если пользователь авторизован то в память тянем информация в ЛК,
    // Если нет то меняем состояние переменной stateAuth
    // 0 - Не авторизирован; 1 - авторизирован.
    var posts_info = await getPosts();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyApp(data: posts_info)));
  } // Загрузка данных пользователя на экране загрузки

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/image/logo.png', width: 350),
            const SizedBox(width: 10, height: 10),
            const Text(
              'v2.0',
              style: TextStyle(color: Color(0xFFC4C4C4), fontSize: 20.8, fontWeight: FontWeight.w200),
            ),
            Expanded(child: Container()), // todo: попробуй удали контейнеры внутри expanded
            Loading(
              indicator: BallSpinFadeLoaderIndicator(),
              size: 50,
              color: Color(0xFF4094D0),
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }
}
