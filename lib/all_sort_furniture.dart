import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:arnituramobile/globals.dart';
import 'image_sort.dart';

class AllSortFurniture extends StatefulWidget {
  final String id_sort;
  final String name_sort;

  AllSortFurniture({Key? key, required this.id_sort, required this.name_sort})
      : super(key: key);

  @override
  State<AllSortFurniture> createState() => _AllSortFurnitureState();
}

class _AllSortFurnitureState extends State<AllSortFurniture> {
  var colorSelected = Color(0xff4094D0);
  var length_list = 1;
  var listSelected = [true, false, false, false];
  var filter_from = 0;
  var filter_to = 10000;
  var filter_title = [
    'До 10 тыс. руб.',
    'От 10-30 тыс. руб.',
    'От 30-100 тыс. руб.',
    'Свыше 100 тыс. руб.'
  ];
  var filter_data = [
    [0, 10000],
    [10000, 30000],
    [30000, 100000],
    [100000, 9900000000]
  ];

  Future<String> downloadData() async {
    var url = Uri.parse(url_server + '/api/get_sort_furniture');
    var response = await post(url, body: {
      'filter_from': filter_from.toString(),
      'filter_to': filter_to.toString(),
      'id': widget.id_sort
    });
    return response.body;
  } // Получение списка мебели отсортированного по цене

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
    }
  } // Смена выбранного фильтра

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Container(
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: 45, right: 30, left: 30),
            child: CupertinoSearchTextField(
                padding: EdgeInsetsDirectional.fromSTEB(3.8, 5, 5, 5),
                itemSize: 20,
                placeholder: 'Поиск'),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              children: [
                Row(
                  children: [
                    ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: ChoiceChip(
                          label: Text(
                            filter_title[index],
                            style: TextStyle(
                                color: listSelected[index]
                                    ? Colors.white
                                    : Color(0xFF83868B),
                                fontWeight: listSelected[index]
                                    ? FontWeight.w600
                                    : FontWeight.normal),
                          ),
                          shape: StadiumBorder(
                              side: BorderSide(
                            width: 1,
                            color: Color(
                                listSelected[index] ? 0xFF2D3DB : 0xFF2D9CDB),
                          )),
                          backgroundColor: Colors.white,
                          selected: listSelected[index],
                          onSelected: (bool value) {
                            filter_from = filter_data[index][0];
                            filter_to = filter_data[index][1];
                            setState(() {
                              setSelected(value, index);
                            });
                          },
                          selectedColor: listSelected[index]
                              ? Color(0xff4094D0)
                              : Color(0xFF2D3DB),
                        ),
                      );
                    })
                    // todo: проверить работоспосбность фильтров
                    // SizedBox(width: 10),
                    // ChoiceChip(
                    //   label: Text(
                    //     'От 10-30 тыс. руб.',
                    //     style: TextStyle(
                    //         color: listSelected[1]
                    //             ? Colors.white
                    //             : Color(0xFF83868B),
                    //         fontWeight: listSelected[1]
                    //             ? FontWeight.w600
                    //             : FontWeight.normal),
                    //   ),
                    //   shape: StadiumBorder(
                    //       side: BorderSide(
                    //     width: 1,
                    //     color: Color(listSelected[1] ? 0xFF2D3DB : 0xFF2D9CDB),
                    //   )),
                    //   backgroundColor: Colors.white,
                    //   selected: listSelected[1],
                    //   onSelected: (bool value) {
                    //     filter_from = 10000;
                    //     filter_to = 30000;
                    //     setState(() {
                    //       setSelected(value, 1);
                    //     });
                    //   },
                    //   selectedColor: listSelected[1]
                    //       ? Color(0xff4094D0)
                    //       : Color(0xFF2D3DB),
                    // ),
                    // SizedBox(width: 10),
                    // ChoiceChip(
                    //   label: Text(
                    //     'От 30-100 тыс. руб.',
                    //     style: TextStyle(
                    //         color: listSelected[2]
                    //             ? Colors.white
                    //             : Color(0xFF83868B),
                    //         fontWeight: listSelected[2]
                    //             ? FontWeight.w600
                    //             : FontWeight.normal),
                    //   ),
                    //   shape: StadiumBorder(
                    //       side: BorderSide(
                    //     width: 1,
                    //     color: Color(listSelected[2] ? 0xFF2D3DB : 0xFF2D9CDB),
                    //   )),
                    //   backgroundColor: Colors.white,
                    //   selected: listSelected[2],
                    //   onSelected: (bool value) {
                    //     filter_from = 30000;
                    //     filter_to = 100000;
                    //     setState(() {
                    //       setSelected(value, 2);
                    //     });
                    //   },
                    //   selectedColor: listSelected[2]
                    //       ? Color(0xff4094D0)
                    //       : Color(0xFF2D3DB),
                    // ),
                    // SizedBox(width: 10),
                    // ChoiceChip(
                    //   label: Text(
                    //     'Свыше 100 тыс. руб.',
                    //     style: TextStyle(
                    //         color: listSelected[3]
                    //             ? Colors.white
                    //             : Color(0xFF83868B),
                    //         fontWeight: listSelected[3]
                    //             ? FontWeight.w600
                    //             : FontWeight.normal),
                    //   ),
                    //   shape: StadiumBorder(
                    //       side: BorderSide(
                    //     width: 1,
                    //     color: Color(listSelected[3] ? 0xFF2D3DB : 0xFF2D9CDB),
                    //   )),
                    //   backgroundColor: Colors.white,
                    //   selected: listSelected[3],
                    //   onSelected: (bool value) {
                    //     filter_from = 100000;
                    //     filter_to = 9900000000;
                    //     setState(() {
                    //       setSelected(value, 3);
                    //     });
                    //   },
                    //   selectedColor: listSelected[3]
                    //       ? Color(0xff4094D0)
                    //       : Color(0xFF2D3DB),
                    // ),
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
                return Center(child: Text('Please wait its loading...'));
              } else {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                else
                  return Expanded(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: Container(
                            width: double.infinity,
                            child: Text(widget.name_sort.toString(),
                                style: TextStyle(
                                    color: Color(0xff4094D0),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(
                                      left: 16.0, right: 16.0, top: 16.0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 3,
                                          childAspectRatio: 0.7),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Map<String, dynamic> data =
                                        jsonDecode(snapshot.data.toString());
                                    return ImageSort(
                                      link_image:
                                          '${data[index.toString()]['photo']}',
                                      name: 'test',
                                      cell:
                                          '${data[index.toString()]['price']} P',
                                      manufacturer_id:
                                          '${data[index.toString()]['manufacturer_id']}',
                                    );
                                  },
                                  itemCount:
                                      jsonDecode(snapshot.data.toString())
                                          .length),
                            ),
                          ],
                        )
                      ],
                    )),
                  );
              }
            },
          ),
        ]),
      )),
    );
  }
}
