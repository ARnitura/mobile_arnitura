import 'package:flutter/material.dart';

import 'globals.dart';

class ImageSort extends StatefulWidget {
  final String link_image;
  final String manufacturer_id;
  final String name;
  final String cell;

  ImageSort(
      {Key? key,
      required this.link_image,
      required this.manufacturer_id,
      required this.name,
      required this.cell})
      : super(key: key);

  @override
  State<ImageSort> createState() => _ImageSortState();
}

class _ImageSortState extends State<ImageSort> {
  @override
  Widget build(BuildContext context) {
    print(widget.link_image.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(url_server + '/api/get_photos?id=' +
              widget.manufacturer_id.toString() +
              '&photo_name=' +
              widget.link_image),
        ),
        Text(
          widget.name,
          style: TextStyle(color: Color(0xff4094D0)),
        ),
        Text(
          widget.cell,
          style: TextStyle(color: Color(0xff555555)),
        ),
      ],
    );
  }
}
