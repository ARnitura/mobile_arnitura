import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:arnituramobile/bottomNavbar.dart';
import 'package:arnituramobile/globals.dart';
import 'package:arnituramobile/grid_search.dart';
import 'package:arnituramobile/all_sort_furniture.dart';

class Search extends StatefulWidget {
  Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var filter_from = 0;
  var filter_to = 10000;
  var colorSelected = Color(0xff4094D0);
  var length_list = 1;
  late Map<String, dynamic> data = {};
  var listSelected = [
    true,
    false,
    false,
    false
  ]; // Список из компонентов с чипсами который включает в себя: Нажата кнопка или нет

  void setSelected(value, index) {
    for (int i = 0; i < listSelected.length; i++) {
      if (listSelected[i] == true) {
        listSelected[i] = !listSelected[i];
      } else if (i == index) {
        listSelected[index] = !listSelected[index];
      }
    }
    if (listSelected.contains(true) == false) {
      filter_from = 0;
      filter_to = 99999999;
      getFurniture();
    };
  }

  @override
  void initState() {
    super.initState();
    getFurniture();
  }

  Future<String> downloadData() async {
    var url = Uri.parse(url_server + '/api/get_list_furniture');
    var response = await post(url);
    return response.body;
  }

  Future getFurniture() async {
    var url = Uri.parse(url_server + '/api/get_product_3_furniture');
    var response = await post(url, body: {
      'filter_from': filter_from.toString(),
      'filter_to': filter_to.toString(),
    });
    this.data = jsonDecode(response.body.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(top: 45, right: 16, left: 16),
              child: Row(
                children: [
                  // IconButton(onPressed: () {Navigator.of(context).pop();}, icon: Icon(Icons.arrow_back), iconSize: 20, splashRadius: 20,),
                  Expanded(
                    child: CupertinoSearchTextField(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                        itemSize: 0,
                        placeholder: 'Поиск'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 20),
                      ChoiceChip(
                        label: Text(
                          'До 10 тыс. руб.',
                          style: TextStyle(
                              color: listSelected[0]
                                  ? Colors.white
                                  : Color(0xFF83868B),
                              fontWeight: listSelected[0]
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        ),
                        shape: StadiumBorder(
                            side: BorderSide(
                          width: 1,
                          color:
                              Color(listSelected[0] ? 0xFF2D3DB : 0xFF2D9CDB),
                        )),
                        backgroundColor: Colors.white,
                        selected: listSelected[0],
                        // Идентификатор нужный для того чтобы проверялось нажата кнопка или нет в соответствии со списком
                        onSelected: (bool value) {
                          filter_from = 0;
                          filter_to = 10000;
                          setState(() {
                            getFurniture();
                            setSelected(value, 0);
                          });
                        },
                        selectedColor: listSelected[0]
                            ? Color(0xff4094D0)
                            : Color(0xFF2D3DB),
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text(
                          'От 10-30 тыс. руб.',
                          style: TextStyle(
                              color: listSelected[1]
                                  ? Colors.white
                                  : Color(0xFF83868B),
                              fontWeight: listSelected[1]
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        ),
                        shape: StadiumBorder(
                            side: BorderSide(
                          width: 1,
                          color:
                              Color(listSelected[1] ? 0xFF2D3DB : 0xFF2D9CDB),
                        )),
                        backgroundColor: Colors.white,
                        selected: listSelected[1],
                        onSelected: (bool value) {
                          filter_from = 10000;
                          filter_to = 30000;
                          setState(() {
                            getFurniture();
                            setSelected(value, 1);
                          });
                        },
                        selectedColor: listSelected[1]
                            ? Color(0xff4094D0)
                            : Color(0xFF2D3DB),
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text(
                          'От 30-100 тыс. руб.',
                          style: TextStyle(
                              color: listSelected[2]
                                  ? Colors.white
                                  : Color(0xFF83868B),
                              fontWeight: listSelected[2]
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        ),
                        shape: StadiumBorder(
                            side: BorderSide(
                          width: 1,
                          color:
                              Color(listSelected[2] ? 0xFF2D3DB : 0xFF2D9CDB),
                        )),
                        backgroundColor: Colors.white,
                        selected: listSelected[2],
                        onSelected: (bool value) {
                          filter_from = 30000;
                          filter_to = 100000;
                          setState(() {
                            getFurniture();
                            setSelected(value, 2);
                          });
                        },
                        selectedColor: listSelected[2]
                            ? Color(0xff4094D0)
                            : Color(0xFF2D3DB),
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text(
                          'Свыше 100 тыс. руб.',
                          style: TextStyle(
                              color: listSelected[3]
                                  ? Colors.white
                                  : Color(0xFF83868B),
                              fontWeight: listSelected[3]
                                  ? FontWeight.w600
                                  : FontWeight.normal),
                        ),
                        shape: StadiumBorder(
                            side: BorderSide(
                          width: 1,
                          color:
                              Color(listSelected[3] ? 0xFF2D3DB : 0xFF2D9CDB),
                        )),
                        backgroundColor: Colors.white,
                        selected: listSelected[3],
                        onSelected: (bool value) {
                          filter_from = 100000;
                          filter_to = 999999999;
                          setState(() {
                            getFurniture();
                            setSelected(value, 3);
                          });
                        },
                        selectedColor: listSelected[3]
                            ? Color(0xff4094D0)
                            : Color(0xFF2D3DB),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )
                ],
              ),
            ),
            FutureBuilder<String>(
              future: downloadData(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text('Загрузка товаров...'));
                } else {
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  else
                    return Expanded(
                      child: Center(
                        child: ListView.builder(
                            itemBuilder: (context, index) {
                              Map<String, dynamic> user =
                                  jsonDecode(snapshot.data.toString());
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AllSortFurniture(
                                                        id_sort: user[index
                                                                    .toString()]
                                                                ['id']
                                                            .toString(),
                                                        name_sort:
                                                            '${user[index.toString()]['sort']}',
                                                      )));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          child: Text(
                                              '${user[index.toString()]['sort']}',
                                              style: TextStyle(
                                                  color: Color(0xff4094D0),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      )),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GridSearch(
                                            data: this.data, indexGL: index),
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                            itemCount:
                                jsonDecode(snapshot.data.toString()).length),
                      ),
                    );
                }
              },
            ),
          ]),
        ),
        bottomNavigationBar: arniturabottomNavBar(currentIndex: 1),
        // bottomNavigationBar: BottomAppBar(
        //     child: Row(
        //   children: [
        //     IconButton(
        //         onPressed: () {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => MyApp()));
        //         },
        //         icon: Image.asset('assets/image/home_icon.png')),
        //     IconButton(
        //         onPressed: () {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => Search()));
        //         },
        //         icon: Image.asset('assets/image/search_icon.png')),
        //     IconButton(
        //         onPressed: () {
        //           Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => ShopingWidget()));
        //         },
        //         icon: Image.asset('assets/image/shop_icon.png')),
        //   ],
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        // )),
      ),
    );
  }
}
