
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuInfo {
  final String id;
  final String title;
  final String description;
  final IconData? icon;

  MenuInfo(this.id, this.title, this.description, [this.icon]);

  Widget? get iconWidget => icon != null ? FaIcon(icon) : null;
}