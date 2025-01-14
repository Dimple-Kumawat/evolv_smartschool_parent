import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StuTextField extends StatelessWidget {
  final String label;
  final String name;
  final bool readOnly;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool showRedAsterisk; // New parameter to control red asterisk

  const StuTextField({
    Key? key,
    required this.name,
    this.initialValue,
    this.readOnly = false,
    this.onChanged,
    required this.label,
    this.showRedAsterisk = false, // Default value is false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust padding for space between fields
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label with optional red asterisk
          SizedBox(
            width: 100, // Adjust the width to align labels and fields properly
            child: RichText(
              text: TextSpan(
                children: [
                  if (showRedAsterisk)
                    const TextSpan(
                      text: '* ',
                      style: TextStyle(
                        
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20), // Space between label and field
          // Form Field
          Expanded(
            child: FormBuilderTextField(
              name: name,
              readOnly: readOnly,
              initialValue: initialValue,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded border
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
              style: const TextStyle(
                fontSize: 14.0, // Input text size
              ),
             
            ),
          ),
        ],
      ),
    );
  }
}
