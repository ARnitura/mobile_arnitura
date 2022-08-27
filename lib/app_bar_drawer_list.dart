import 'package:flutter/material.dart';

class AppBarDrawerList extends StatefulWidget implements PreferredSizeWidget {
  String title;

  AppBarDrawerList(this.title, {Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  State<AppBarDrawerList> createState() => _AppBarDrawerListState();
}

class _AppBarDrawerListState extends State<AppBarDrawerList> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Color(0xFF83868B)),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
              color: Color(0xFF83868B),
              size: 30, // Changing Drawer Icon Size
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          );
        },
      ),
      backgroundColor: Colors.transparent,
      bottomOpacity: 0,
      elevation: 0,
      actions: [
        Image.asset(
          'assets/image/logo_appbar.png',
          width: 100,
        ),
        const SizedBox(
          width: 10,
        )
      ],
    );
  }
}
