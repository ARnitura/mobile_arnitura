import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:arnituramobile/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bottomNavbar.dart';
import 'full_post.dart';
import 'main_drawer.dart';
import 'app_bar_drawer_list.dart';

class ManufacturerWidget extends StatefulWidget {
  final String manufacturer_data;
  final String manufacturer_id;
  var counter_products = '0';

  ManufacturerWidget(
      {Key? key,
      required this.manufacturer_data,
      required this.manufacturer_id})
      : super(key: key);

  @override
  _ManufacturerWidgetState createState() => _ManufacturerWidgetState();
}

class _ManufacturerWidgetState extends State<ManufacturerWidget> {
  dynamic likes_count = 0;
  dynamic list_favourites = 0;
  dynamic list_products = 0;
  dynamic list_orders = 0;

  Future<String> getPhotoList() async {
    var _url = Uri.parse(url_server + '/api/get_list_photos');
    var _response = await post(_url, body: {'id': widget.manufacturer_id});
    return _response.body;
  }

  void getManufacturerCount() async {
    var url = Uri.parse(url_server + '/api/get_counts_manufacturer');
    var res =
        await post(url, body: {'id_manufacturer': widget.manufacturer_id});
    setState(() {
      likes_count = jsonDecode(res.body)['likes_count'];
      list_favourites = jsonDecode(res.body)['list_favourites'];
      list_products = jsonDecode(res.body)['list_products'];
      list_orders = jsonDecode(res.body)['list_orders'];
    });
  }

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    await launchUrl(Uri.parse(url));
  }

  @override
  void initState() {
    super.initState();
    getManufacturerCount();
  }

  @override
  Widget build(BuildContext context) {
    var data = jsonDecode(widget.manufacturer_data);
    return Scaffold(
      bottomNavigationBar: arniturabottomNavBar(currentIndex: -1),
      drawer: DrawerKreslo(),
      appBar: AppBarDrawerList(''),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(
                  url_server +
                      '/api/get_photo_avatar?id=' +
                      widget.manufacturer_id.toString() +
                      '&photo_name=image_company',
                  width: 95,
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/image/kreslo_count.png',
                      width: 30,
                    ),
                    Text(list_products.toString())
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/like_count.png', width: 30),
                    Text(likes_count.toString())
                  ],
                ),
                Column(
                  children: [
                    Image.asset('assets/image/shop_count.png', width: 30),
                    Text(list_orders.toString())
                  ],
                ),
                // Column(
                //   children: [
                //     Image.asset('assets/image/bookmark_icon_manufacturers.png', width: 30),
                //     Text(list_favourites.toString())
                //   ],
                // ),  # todo: отключено избранное
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 30, top: 20, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  // Название
                  GestureDetector(
                      onTap: () {
                        _launchURL(data['mail'].toString(),
                            'Сообщение производителю', '');
                      },
                      child: Text(data['mail'].toString())),
                  // Почта
                  GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(
                            "tel:" + data['phone_number'].toString()));
                      },
                      child: Text(data['phone_number'].toString())),
                  SizedBox(
                    height: 5,
                  ),
                  // Номер телефона
                  GestureDetector(
                      onTap: () {
                        launchUrl(
                            Uri.parse(data['site'].toString()));
                      },
                      child: Text(data['site'],
                          style: TextStyle(color: Color(0xFF2D9CDB))))
                  // Сайт
                ],
              )),
          Expanded(
              child: FutureBuilder<String>(
            future: getPhotoList(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text('Please wait its loading...'));
              } else {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                else
                  return GridView.builder(
                    itemCount: jsonDecode(snapshot.data.toString()).length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 3),
                    itemBuilder: (BuildContext context, int index) {
                      // debugPrint(jsonDecode(snapshot.data.toString())[index.toString()].toString());
                      // debugPrint(data.toString());
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullPost(
                                  id: jsonDecode(snapshot.data.toString())[
                                          index.toString()]['id']
                                      .toString(),
                                  manufacturer_id: widget.manufacturer_id),
                            ),
                          );
                        },
                        child: Image.network(url_server +
                            '/api/get_photos?id=' +
                            widget.manufacturer_id.toString() +
                            '&photo_name=' +
                            jsonDecode(snapshot.data.toString())[
                                    index.toString()]['photo']
                                .toString()),
                      );
                    },
                    // children: [
                    //   ListView.builder(itemBuilder: (BuildContext context, int index) {
                    //     return Image.network('https://picsum.photos/250?image=2');
                    //   }, itemCount: 5),
                    //   Stack(
                    //     children: [
                    //       Image.network('https://picsum.photos/250?image=1'),
                    //       Container(
                    //         child: Align(
                    //             child: Image.asset(
                    //               'assets/image/carousel_icon.png',
                    //               width: 15,
                    //             ),
                    //             alignment: Alignment.topRight),
                    //         margin: EdgeInsets.all(10),
                    //       ),
                    //     ],
                    //   ),
                    //   Image.network('https://picsum.photos/250?image=2'),
                    //   Image.network('https://picsum.photos/250?image=2'),
                    //   Image.network('https://picsum.photos/250?image=3'),
                    //   Image.network('https://picsum.photos/250?image=4'),
                    // ],
                  );
              }
            },
          ))
        ],
      ),
    );
  }
}
