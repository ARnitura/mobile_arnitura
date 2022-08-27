import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:arnituramobile/globals.dart';

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
  var avatar = '';
  var id = '';

  @override
  void initState() {
    super.initState();
    getInfoUserLocal();
  }

  edit_info_user(number, mail, address) async {
    var res = await post(
        Uri.parse(url_server + '/api/edit_info_user'),
        body: {
          'user_id': id,
          'number': number.text,
          'mail': mail.text,
          'address': address.text
        });
    if (res.statusCode == 200) {
      var prefs = await SharedPreferences.getInstance();
      setState(() {
        prefs.setString('phone',  number.text);
        prefs.setString('mail', mail.text);
        prefs.setString('address', address.text);
        this.phoneNumber = number.text;
        this.mail = mail.text;
        this.address = address.text;
      });
    }
  } // Редактирование информации о пользователе

  edit_fullname_user(lastname, firstname, patronymic) async {
    var res = await post(
        Uri.parse(url_server + '/api/edit_fullname_user'),
        body: {
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
  }  // Редактирование ФИО о пользователе

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
                          edit_info_user(
                              numberController.value,
                              mailController.value,
                              addressController.value);
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
      avatar = prefs.getString('avatar')!;
      phoneNumber = prefs.getString('phone')!;
      mail = prefs.getString('mail')!;
      address = prefs.getString('address')!;
    });
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
                      Image.asset(
                        'assets/image/photo_lk.png',
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
                            onPressed: () {},
                          ),
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
