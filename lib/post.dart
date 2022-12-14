import 'dart:convert';
import 'package:expansion_widget/expansion_widget.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arnituramobile/auth.dart';
import 'package:arnituramobile/globals.dart';
import 'authDialog.dart';
import 'dart:math';

import 'manufacturer.dart';

class Post extends StatefulWidget {
  final String id;
  final String manufacturer_id;
  final VoidCallback setStatePosts;

  Post(
      {Key? key,
      required this.id,
      required this.manufacturer_id,
      required this.setStatePosts})
      : super(key: key);

  @override
  State<Post> createState() => PostState();
}

class PostState extends State<Post> with AutomaticKeepAliveClientMixin {
  var isLiked = false;
  var _currentIndex = 1;
  var countLikes = '0';
  int activePage = 1;
  List<String> images = [];
  late StateSetter _setState;
  late StateSetter _setStateLike;
  late StateSetter _setStateLikeCount;
  var info_post, isAuth;
  var date_post = '';
  var time_post = '';
  var price = '';

  @override
  void initState() {
    super.initState();
    print('post init');
  }

  void setStatePosts() {
    widget.setStatePosts();
  }

  void initStateLike() async {
    if (!mounted) return;
    var prefs = await SharedPreferences.getInstance();
    var id_user = await prefs.getString('id');
    if (id_user != null) {
      var res = await post(Uri.parse(url_server + '/api/get_state_like'),
          body: {'id_user': id_user, 'id_post': widget.id});
      if (jsonDecode(res.body)['state'] == 'on') {
        this.isLiked = true;
      } else if (jsonDecode(res.body)['state'] == 'off') {
        this.isLiked = false;
      }
    } // Если пользователь авторизован то определяется состояние лайка
    else {
      this.isLiked = false;
    } // Если пользваотель вышел из акк или не авторизирован то лайк выключен
    var res = await post(Uri.parse(url_server + '/api/get_count_like'),
        body: {'id_post': widget.id});
    this.countLikes = jsonDecode(res.body)['count_likes'].toString();
    if (indexUnityPageLayer == 0) {
      _setStateLikeCount(() {});
      _setStateLike(() {});
    }
  }

  Future<String> getObjectManufacturer() async {
    this.price = "";
    var url = Uri.parse(url_server + '/api/get_manufacturer');
    var response = await post(url, body: {'id': widget.manufacturer_id});
    var response_posts = await post(
        Uri.parse(url_server + '/api/get_list_photos_post'),
        body: {'id': widget.id});
    this.info_post = await post(Uri.parse(url_server + '/api/get_info_post'),
        body: {'id_post': widget.id});
    var index = 1;
    for (int i = jsonDecode(info_post.body)['0']['price_furniture']
                .round()
                .toString()
                .length -
            1;
        i >= 0;
        i--) {
      this.price = jsonDecode(info_post.body)['0']['price_furniture']
              .round()
              .toString()[i] +
          this.price;
      if (index % 3 == 0) {
        this.price = ' ' + this.price;
      }
      index += 1;
    }
    time_post = jsonDecode(info_post.body)['0']['post_time'];
    // debugPrint(jsonDecode(response_posts.body)['0']['photo']
    //     .toString()
    //     .split(', ')
    //     .toString()); // TODO: Починить отображение фото
    this.images = [];
    for (int i = 0;
        i <
            jsonDecode(response_posts.body)['0']['photo']
                .toString()
                .split(', ')
                .length;
        i++) {
      this.images.add(url_server +
          '/api/get_photos?id=' +
          widget.manufacturer_id.toString() +
          '&photo_name=' +
          jsonDecode(response_posts.body)['0']['photo']
              .toString()
              .split(', ')[i]
              .toString());
    }
    ;
    initStateLike();
    return response.body;
  }

