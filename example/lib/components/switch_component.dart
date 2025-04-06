import 'package:flutter/material.dart';

class SwitchComponent extends StatefulWidget {
  final String title;
  final void Function(bool) onChanged;
  final bool initialValue;
  final TextStyle? textStyle;

  const SwitchComponent(
      {super.key,
      required this.title,
      required this.onChanged,
      this.initialValue = false,
      this.textStyle});

  @override
  State<SwitchComponent> createState() => _SwitchComponentState();
}

class _SwitchComponentState extends State<SwitchComponent> {
  late bool value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(widget.title, style: widget.textStyle),
        Switch(
            value: value,
            onChanged: (value) {
              setState(() {
                this.value = value;
              });
              widget.onChanged(value);
            })
      ]);
}
