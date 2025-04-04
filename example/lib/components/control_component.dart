import 'package:flutter/material.dart';
import 'package:kakao_map_sdk_example/components/dropdown.dart';

mixin ControlComponent {
  Widget slider(String title, double value, void Function(double) onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: controllerTitleText, textAlign: TextAlign.start),
        Text(value.toString(), style: controllerValueText, textAlign: TextAlign.end)
      ]),
      Slider(value: value, onChanged: onChanged)
    ]
  );

  Widget checkbox(String title, bool value, void Function(bool?) onChanged) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: controllerTitleText),
      Checkbox(value: value, onChanged: onChanged)
    ],
  );

  Widget dropbox(String title, List<String> values, int initialValue, void Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: controllerTitleText, textAlign: TextAlign.start),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: double.infinity,
          child: Dropdown(
            values: values,
            onChanged: onChanged,
            initialValue: initialValue,
          )
        )
      ],
    );
  }


  final controllerTitleText = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.bold);
  final controllerValueText = const TextStyle(
      fontSize: 16, color: Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.normal);
}