  void put_like() async {
    var url = Uri.parse(url_server + '/api/put_like');
    var prefs = await SharedPreferences.getInstance();
    var id = await prefs.getString('id');
    var res = await post(url, body: {'id_post': widget.id, 'id_user': id});
    if (jsonDecode(res.body)['description'] == 'success') {
      this.isLiked = true;
    } else if (jsonDecode(res.body)['description'] == 'cancelled') {
      this.isLiked = false;
    }
    this.countLikes = jsonDecode(res.body)['count_likes'].toString();
    _setStateLikeCount(() {});
    _setStateLike(() {});

    print(res.body.toString());
  } // Поставить лайк

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<String>(
      future: getObjectManufacturer(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 2,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                "assets/animation/loader.gif",
                height: 125.0,
                width: 125.0,
              ),
            ),
          );
        } else {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          else {
            return Column(children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ManufacturerWidget(
                                manufacturer_data: snapshot.data.toString(),
                                manufacturer_id:
                                    widget.manufacturer_id.toString(),
                              )));
                },
                child: Row(
                  children: [
                    Container(
                      child: Image.network(
                          url_server +
                              '/api/get_photo_avatar?id=' +
                              widget.manufacturer_id.toString() +
                              '&photo_name=image_company',
                          width: 30),
                      margin: EdgeInsets.only(left: 20),
                    ), // Контейнер с фото производителя
                    Container(
                      child: Text(
                        jsonDecode(snapshot.data.toString())['name'].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      margin: EdgeInsets.only(left: 10),
                    ) // Название производителя
                  ],
                ),
              ),
              // Плашка для перехода на экран производителя
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
                                fit: BoxFit.fitWidth,
                                height: 400,
                              ),
                            ),
                          )
                          .toList(),
                      options: CarouselOptions(
                          onPageChanged: (index, reason) {
                            _currentIndex = index + 1;
                            print('1');
                            _setState(() {});
                          },
                          viewportFraction: 1,
                          height: 400,
                          enableInfiniteScroll: false,
                          autoPlay: false),
                    )),
                    // Карусель из фото товара
                    StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
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
                    // Счетчик, из за того что нужно обновлять состояние(только счетчика а не всего поста) он не выделен в другой виджет, а сделан адаптивно
                  ],
                ),
              ),
              // Карусель с фотографиями товаров
              Row(children: [
                SizedBox(width: 10),
                IconButton(onPressed: () async {
                  isAuth = await Auth().isAuth();
                  if (isAuth == 1) {
                    put_like();
                  } // Делаем запрос на апи и ставим лайк, передаем айди
                  else if (isAuth == 0) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return authDialog(
                              setStatePosts: widget.setStatePosts);
                        });
                  } // Выводим окно авторизации или регистрации
                }, icon: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    _setStateLike = setState;
                    return isLiked
                        ? Image.asset(
                            'assets/image/like_button_on.png',
                            width: 30,
                          )
                        : Image.asset(
                            'assets/image/like_button_off.png',
                            width: 30,
                          );
                  },
                )),
                Container(
                  child: Row(
                    children: [
                      StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          _setStateLikeCount = setState;
                          return Text(this.countLikes.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff83868B)));
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                  ),
                ),
                IconButton(
                    iconSize: 40,
                    splashRadius: 30,
                    onPressed: () {
                      idTextureUnityModel = jsonDecode(info_post.body)['0']
                          ['material_id_furniture'];
                      idPostUnityModel = widget.id;
                      indexUnityPageLayer == 0
                          ? indexUnityPageLayer = 2
                          : indexUnityPageLayer = 0;
                      widget.setStatePosts(); // Переход между экранами
                      if (indexUnityPageLayer == 2) {
                        idPostUnityModel = idPostUnityModel;
                        Future.delayed(const Duration(milliseconds: 0), () {
                          unityWidgetController.postMessage(
                              '_FlutterMessageHandler', 'StartAR', '');
                        }).then((value) => ArController.downloadModel()).then(
                            (value) => ArController.downloadTextureToModel());
                      } // Если переход был совершен на экран ar(Инициализация)
                    }, // Кнопка дополненной реальности
                    icon: Image.asset(
                      'assets/image/ar_button.png',
                      width: 40,
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
                      //         builder: (context) => ()));
                    },
                    icon: Image.asset(
                      'assets/image/favourites_button.png',
                      width: 30,
                      color: Colors
                          .transparent, // #TODO: Избранное в прозрачном состооянии
                    )),
                SizedBox(width: 10),
              ]),
              // Кнопки лайка, ar, избранного
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 40,
                    margin: EdgeInsets.only(left: 20),
                    child: InkWell(onTap: () {
                      debugPrint(snapshot.data.toString());
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => FullPost(
                      //         id: widget.id,
                      //         manufacturer_id: widget.manufacturer_id),
                      //   ),
                      // );
                    }, child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return ExpansionWidget(
                            initiallyExpanded: false,
                            titleBuilder: (double animationValue, _,
                                bool isExpaned, toogleFunction) {
                              return InkWell(
                                  onTap: () => {
                                        toogleFunction(
                                          animated: true,
                                        ),
                                        print(animationValue)
                                        // debugPrint(jsonDecode(info_post.body)
                                        //     .toString()),
                                      },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Text(
                                                'Серия «' +
                                                    jsonDecode(info_post.body)[
                                                                '0']
                                                            ['series_furniture']
                                                        .toString() +
                                                    '»',
                                                style: TextStyle(
                                                    color: Color(0xff4094D0),
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        Transform.rotate(
                                          angle: pi * (animationValue + 2) / 2,
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: 20,
                                            color: Color(0xff4094D0),
                                          ),
                                          alignment: Alignment.center,
                                        )
                                      ],
                                    ),
                                  ));
                            },
                            content: Container(
                              width: double.infinity,
                              color: Colors.white,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      children: [
                                        Text(
                                            jsonDecode(info_post.body)['0']
                                                        ['sort_furniture']
                                                    .toString() +
                                                ' «' +
                                                jsonDecode(info_post.body)['0']
                                                        ['name_furniture']
                                                    .toString() +
                                                '»',
                                            style: TextStyle(
                                                color: Color(0xff4094D0),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            // 'От '
                                            this.price + '₽',
                                            style: TextStyle(
                                                overflow: TextOverflow.fade,
                                                color: Color(0xff4094D0),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500))
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween),
                                  Container(
                                    child: Text(
                                      jsonDecode(info_post.body)['0']
                                              ['description_furniture']
                                          .toString(),
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                  ),
                                  Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Материал',
                                              style: TextStyle(
                                                  color: Color(0xff4094D0),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                              jsonDecode(info_post.body)['0'][
                                                      'material_name_furniture']
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Color(0xff83868B),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400))
                                        ],
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 5)),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                            textDirection: TextDirection.ltr,
                                            text: TextSpan(
                                              text: "Габаритные размеры",
                                              style: TextStyle(
                                                  color: Color(0xff4094D0),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: " (ш*д*в)",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff83868B),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            )),
                                        Text(
                                            jsonDecode(info_post.body)['0']
                                                        ['width']
                                                    .toString() +
                                                '*' +
                                                jsonDecode(info_post.body)['0']
                                                        ['length']
                                                    .toString() +
                                                '*' +
                                                jsonDecode(info_post.body)['0']
                                                        ['height']
                                                    .toString(),
                                            style: TextStyle(
                                                color: Color(0xff83868B),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                  ),
                                ],
                              ),
                            ));
                      },
                    )
                        //  Text(
                        //   'Серия Хистори: кресло “Людовик”, диван',
                        //   overflow: TextOverflow.ellipsis,
                        //   style: TextStyle(
                        //       color: Color(0xff4094D0),
                        //       fontWeight: FontWeight.w600),
                        // )
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      this.time_post.toString(),
                      style: TextStyle(color: Color(0xff999999)),
                    ),
                    margin: EdgeInsets.only(left: 20),
                  ),
                ],
              ),
              SizedBox(height: 40)
              //
              // InkWell(
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => Comment()));
              //   },
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             margin: EdgeInsets.only(left: 20),
              //             child: Text(
              //               'Посмотреть все отзывы (12)',
              //               style: TextStyle(color: Color(0xff83868B)),
              //             ),
              //           ),
              //         ],
              //       ),
              //       Container(
              //         margin: EdgeInsets.only(top: 20, bottom: 20),
              //         child: Row(
              //           children: [
              //             Container(
              //               child: Image.network(
              //                   'https://arkreslo.ru/api/get_photo_avatar?id=' +
              //                       widget.manufacturer_id.toString() +
              //                       '&photo_name=image_company',
              //                   width: 30),
              //               margin: EdgeInsets.only(left: 20),
              //             ),
              //             Container(
              //               child: Text(
              //                 'Добавить отзыв...',
              //                 style: TextStyle(
              //                     fontWeight: FontWeight.w500,
              //                     color: Color(0xff83868B)),
              //               ),
              //               margin: EdgeInsets.only(left: 10),
              //             )
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ]);
          }
        }
      },
    );
  }
}
