import 'dart:math';

import 'package:flutter/material.dart';

class DrawerComponent extends StatefulWidget {
  final Widget body;
  final Widget drawer;

  final int maxHeight;
  final int minHeight;

  const DrawerComponent(
      {super.key,
      required this.body,
      required this.drawer,
      required this.maxHeight,
      required this.minHeight});

  @override
  State<DrawerComponent> createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  late int _drawerHeight;
  late bool isOpened;

  @override
  void initState() {
    _drawerHeight = widget.maxHeight;
    isOpened = true;
    super.initState();
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    var deltaX = details.delta.dy.toInt();
    setState(() {
      _drawerHeight =
          min(max(_drawerHeight - deltaX, widget.minHeight), widget.maxHeight);
      isOpened = (_drawerHeight >=
          (widget.maxHeight - widget.minHeight) / 2 + widget.minHeight);
    });
  }

  void onVerticalDragEnd(DragEndDetails details) {
    if (isOpened) {
      setState(() {
        _drawerHeight = widget.maxHeight;
      });
    } else {
      setState(() {
        _drawerHeight = widget.minHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var children = <Widget>[];

    children.addAll([
      AnimatedPositioned(
          duration: const Duration(milliseconds: 150),
          top: 0,
          left: 0,
          right: 0,
          bottom: _drawerHeight.toDouble(),
          child: widget.body),
      Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
              onTap: () {},
              onVerticalDragUpdate: onVerticalDragUpdate,
              onVerticalDragEnd: onVerticalDragEnd,
              child: AnimatedContainer(
                  height: _drawerHeight.toDouble(),
                  width: mediaQuery.size.width,
                  padding: const EdgeInsets.all(8),
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 150),
                  child: widget.drawer))),
    ]);
    return Stack(
        alignment: AlignmentDirectional.centerStart, children: children);
  }
}
