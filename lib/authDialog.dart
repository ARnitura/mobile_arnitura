import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arnituramobile/globals.dart';

class authDialog extends StatefulWidget {
  final VoidCallback setStatePosts;

  authDialog({Key? key, required this.setStatePosts}) : super(key: key);

  @override
  State<authDialog> createState() => _authDialogState();
}

class _authDialogState extends State<authDialog> {
  var isRemember = false;
  var loginController = TextEditingController();
  var passwordController = TextEditingController();
  var errorText = null;

  void sign(context) async {
    var url = Uri.parse(url_server + '/api/auth_user');
    var res = await post(url, body: {
      'login': loginController.text,
      'password': passwordController.text
    });
    if (res.statusCode == 400) {
      setError();
    } else if (res.statusCode == 200) {
      var prefs = await SharedPreferences.getInstance();
      var object_user = jsonDecode(res.body)['0'];
      prefs.setString('id', object_user['id'].toString());
      prefs.setString('firstname', object_user['firstname'].toString());
      prefs.setString('lastname', object_user['lastname'].toString());
      prefs.setString('patronymic', object_user['patronymic'].toString());
      prefs.setString('avatar', object_user['firstname'].toString());
      prefs.setString('phone', object_user['phone'].toString());
      prefs.setString('mail', object_user['mail'].toString());
      prefs.setString('address', object_user['address'].toString());
      prefs.setString('login', object_user['login'].toString());
      prefs.setString(
          'list_favourites', object_user['list_favourites'].toString());
      prefs.setString('list_orders', object_user['list_orders'].toString());
      prefs.setInt('stateAuth', 1);
      print(object_user.toString());
      Navigator.pop(context);
      widget.setStatePosts();
    } // Если пользователь ввел правильные данные то сохраняем его данные и меняем состояние stateAuth, а так же изменяем состояние ленты
  }

  void setError() {
    setState(() {
      errorText = 'Логин или пароль неверны';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          child: Column(children: [
        Column(
          children: [
            Text('Логин'),
            SizedBox(height: 6),
            TextField(
                controller: loginController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12))
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(height: 10),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Пароль'),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (alertContext) => recoveryDialog(),
                    );
                  }, // => Navigator.pop(context),
                  child: Text('Забыли пароль?',
                      style: TextStyle(fontSize: 14, color: Color(0xff4094D0))),
                )
              ],
            ),
            SizedBox(height: 6),
            TextField(
                controller: passwordController,
                onChanged: (text) {
                  if (errorText != null) {
                    setState(() {
                      errorText = null;
                    });
                  }
                },
                decoration: InputDecoration(
                    errorText: errorText,
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                obscureText: true,
                style: TextStyle(fontSize: 12))
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              child: Checkbox(
                  onChanged: (bool? value) {
                    setState(() {
                      this.isRemember = value!;
                    });
                  },
                  value: this.isRemember),
              width: 20,
              height: 30,
            ),
            SizedBox(width: 10),
            Text('Запомнить меня')
          ],
        ),
        SizedBox(height: 20),
        OutlinedButton(
          onPressed: () {
            sign(context);
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text('Войти',
                style: TextStyle(
                    color: Color(0xff202020),
                    fontSize: 20,
                    fontWeight: FontWeight.w400)),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white, width: 0),
            backgroundColor: Color(0xffEDEDED),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (alertContext) => regDialog(),
            );
          },
          child: Text('Зарегистрироваться',
              style: TextStyle(fontSize: 14, color: Color(0xff4094D0))),
        )
      ], mainAxisSize: MainAxisSize.min)),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}

class recoveryDialog extends StatefulWidget {
  recoveryDialog({Key? key}) : super(key: key);

  @override
  State<recoveryDialog> createState() => _recoveryDialogState();
}

class _recoveryDialogState extends State<recoveryDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          child: Column(children: [
        Column(
          children: [
            Text('Восстановление пароля'),
            SizedBox(height: 6),
            Text('Чтобы восстановить пароль введите адрес электронной почты.',
                style: TextStyle(fontSize: 14, color: Color(0xff83868B)))
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(height: 20),
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('E-mail', style: TextStyle(color: Color(0xff83868B))),
              ],
            ),
            SizedBox(height: 6),
            TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12))
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (alertContext) => mailDialog(),
            );
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text('Восстановить пароль',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400)),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white, width: 0),
            backgroundColor: Color(0xff4094D0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50))),
          ),
        ),
        SizedBox(height: 10),
        Text('Назад', style: TextStyle(fontSize: 14, color: Color(0xff4094D0)))
      ], mainAxisSize: MainAxisSize.min)),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}

class mailDialog extends StatefulWidget {
  mailDialog({Key? key}) : super(key: key);

  @override
  State<mailDialog> createState() => _mailDialogState();
}

