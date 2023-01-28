import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:arnituramobile/globals.dart';
import 'package:image_network/image_network.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ContactWidget extends StatefulWidget {
  ContactWidget({Key? key}) : super(key: key);

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  var phoneNumber = '';
  var mail = '';
  var address = '';
  var firstname = '';
  var lastname = '';
  var patronymic = '';
  dynamic avatar = '';
  var id = '';
  File? image;

  @override
  void initState() {
    super.initState();
    getInfoUserLocal();
  }

  Future get_avatar_user() async {
    var imageUrl = url_server + '/api/get_photo_user_avatar?user_id=' + id.toString();
    var prefs = await SharedPreferences.getInstance();
    var cacheImageKey = prefs.getString('cacheImageKey');
    avatar = ImageNetwork(
        image: imageUrl,
        width: 80,
        height: 80,
        fitAndroidIos: BoxFit.cover,
        imageCache: CachedNetworkImageProvider(imageUrl, cacheKey: cacheImageKey),
    );
    setState(() {});
  }

  edit_info_user(number, mail, address) async {
    var res = await http.post(Uri.parse(url_server + '/api/edit_info_user'),
        body: {
          'user_id': id,
          'number': number.text,
          'mail': mail.text,
          'address': address.text
        });
    if (res.statusCode == 200) {
      var prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('phone', number.text);
        prefs.setString('mail', mail.text);
        prefs.setString('address', address.text);
        this.phoneNumber = number.text;
        this.mail = mail.text;
        this.address = address.text;
      });
    }
  } // Редактирование информации о пользователе

  edit_fullname_user(lastname, firstname, patronymic) async {
    var res = await http
        .post(Uri.parse(url_server + '/api/edit_fullname_user'), body: {
      'user_id': id,
      'firstname': firstname.text,
      'lastname': lastname.text,
      'patronymic': patronymic.text
    });
    if (res.statusCode == 200) {
      var prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('firstname', firstname.text);
        prefs.setString('lastname', lastname.text);
        prefs.setString('patronymic', patronymic.text);
        this.firstname = firstname.text;
        this.lastname = lastname.text;
        this.patronymic = patronymic.text;
      });
    }
  } // Редактирование ФИО о пользователе

  _showDialog(BuildContext context) {
    var numberController = TextEditingController(text: phoneNumber);
    var mailController = TextEditingController(text: mail);
    var addressController = TextEditingController(text: address);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: AlertDialog(
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Телефон'),
                      SizedBox(height: 5),
                      TextField(
                          controller: numberController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      Text('Электронная почта'),
                      SizedBox(height: 5),
                      TextField(
                          controller: mailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      Text('Адрес доставки'),
                      SizedBox(height: 5),
                      TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      OutlinedButton(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Сохранить',
                              style: TextStyle(
                                  color: Color(0xff202020),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 0),
                          backgroundColor: Color(0xffEDEDED),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        onPressed: () {
                          edit_info_user(numberController.value,
                              mailController.value, addressController.value);
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xff4094D0),
                            size: 16,
                          ),
                          GestureDetector(
                            child: Text('Назад',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff4094D0))),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ]),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ],
        );
      },
    );
  }

  _showDialogFullname(BuildContext context) {
    var _lastnameController = TextEditingController(text: this.lastname);
    var _firstnameController = TextEditingController(text: this.firstname);
    var _patronymicController = TextEditingController(text: this.patronymic);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: AlertDialog(
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Фамилия'),
                      SizedBox(height: 5),
                      TextField(
                          controller: _lastnameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      Text('Имя'),
                      SizedBox(height: 5),
                      TextField(
                          controller: _firstnameController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      Text('Отчество'),
                      SizedBox(height: 5),
                      TextField(
                          controller: _patronymicController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 8))),
                      SizedBox(height: 20),
                      OutlinedButton(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Сохранить',
                              style: TextStyle(
                                  color: Color(0xff202020),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white, width: 0),
                          backgroundColor: Color(0xffEDEDED),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                        ),
                        onPressed: () {
                          edit_fullname_user(
                              _lastnameController.value,
                              _firstnameController.value,
                              _patronymicController.value);
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xff4094D0),
                            size: 16,
                          ),
                          GestureDetector(
                            child: Text('Назад',
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff4094D0))),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ]),
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.blue, width: 1.5),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ),
          ],
        );
      },
    );
  }

  void getInfoUserLocal() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id')!;
      firstname = prefs.getString('firstname')!;
      lastname = prefs.getString('lastname')!;
      patronymic = prefs.getString('patronymic')!;
      if (prefs.getString('avatar') == null) {
        avatar = '';
      }
      else {
        avatar = prefs.getString('avatar')!;
      }
      phoneNumber = prefs.getString('phone')!;
      mail = prefs.getString('mail')!;
      address = prefs.getString('address')!;
    });
    if (avatar != '') {
      get_avatar_user();
    }
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      _asyncFileUpload(this.id, imageTemporary);
    } on PlatformException catch (e) {
      print('failed to pick image');
    }
  }

  _asyncFileUpload(String text, File file) async {
    var request = await http.MultipartRequest(
        "POST", Uri.parse(url_server + '/api/set_user_avatar'));
    request.fields["user_id"] = text;
    var pic = await http.MultipartFile.fromPath("file_field", file.path);
    request.files.add(pic);
    var response = await request.send();

    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    if (jsonDecode(responseString)['status'] == 200) {
      var prefs = await SharedPreferences.getInstance();
      prefs.setString('cacheImageKey', Random().nextInt(100).toString());
      get_avatar_user();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: const Color(0xFF4094D0),
          title: Text('Контактные данные'),
          centerTitle: false,
          bottomOpacity: 0,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              margin: EdgeInsets.only(top: 100, right: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 30),
                  Stack(
                    children: [
                      avatar != ''
                                ? ClipOval(
                                    child: avatar,
                                  )
                                : Image.asset(
                                    'assets/image/no_auth_avatar.png',
                                    width: 80,
                                    height: 80,
                                  ),
                      Positioned(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40)),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            splashRadius: 20,
                            icon: Icon(Icons.add_a_photo_outlined,
                                color: Colors.black),
                            onPressed: () {
                              pickImage();
                            },
                          ), // Добавить фото
                        ),
                        bottom: 0,
                        right: 0,
                      )
                    ],
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(firstname + ' ' + patronymic,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        Text('В сети', style: TextStyle(color: Colors.white))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15, 20, 00, 10),
                child: const Text(
                  'Контактные данные',
                  style: TextStyle(
                      color: Color(0xFF4094D0),
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
              ListTile(
                  title: Text(
                    lastname + ' ' + firstname + ' ' + patronymic,
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text('Фамилия Имя Отчество'),
                  onTap: () {
                    _showDialogFullname(context);
                  }),
              ListTile(
                title: Text(phoneNumber),
                subtitle: Text('Номер телефона'),
                onTap: () {
                  _showDialog(context);
                },
              ),
              ListTile(
                title: Text(mail),
                subtitle: Text('Электронная почта'),
                onTap: () {
                  _showDialog(context);
                },
              ),
              SizedBox(height: 15),
              ListTile(
                title: Text(address),
                subtitle: Text('Адрес доставки'),
                onTap: () {
                  _showDialog(context);
                },
              ),
            ],
          ))
        ],
      ),
    );
  }
}
