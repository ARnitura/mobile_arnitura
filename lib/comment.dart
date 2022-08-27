import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  Comment({Key? key}) : super(key: key);

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Row(children: [Image.network('src'), Text('')],);
            },
          ),
        ));
  }
}
