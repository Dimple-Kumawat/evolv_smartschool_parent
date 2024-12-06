import 'package:flutter/material.dart';

class LabeledDropdown1 extends StatelessWidget {
  final String label1;
  final List<String> options1;
  final void Function(String?) onChanged1;

  LabeledDropdown1({
    required this.label1,
    required this.options1,
    required this.onChanged1,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label1,
        border: OutlineInputBorder(),
      ),
      value: options1.contains(label1.split(' : ')[1]) ? label1.split(' : ')[1] : options1.first,
      onChanged: onChanged1,
      items: options1.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}