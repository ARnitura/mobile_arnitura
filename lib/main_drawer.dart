import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:arnituramobile/globals.dart';
import 'package:arnituramobile/privacy_policy.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_network/image_network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'authDialog.dart';
import 'privacy_policy.dart';
import 'offert.dart';
import 'support.dart';
import 'contact.dart';

class DrawerKreslo extends StatefulWidget {
  final setStatePosts;

  // Виджет выдвегающегося меню

  DrawerKreslo({Key? key, this.setStatePosts = null}) : super(key: key);

  @override
  State<DrawerKreslo> createState() => _DrawerKresloState();
}

class _DrawerKresloState extends State<DrawerKreslo> {
  var stateLKAuth = 0;
  var firstname = '';
  var lastname = '';
  var manufacturer_id = '';
  var id_user = '';
  var cacheImageKey = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
    print('init drawer');
  }

  void loadProfile() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
      stateLKAuth = 1;
      firstname = prefs.getString('firstname')!;
      lastname = prefs.getString('lastname')!;
      id_user = prefs.getString('id')!;
      cacheImageKey = prefs.getString('cacheImageKey')!;
    } else {
      stateLKAuth = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Color(0xff578FCE)),
            accountName: stateLKAuth == 0
                ? Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return authDialog(
                                      setStatePosts: widget.setStatePosts);
                                });
                          },
                          child: Text(
                            'Войти',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      Text(
                        'или',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w200),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return regDialog();
                                });
                          },
                          child: Text(
                            'зарегистрироваться',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  )
                : Row(
                    children: [Text(firstname + ' ' + lastname)],
                  ),
            currentAccountPicture: CircleAvatar(
              radius: 15,
              child: ClipOval(
                child: stateLKAuth == 0
                    ? Image.asset('assets/image/no_auth_avatar.png')
                    : ImageNetwork(
                    image: url_server +
                            '/api/get_photo_user_avatar?user_id=' +
                            id_user.toString(),
                        width: 300, fitAndroidIos: BoxFit.cover, height: 300,         imageCache: CachedNetworkImageProvider(url_server +
                    '/api/get_photo_user_avatar?user_id=' +
                    id_user.toString(), cacheKey: cacheImageKey),
                ),
              ),
            ),
            accountEmail: null,
          ),
          stateLKAuth == 1
              ? Card(
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 10, 00, 10),
                        child: const Text(
                          'Аккаунт',
                          style: TextStyle(
                              color: Color(0xFF4094D0),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      ListTile(
                        leading: Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Image.asset(
                            'assets/image/user_icon.png',
                            height: 30,
                          ),
                        ),
                        title: Container(
                            child: const Text(
                          "Контактные данные",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactWidget()));
                          // Переход на страницу с контактными данными
                        },
                      ),
                      // ListTile(
                      //   leading: Container(
                      //     padding: EdgeInsets.only(left: 5),
                      //     child: Image.asset(
                      //       'assets/image/bookmark_icon_drawer.png',
                      //       height: 30,
                      //     ),
                      //   ),
                      //   title: const Text(
                      //     "Избранное",
                      //     style: TextStyle(fontWeight: FontWeight.w600),
                      //   ),
                      //   onTap: () {
                      //     // Переход на страницу с избранным
                      //   },
                      // ),  Избранное
                    ],
                  ),
                )
              : SizedBox(width: 10),
          SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 00, 10),
                  child: const Text(
                    'Помощь',
                    style: TextStyle(
                        color: Color(0xFF4094D0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Image.asset(
                      'assets/image/faq_icon.png',
                      height: 30,
                    ),
                  ),
                  title: const Text(
                    "Техподдержка",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SupportWidget()));
                    // Переход на страницу с техподдержкой
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Image.asset(
                      'assets/image/shield_icon.png',
                      height: 30,
                    ),
                  ),
                  title: const Text(
                    "Политика конфиденциальности",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PolicyWidget())); //call to parent
                    });
                    // Переход на страницу с политикой конф.
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(left: 5),
                    child: Image.asset(
                      'assets/image/oferta_icon.png',
                      height: 30,
                    ),
                  ),
                  title: const Text(
                    "Правила оферты",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OffertWidget())); //call to parent
                    });
                  },
                  // Переход на страницу с правилами оферты
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                stateLKAuth == 1 ? ListTile(
                  leading: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: SvgPicture.asset('assets/image/exit.svg', height: 25),
                  ),
                  title: Container(
                      child: const Text(
                        "Выход",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )),
                  onTap: () {
                    Auth().exit(widget.setStatePosts);
                    Navigator.pop(context);
                  },
                ) : Container()
              ],
            ),
          )
          // ListTile(
          //   leading: Image.asset(
          //     'assets/image/settings_icon.png',
          //     height: 30,
          //   ),
          //   title: const Text("Настройки"),
          //   onTap: () {
          //     // Переход на страницу с настройками
          //   },
          // ),
        ],
      ),
    );
  }
}
