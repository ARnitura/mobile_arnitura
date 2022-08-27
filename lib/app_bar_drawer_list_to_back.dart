import 'package:flutter/material.dart';

class AppBarDrawerListToBack extends StatefulWidget
    implements PreferredSizeWidget {
  String title;

  AppBarDrawerListToBack(this.title, {Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  State<AppBarDrawerListToBack> createState() => _AppBarDrawerListToBackState();
}

class _AppBarDrawerListToBackState extends State<AppBarDrawerListToBack> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Align(
        child: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        alignment: Alignment.centerLeft,
      ),
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.transparent,
      bottomOpacity: 0,
      elevation: 0,
    );
  }
}
