import 'package:flutter/material.dart';

class ViewProjectContentScreen extends StatefulWidget {
  @override
  _ViewProjectContentScreenState createState() =>
      _ViewProjectContentScreenState();
}

class _ViewProjectContentScreenState extends State<ViewProjectContentScreen> {
  PageController _controller = PageController(
    initialPage: 0,
  );

  List<Scaffold> scaffolds = [];

  @override
  Widget build(BuildContext context) {
    //TODO: Implement a pageview controller

    return PageView(
      controller: _controller,
      children: scaffolds,
    );
  }
}