class _mailDialogState extends State<mailDialog> {
  late Timer _timer;
  int _start = 1;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (alertContext) => newPasswordDialog(),
            );
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          child: Column(children: [
        SizedBox(height: 40),
        Image.asset(
          'assets/image/mail_message.png',
          width: 80,
        ),
        Column(
          children: [
            Text('Проверьте почту', style: TextStyle(fontSize: 20)),
            SizedBox(height: 6),
            Text(
                'На указанный email отправлено письмо с инструкцией по смене пароля.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xff83868B)))
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        SizedBox(height: 20),
        Column(
          children: [
            Text(
                'Не получили письмо? Проверьте папку “спам” или введите другой адрес электронной почты',
                style: TextStyle(color: Color(0xff83868B), fontSize: 13)),
            SizedBox(height: 6),
          ],
        ),
        SizedBox(height: 10),
      ], mainAxisSize: MainAxisSize.min)),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}

class newPasswordDialog extends StatefulWidget {
  newPasswordDialog({Key? key}) : super(key: key);

  @override
  State<newPasswordDialog> createState() => _newPasswordDialogState();
}

class _newPasswordDialogState extends State<newPasswordDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Создание нового пароля'),
                SizedBox(height: 10),
                Text('Новый пароль должен отличаться от предыдущего.',
                    style: TextStyle(fontSize: 14, color: Color(0xff83868B))),
                SizedBox(height: 20),
                Text('Пароль'),
                SizedBox(height: 5),
                TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                    obscureText: true,
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 10),
                Text('Подтвердить пароль'),
                SizedBox(height: 5),
                TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                    style: TextStyle(fontSize: 12)),
                SizedBox(height: 30),
                OutlinedButton(
                  onPressed: () async {},
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('Войти',
                        style: TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 20,
                            fontWeight: FontWeight.w400)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 0),
                    backgroundColor: Color(0xff4094D0),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                  ),
                )
              ],
              mainAxisSize: MainAxisSize.min)),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}

class regDialog extends StatefulWidget {
  regDialog({Key? key}) : super(key: key);

  @override
  State<regDialog> createState() => _regDialogState();
}

class _regDialogState extends State<regDialog> {
  var lastnameController = TextEditingController();
  var firstnameController = TextEditingController();
  var patronymicController = TextEditingController();
  var loginController = TextEditingController();
  var passwordController = TextEditingController();
  var emailController = TextEditingController();
  var numberController = TextEditingController();
  var phoneController = TextEditingController();
  var addressController = TextEditingController();
  var loginErrorText = null;
  var passwordErrorText = null;

  bool validation() {
    var login = loginController.text;
    var password = passwordController.text;
    if (login.length == 0) {
      setState(() {
        loginErrorText = 'Поле не может быть пустым';
      });
      return false;
    }
    if (password.length < 8) {
      setState(() {
        passwordErrorText = 'Пароль должен содержать больше 8 символов';
      });
      return false;
    }

    for (int i = 0; i < login.length; i++) {
      if ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_.'
              .contains(login[i]) ==
          false) {
        return false;
      }
      ;
    }
    ;
    for (int i = 0; i < password.length; i++) {
      if ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_.'
              .contains(password[i]) ==
          false) {
        return false;
      }
      ;
    }
    ;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: SingleChildScrollView(
        child: Container(
            child: Column(
          children: [
            Text('Фамилия', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: lastnameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Имя', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: firstnameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Отчество', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: patronymicController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Логин', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: loginController,
                onChanged: ((text) {
                  loginErrorText = null;
                }),
                decoration: InputDecoration(
                    errorText: loginErrorText,
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Пароль', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: passwordController,
                onChanged: ((text) {
                  setState(() {
                    passwordErrorText = null;
                  });
                }),
                decoration: InputDecoration(
                    errorText: passwordErrorText,
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                obscureText: true,
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('E-mail', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Телефон', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: phoneController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            Text('Адрес', style: TextStyle(color: Color(0xff83868B))),
            SizedBox(height: 6),
            TextField(
                controller: addressController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 8)),
                style: TextStyle(fontSize: 12)),
            SizedBox(height: 20),
            OutlinedButton(
              onPressed: () async {
                if (validation()) {
                  var url = Uri.parse(url_server + '/api/reg_user');
                  var res = await post(url, body: {
                    'firstname': firstnameController.text,
                    'lastname': lastnameController.text,
                    'patronymic': patronymicController.text,
                    'login': loginController.text,
                    'password': passwordController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'address': addressController.text
                  });
                  if (jsonDecode(res.body)['description'] == 'success') {
                    var prefs = await SharedPreferences.getInstance();
                    prefs.setInt('stateAuth', 1);
                    prefs.setString('id', jsonDecode(res.body)['id'].toString());
                    prefs.setString('firstname', firstnameController.text);
                    prefs.setString('lastname', lastnameController.text);
                    prefs.setString('patronymic', patronymicController.text);
                    prefs.setString('phone', phoneController.text);
                    prefs.setString('mail', emailController.text);
                    prefs.setString('address', addressController.text);
                    prefs.setString('login', loginController.text);
                    prefs.setString('list_favourites', '');
                    prefs.setString('list_orders', '');
                    Navigator.pop(context);
                  }
                  ;
                }
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text('Зарегистрироваться',
                    style: TextStyle(
                        color: Color(0xff202020),
                        fontSize: 20,
                        fontWeight: FontWeight.w400)),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white, width: 0),
                backgroundColor: Color(0xffEDEDED),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50))),
              ),
            ),
            Row(
              children: [
                Text('Уже зарегистрированы? '),
                Text(
                  'Войти',
                  style: TextStyle(color: Color(0xff4094D0)),
                )
              ],
            )
          ],
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        )),
      ),
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(15))),
    );
  }
}
