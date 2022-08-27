import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart';
import 'package:arnituramobile/globals.dart';
import 'comment.dart';

class FullPost extends StatefulWidget {
  final String id;
  final String manufacturer_id;

  FullPost({Key? key, required this.id, required this.manufacturer_id})
      : super(key: key);

  @override
  State<FullPost> createState() => _FullPostState();
}

class HomePageController {
  late void Function() methodA;
}

class _FullPostState extends State<FullPost>
    with AutomaticKeepAliveClientMixin {
  var _currentIndex = 1;
  int activePage = 1;
  List<String> images = [];
  late StateSetter _setState;

  @override
  void initState() {
    super.initState();
  }

  Future<String> getObjectManufacturer() async {
    var url = Uri.parse(url_server + '/api/get_manufacturer');
    var response = await post(url, body: {'id': widget.manufacturer_id});
    var response_posts = await post(
        Uri.parse(url_server + '/api/get_list_photos_post'),
        body: {'id': widget.id});
    debugPrint(jsonDecode(response_posts.body)['0']['photo']
        .toString()
        .split(', ')
        .toString());
    for (int i = 0;
        i <
            jsonDecode(response_posts.body)['0']['photo']
                .toString()
                .split(', ')
                .length;
        i++) {
      images.add(url_server + '/api/get_photos?id=' +
              widget.manufacturer_id.toString() +
              '&photo_name=' +
              jsonDecode(response_posts.body)['0']['photo'].toString()
          // jsonDecode(response_posts.body)[i.toString()]['photo'].toString()
          );
    }
    ;
    return response.body;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
            centerTitle: false,
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.transparent,
            bottomOpacity: 0,
            elevation: 0,),
          body: FutureBuilder<String>(
            future: getObjectManufacturer(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text('Please wait its loading...'));
              } else {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                else {
                  return Column(children: [
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      child: Stack(
                        children: [
                          Container(
                              child: CarouselSlider(
                            items: images
                                .map(
                                  (item) => Center(
                                    child: Image.network(
                                      item,
                                      fit: BoxFit.fill,
                                      height: 400,
                                    ),
                                  ),
                                )
                                .toList(),
                            options: CarouselOptions(
                                onPageChanged: (index, reason) {
                                  _currentIndex = index + 1;
                                  _setState(() {});
                                },
                                viewportFraction: 1,
                                height: 400,
                                enableInfiniteScroll: false,
                                autoPlay: false),
                          )),
                          StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              _setState = setState;
                              return Positioned(
                                right: 20,
                                top: 20,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Color(0xff494950)),
                                  child: Text(
                                    ' ' +
                                        _currentIndex.toString() +
                                        '/' +
                                        images.length.toString() +
                                        ' ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          )
                          // Специально нужен для того чтобы отделить виджет от остальных и при setState обновлять только его(счетчик)
                        ],
                      ),
                    ),
                    Row(children: [
                      SizedBox(width: 10),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/image/like_button_off.png',
                            width: 30,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/image/chat_button.png',
                            width: 30,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/image/share_button.png',
                            width: 30,
                          )),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => HelloWorld()));
                          },
                          icon: Image.asset(
                            'assets/image/ar_button.png',
                            width: 25,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/image/favourites_button.png',
                            width: 30,
                          )),
                      SizedBox(width: 10),
                    ]),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Text('0',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text(' Likes',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          margin: EdgeInsets.only(left: 20),
                          child: InkWell(
                              onTap: () {},
                              child: Text(
                                'Серия Хистори: кресло “Людовик”, диван.erf3f43f34ferwfew',
                                softWrap: true,
                                style: TextStyle(
                                    color: Color(0xff4094D0),
                                    fontWeight: FontWeight.w600),
                              )),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Comment()));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  'Посмотреть все отзывы (12)',
                                  style: TextStyle(color: Color(0xff83868B)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            child: Row(
                              children: [
                                Container(
                                  child: Image.network(
                                      url_server + '/api/get_photo_avatar?id=' +
                                          widget.manufacturer_id.toString() +
                                          '&photo_name=image_company',
                                      width: 30),
                                  margin: EdgeInsets.only(left: 20),
                                ),
                                Container(
                                  child: Text(
                                    'Добавить отзыв...',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff83868B)),
                                  ),
                                  margin: EdgeInsets.only(left: 10),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]);
                }
              }
            },
          )),
    );
  }
}
