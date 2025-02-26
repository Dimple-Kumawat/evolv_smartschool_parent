import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class StuTextField extends StatelessWidget {
  final String label;
  final String name;
  final bool readOnly;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool showRedAsterisk;

  const StuTextField({
    Key? key,
    required this.name,
    this.initialValue,
    this.readOnly = false,
    this.onChanged,
    required this.label,
    this.showRedAsterisk = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Fixed width for label with RichText
          SizedBox(
            width: 120, // Ensures proper alignment
            child: RichText(
              text: TextSpan(
                children: [

                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                  if (showRedAsterisk)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              // overflow: TextOverflow.ellipsis, // Prevents text overflow issues
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
                  borderRadius: BorderRadius.circular(10.0),
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
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}