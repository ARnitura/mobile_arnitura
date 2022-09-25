import 'dart:convert';
import 'auth.dart';
import 'authDialog.dart';
import 'globals.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_bar_drawer_list_to_back.dart';

class OrderWidget extends StatefulWidget {
  OrderWidget({Key? key}) : super(key: key);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  var _value = false;
  var firstname = '';
  var lastname = '';
  var patronymic = '';
  var mail = '';
  var phoneNumber = '';
  var address = '';
  var listOrders;
  var printedOrders = [];
  late var isAuth;

  @override
  void initState() {
    super.initState();
    getInfoUser();
  }

  void getInfoUser() async {
    isAuth = await Auth().isAuth();
    var prefs = await SharedPreferences.getInstance();
    firstname = prefs.getString('firstname').toString();
    lastname = prefs.getString('lastname').toString();
    patronymic = prefs.getString('patronymic').toString();
    mail = prefs.getString('mail').toString();
    address = prefs.getString('address').toString();
    getListOrder();
  }

  void getListOrder() async {
    var prefs = await SharedPreferences.getInstance();
    this.listOrders = jsonDecode(prefs.getString('list_orders').toString());
    for (var i = 0; i < this.listOrders.length; i++) {
      var postIndexed = this.listOrders[this.listOrders.keys.elementAt(i)];
      var infoOrder = await post(Uri.parse(url_server + '/api/get_info_post'),
          body: {'id_post': postIndexed['id']});
      printedOrders.add(jsonDecode(infoOrder.body));
    }
    setState(() {});
  }

  void editNumberMailAddress() {
    var numberController = TextEditingController(text: phoneNumber);
    var mailController = TextEditingController(text: mail);
    var addressController = TextEditingController(text: address);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Телефон'),
                  SizedBox(height: 5),
                  TextField(
                      controller: numberController,
                      onChanged: (text) {
                        this.phoneNumber = text;
                      },
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
                      onChanged: (text) {
                        this.mail = text;
                      },
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
                      onChanged: (text) {
                        this.address = text;
                      },
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
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                    onPressed: () {
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
          ),
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.all(Radius.circular(15))),
        );
      },
    );
  }

  void editName() {
    var _lastnameController = TextEditingController(text: this.lastname);
    var _firstnameController = TextEditingController(text: this.firstname);
    var _patronymicController = TextEditingController(text: this.patronymic);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Фамилия'),
                    SizedBox(height: 5),
                    TextField(
                        controller: _lastnameController,
                        onChanged: (text) {
                          this.lastname = text;
                        },
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
                        onChanged: (text) {
                          this.firstname = text;
                        },
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
                        onChanged: (text) {
                          this.patronymic = text;
                        },
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
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(15))),
          );
        });
  }

  void orderBuy() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(
              "Отлично!\n Ваш заказ оформлен",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xff4094D0), fontSize: 20),
            ),
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.all(Radius.circular(15))),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDrawerListToBack('Оформление заказа'),
      body: Column(
        children: [
          Expanded(
              child: ListView(
            children: [
              ListTile(
                  title: Text(lastname + ' ' + firstname + ' ' + patronymic),
                  subtitle: Text('Фамилия Имя Отчество'),
                  onTap: () {
                    editName();
                  }),
              Divider(),
              ListTile(
                title: Text(mail),
                subtitle: Text('Электронная почта'),
                onTap: () {
                  editNumberMailAddress();
                },
              ),
              Divider(),
              ListTile(
                  title: Text(address),
                  subtitle: Text('Адрес доставки'),
                  onTap: () {
                    editNumberMailAddress();
                  }),
              Divider(),
              ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      this.listOrders == null ? 0 : this.listOrders.length,
                  itemBuilder: (BuildContext buildContext, int index) {
                    print(printedOrders[index]['0'].toString());
                    return ListTile(
                        title: Text(printedOrders[index]['0']
                                ['manufacturer_name']
                            .toString()),
                        subtitle: Text(printedOrders[index]['0']
                                    ['name_furniture']
                                .toString() +
                            ' (' +
                            this
                                .listOrders[this
                                    .listOrders
                                    .keys
                                    .elementAt(index)]['count']
                                .toString() +
                            ' шт)'));
                  }),
              Row(
                children: [
                  Checkbox(
                    value: _value,
                    fillColor: MaterialStateProperty.all(Color(0xff51AEE7)),
                    onChanged: (value) {
                      setState(() {
                        _value = value!;
                      });
                    },
                  ),
                  Text(
                    'Ознакомлен с условиями офферты',
                    style: TextStyle(color: Color(0xff83868B)),
                  )
                ],
              ),
            ],
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: _value == true
                ? OutlinedButton(
                    onPressed: () async {
                      var response = await post(
                          Uri.parse(url_server + '/api/new_order'),
                          body: {
                            'firstname': this.firstname,
                            'lastname': this.lastname,
                            'patronymic': this.patronymic,
                            'mail': mail,
                            'phone': phoneNumber,
                            'address': address,
                            'listToBuy': jsonEncode(list_to_buy)
                          });
                      response.statusCode == 200 ? orderBuy() : null;
                    },
                    child: Text('Оформить заказ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Color(0xff4094D0),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    child: Text('Оформить заказ',
                        style: TextStyle(
                            color: Color(0xff83868B),
                            fontSize: 20,
                            fontWeight: FontWeight.w400)),
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(
                            Colors.transparent),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.transparent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)))),
                        side: MaterialStateProperty.all<BorderSide>(
                            BorderSide(width: 1.5, color: Color(0xff83868B)))),
                  ),
          )
        ],
      ),
    );
  }
}
