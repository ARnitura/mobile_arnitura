import 'package:flutter/material.dart';
import 'image_sort.dart';

class GridSearch extends StatefulWidget {
  var data;
  var indexGL;

  GridSearch({Key? key, required this.data, this.indexGL}) : super(key: key);

  @override
  State<GridSearch> createState() => _GridSearchState();
}

class _GridSearchState extends State<GridSearch> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        primary: false,
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 3,
            childAspectRatio: 0.7),
        itemBuilder: (BuildContext context, int index) {
          return widget
                      .data['${widget.indexGL + 1}'][index.toString()].length ==
                  null
              ? Text('Товаров нет')
              : ImageSort(
                  link_image: widget.data['${widget.indexGL + 1}']
                      [index.toString()]['photo'],
                  manufacturer_id: widget.data['${widget.indexGL + 1}']
                          [index.toString()]['manufacturer_id']
                      .toString(),
                  name: 'test',
                  cell: widget.data['${widget.indexGL + 1}'][index.toString()]
                          ['price']
                      .toString());
        },
        itemCount: widget.data['${widget.indexGL + 1}'] != null
            ? widget.data['${widget.indexGL + 1}'].length
            : 0);
  }
}
