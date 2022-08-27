import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arnituramobile/bottomNavbar.dart';
import 'package:arnituramobile/globals.dart';
import 'package:arnituramobile/order.dart';
import 'main_drawer.dart';
import 'app_bar_drawer_list.dart';

class ShopingWidget extends StatefulWidget {
  ShopingWidget({
    Key? key,
  }) : super(key: key);

  @override
  _ShopingWidgetState createState() => _ShopingWidgetState();
}

class _ShopingWidgetState extends State<ShopingWidget> {
  List<bool> values = []; // Список чекбоксов
  var list_to_buy = {}; // TODO: убрать это ненужный словарь
  var countSelected = 0;
  var priceSelected = 0;
  var prices = [];

  @override
  void initState() {
    super.initState();
    initCartInfo();
    removeOrders();
  }

  void removeOrders() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.remove('list_orders');
  }

  void initCartInfo() async {
    var prefs = await SharedPreferences.getInstance();
    var objects = jsonDecode(prefs.getString('cart_info').toString());
    setState(() {
      list_to_buy = Map<String, dynamic>.from(objects);
      for (var i = 0; i < list_to_buy.length; i++) {
        values.add(false);
      }
    });
  } // Подтягиваем данные корзины, и меняем состояние корзины с пустой на заполненную;

  Future getCartInfo(id) async {
    var photos = '';
    var res = await post(Uri.parse(url_server + '/api/get_info_post'),
        body: {'id_post': id.toString()});

    print(jsonDecode(res.body)['0']['name_furniture'].toString());
    if (jsonDecode(res.body)['0']['avatar_furniture']
            .toString()
            .split(', ')
            .length !=
        0) {
      photos = jsonDecode(res.body)['0']['avatar_furniture']
          .toString()
          .split(', ')[0];
    } else {
      photos = jsonDecode(res.body)['0']['avatar_furniture'];
    }
    return {
      'name_furniture': jsonDecode(res.body)['0']['name_furniture'],
      'series_furniture': jsonDecode(res.body)['0']['series_furniture'],
      'material_name_furniture': jsonDecode(res.body)['0']
          ['material_name_furniture'],
      'width': jsonDecode(res.body)['0']['width'],
      'length': jsonDecode(res.body)['0']['length'],
      'height': jsonDecode(res.body)['0']['height'],
      'price_furniture': jsonDecode(res.body)['0']['price_furniture'],
      'manufacturer_id': jsonDecode(res.body)['0']['manufacturer_id'],
      'avatar_furniture': photos
    };
  }
  // Подтягивается информация о каждом товаре

  void setChoice(value, index) {
    if (values[index] == true) {
      values[index] = false;
    } else if (values[index] == false) {
      values[index] = true;
    }
    updateState();
  } // Меняется состояние чекбоксов и после меняется состояние в памяти

  void deleteCart(index) async {
    list_to_buy.remove(index.toString());
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('cart_info', jsonEncode(list_to_buy));
    setState(() {
    });
  }

  void updateState() async {
    initCartInfo();
    countSelected = 0;
    priceSelected = 0;
    var prefs = await SharedPreferences.getInstance();
    dynamic list_orders;
    if (prefs.getString('list_orders') == null) {
      list_orders = jsonDecode('{}');
    }
    else
      {
        list_orders = Map<String, dynamic>.from(jsonDecode(prefs.getString('list_orders')!));
      }
    for (var i = 0; i < list_to_buy.length; i++) {
      if (values[i]) {
        if (list_orders[i.toString()] == null) {
          list_orders[i.toString()] = list_to_buy[list_to_buy.keys.elementAt(i)];
        }
        countSelected +=
            int.parse(list_to_buy[list_to_buy.keys.elementAt(i)]['count']);
        priceSelected += int.parse(
                prices[i][prices[i].keys.elementAt(0)].round().toString()) *
            int.parse(list_to_buy[list_to_buy.keys.elementAt(i)]['count']);
      } // Когда чекбокс включается, меняется состояние цены, колва товаров,
      // а так же отслеживается в памяти отметка товаров
      else {
        if (list_orders[i.toString()] != null) {
          list_orders.remove(i.toString());
        }
      } // если товар не выбран то удаляется из памяти
    }
    prefs.setString('list_orders', jsonEncode(list_orders));
    setState(() {});
  } // Меняется состояние в памяти

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: arniturabottomNavBar(currentIndex: 2),
      drawer: DrawerKreslo(),
      appBar: AppBarDrawerList('Корзина'),
      body: Center(
        child: list_to_buy.length == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 100),
                  Image.asset('assets/image/cart.png', width: 100),
                  SizedBox(height: 20),
                  Text('Корзина пуста',
                      style: TextStyle(color: Color(0xff202020))),
                  SizedBox(height: 10),
                  Text(
                    'Выберите и добавьте товар в корзину',
                    style: TextStyle(color: Color(0xff83868B)),
                  )
                ],
              ) // Пустая корзина
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: list_to_buy.length,
                        itemBuilder: (BuildContext buildContext, int index) {
                          return FutureBuilder<dynamic>(
                            future: getCartInfo(int.parse(
                                list_to_buy[list_to_buy.keys.elementAt(index)]
                                    ['id'])),
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: Text('Please wait its loading...'));
                              } else {
                                if (snapshot.hasError)
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                else if (prices.length != 0) {
                                  prices.add({
                                    (int.parse(prices.last.keys.last) + 1)
                                            .toString():
                                        snapshot.data['price_furniture']
                                  });
                                } else {
                                  prices.add(
                                      {'1': snapshot.data['price_furniture']});
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Container(
                                    //   margin: EdgeInsets.only(left: 40, top: 10),
                                    //   child: Text('Мебельный дом «Тэйбл»',
                                    //       style: TextStyle(
                                    //           color: Color(0xff4094D0),
                                    //           fontSize: 20,
                                    //           fontWeight: FontWeight.w600)),
                                    // ),
                                    Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Checkbox(
                                                value: values[index],
                                                onChanged: (value) {
                                                  setChoice(value, index);
                                                },
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                    url_server +
                                                        '/api/get_photos?id=' +
                                                        snapshot.data[
                                                                'manufacturer_id']
                                                            .toString() +
                                                        '&photo_name=' +
                                                        snapshot.data[
                                                                'avatar_furniture']
                                                            .toString(),
                                                    width: 100,
                                                    height: 80,
                                                    fit: BoxFit.contain),
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    snapshot
                                                        .data['name_furniture'],
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 18),
                                                  ),
                                                  Text(
                                                    snapshot.data[
                                                            'series_furniture'] +
                                                        ', ' +
                                                        snapshot.data[
                                                            'material_name_furniture'],
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff83868B),
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                    snapshot.data['width'] +
                                                        '*' +
                                                        snapshot
                                                            .data['length'] +
                                                        '*' +
                                                        snapshot.data['height'],
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff83868B),
                                                        fontWeight:
                                                            FontWeight.w400),
                                                  ),
                                                  Text(
                                                      snapshot.data[
                                                              'price_furniture']
                                                          .toInt().toString(), // Образаем копейки
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 22)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                              child: GestureDetector(
                                                child: Icon(
                                                  Icons.close,
                                                  color: Color(0xff4094D0),
                                                ),
                                                onTap: () {
                                                  deleteCart(index);
                                                }
                                              ),
                                              right: 20,
                                              top: 0),
                                        Positioned(
                                            child: CountWidget(
                                                count: int.parse(list_to_buy[
                                                        list_to_buy.keys
                                                            .elementAt(index)]
                                                    ['count']),
                                                index: index),
                                            right: 20,
                                            bottom: 5),
                                      ],
                                    ),
                                    SizedBox(height: 40),
                                  ],
                                );
                                // return Center(child: new Text('${snapshot.data}'));  // snapshot.data  :- get your object which is pass from your downloadData() function
                              }
                            },
                          );
                        }),
                  ),
                  Column(
                    children: [
                      Text(priceSelected.toString() + ' ₽',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 28)),
                      Text('Товаров выбрано: ' + countSelected.toString(),
                          style: TextStyle(
                              color: Color(0xff4094D0),
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: 40),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OrderWidget()));
                        },
                        child: Text('Перейти к оформлению',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w400)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xff4094D0),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}

