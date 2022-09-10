import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arnituramobile/main.dart';
import 'package:arnituramobile/shopping_cart.dart';
import 'package:arnituramobile/globals.dart';

class arniturabottomNavBar extends StatefulWidget {
  var currentIndex = 0;
  arniturabottomNavBar({required this.currentIndex});

  @override
  State<arniturabottomNavBar> createState() => arniturabottomNavBarState();
}

class arniturabottomNavBarState extends State<arniturabottomNavBar> {
  var prefs;

  @override
  void initState() {
    initShared();
    super.initState();
  }

  void initShared() async {
    prefs = await SharedPreferences.getInstance(); // Получаю значение в памяти
    await prefs.remove('navbarCount');
    final int? counter = prefs.getString('navbarCount'); // Получаю индекс раздела navbar на данный момент
    if (counter == null) {
      await prefs.setString('navbarCount', widget.currentIndex.toString());
    } // сначала проверяю что значение не равно null
    else if (counter != widget.currentIndex) {
      await prefs.setString('navbarCount', widget.currentIndex.toString());
      setState(() {
      });
    }  // Проверяю если экран пришедший не равен экрану действительному то меняю состояния и перевожу экран
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
        IconButton(
          icon: Image.asset('assets/image/home_icon.png',
              width: 35,
              color:
                  widget.currentIndex == 0 ? Color(0xff4094D0) : Colors.black),
          onPressed: () {
            if (widget.currentIndex != 0) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp(data: 'null')));
            }
            setState(() {
              indexUnityPageLayer = 0;
            });
          },
        ),
        // IconButton(
        //   icon: Image.asset('assets/image/search_icon.png',
        //       width: 35,
        //       color:
        //       widget.currentIndex == 1 ? Color(0xff4094D0) : Colors.black),
        //   onPressed: () {
        //     if (widget.currentIndex != 1) {
        //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Search()));
        //     }
        //     setState(() {
        //       widget.currentIndex = 1;
        //     });
        //   },
        // ),
        IconButton(
          icon: Image.asset('assets/image/shop_icon.png',
              width: 35,
              color:
              widget.currentIndex == 2 ? Color(0xff4094D0) : Colors.black),
          onPressed: () {
            if (widget.currentIndex != 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShopingWidget()));
            }
            setState(() {
              widget.currentIndex = 2;
            });
          },
        ),
      ]),
    );
  }
}
