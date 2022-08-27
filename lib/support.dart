import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_bar_drawer_list_to_back.dart';

class SupportWidget extends StatefulWidget {
  const SupportWidget({Key? key}) : super(key: key);

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<SupportWidget> {

  _launchURL(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDrawerListToBack('Техподдержка'),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                launch("tel://+7 922 775-33-90");
              },
              title: Text('+7 922 775-33-90'),
              subtitle: Text('Позвонить по телефону'),
            ),
            ListTile(
                subtitle: const Text('Отправить сообщение через менеджер'),
                title: Row(
                  children: [
                    IconButton(
                        onPressed: () async =>
                            await launch("https://t.me/zkgerman"),
                        icon: Image.asset('assets/image/telega_icon.png'),
                        iconSize: 40.0),
                    IconButton(
                        onPressed: () async => await launch(
                            "https://wa.me/+79227753390?text=Здравствуйте!"),
                        icon: Image.asset('assets/image/whatsapp_icon.png'),
                        iconSize: 40.0),
                    IconButton(
                        onPressed: () async =>
                            await launch("viber://chat?number=%2B79227753390"),
                        icon: Image.asset('assets/image/viber_icon.png'),
                        iconSize: 40.0)
                  ],
                )),
            ListTile(
              onTap: () {
                _launchURL('german214@yandex.ru', 'Сообщение в техподдержку arnitura', '');
              },
                title: Text('pocta@kreslo.com'),
                subtitle: Text('Отправить e-mail'))
          ],
        ),
      ),
    );
  }
}
