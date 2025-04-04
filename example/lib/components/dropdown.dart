// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    required this.values,
    required this.onChanged,
    this.initialValue = 0,
  });

  final List<String> values;
  final int initialValue;
  final void Function(int) onChanged;

  @override
  State<StatefulWidget> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  int selectedValue = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedValue = widget.initialValue;
    });
  }

  @override
  Widget build(BuildContext context) => DropdownButton(
    isExpanded: true,
    value: selectedValue,
    items: widget.values
      .mapIndexed((index, element) => DropdownMenuItem(
        value: index,
        child: Text(element),
      )).toList(),
    onChanged: (value) {
      widget.onChanged(value!);
      setState(() {
        selectedValue = value;
      });
    },
  );
}