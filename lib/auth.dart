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

  Future<dynamic> exit(setStatePosts) async {
      var prefs = await SharedPreferences.getInstance();
      prefs.remove('id');
      prefs.remove('firstname');
      prefs.remove('lastname');
      prefs.remove('patronymic');
      prefs.remove('avatar');
      prefs.remove('phone');
      prefs.remove('mail');
      prefs.remove('address');
      prefs.remove('login');
      prefs.remove(
          'list_favourites');
      prefs.remove('list_orders');
      prefs.setInt('stateAuth', 0);
      setStatePosts();
    } // Если пользователь ввел правильные данные то сохраняем его данные и меняем состояние stateAuth, а так же изменяем состояние ленты
  }
