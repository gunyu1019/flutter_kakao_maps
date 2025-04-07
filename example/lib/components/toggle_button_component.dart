// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';

class ToggleButtonComponent extends StatefulWidget {
  final List<String> options;
  final int defaultSelection;
  final void Function(int) onChanged;

  const ToggleButtonComponent({
    super.key,
    required this.options,
    required this.onChanged,
    this.defaultSelection = 0,
  });

  @override
  State<ToggleButtonComponent> createState() => _ToggleButtonComponentState();
}

class _ToggleButtonComponentState extends State<ToggleButtonComponent> {
  late List<bool> _selectedButton;

  @override
  void initState() {
    _selectedButton = List.filled(widget.options.length, false);
    _selectedButton[widget.defaultSelection] = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => ToggleButtons(
      direction: Axis.vertical,
      isSelected: _selectedButton,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      selectedBorderColor: const Color.fromARGB(255, 19, 137, 253),
      selectedColor: Colors.white,
      fillColor: const Color.fromARGB(255, 19, 137, 253),
      color: Colors.black,
      onPressed: (index) {
        widget.onChanged(index);
        setState(() {
          for (int i = 0; i < _selectedButton.length; i++) {
            _selectedButton[i] = i == index;
          }
        });
      },
      children: widget.options.map((e) => Text(e)).toList());
}
