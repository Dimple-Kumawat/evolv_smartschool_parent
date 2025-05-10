import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
class CustomTextField extends StatelessWidget {
  final String label;
  final String name;
  final bool readOnly;
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.name,
    this.initialValue,
    this.readOnly = false,
    this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name,
      readOnly: readOnly,
      initialValue: initialValue,
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        label: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
             // fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black, // Default label color
            ),
            children: [
              const TextSpan(
                text: ' *',  // Added space before the asterisk
                style: TextStyle(
                  color: Colors.red, // Color for the asterisk
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
     // onChanged: onChanged,
    );
  }
}
