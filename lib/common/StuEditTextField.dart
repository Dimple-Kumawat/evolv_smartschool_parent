import 'package:flutter/material.dart';

class StuEditTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap; // For fields like date pickers
  final Widget? suffixIcon; // For icons like calendars or dropdowns

  const StuEditTextField({
    Key? key,
    required this.labelText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Space between fields
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align label and field
        children: [
          // Label on the left
          SizedBox(
            width: 100, // Adjust the width as needed
            child: Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Set font weight to bold
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20), // Space between label and field
          // Input field on the right
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 12.0,
                ), // Adjust inner padding
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
                suffixIcon: suffixIcon, // Add any suffix icon if needed
              ),
              style: const TextStyle(
                fontSize: 14.0, // Input text size
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}