class CountWidget extends StatefulWidget {
  int count;
  int index;

  CountWidget({Key? key, required this.count, required this.index})
      : super(key: key);

  @override
  _CountWidgetState createState() => _CountWidgetState();
}

class _CountWidgetState extends State<CountWidget> {
  var list_to_buy = {};

  @override
  void initState() {
    super.initState();
    getInfoCount();
  }

  void getInfoCount() async {
    var prefs = await SharedPreferences.getInstance();
    var objects = jsonDecode(prefs.getString('cart_info').toString());
    list_to_buy = Map<String, dynamic>.from(objects);
    setState(() {
      widget.count = int.parse(
          list_to_buy[list_to_buy.keys.elementAt(widget.index)]['count']);
    });
  }

  void saveInfoCount() async {
    var prefs = await SharedPreferences.getInstance();
    list_to_buy[list_to_buy.keys.elementAt(widget.index)]['count'] =
        widget.count.toString();
    prefs.setString('cart_info', jsonEncode(list_to_buy));
  }

  @override
  Widget build(BuildContext context) {
    getInfoCount();
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(0xffEDEDED)),
          child: GestureDetector(
            child: Icon(Icons.remove),
            onTap: () {
              if (widget.count - 1 != 0) {
                setState(() {
                  widget.count -= 1;
                  saveInfoCount();
                });
              }
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          child: Container(
            child: Text(widget.count.toString()),
            height: 25,
            alignment: Alignment.center,
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(0xffEDEDED)),
          child: GestureDetector(
            child: Icon(Icons.add),
            onTap: () {
              setState(() {
                widget.count += 1;
                saveInfoCount();
              });
            },
          ),
        ),
      ],
    );
  }
}
