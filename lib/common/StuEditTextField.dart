import 'package:flutter/material.dart';

//dimple p
class StuEditTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap; // For fields like date pickers
  final Widget? suffixIcon; // For icons like calendars or dropdowns
  final bool isRequired; // Flag for mandatory field

  const StuEditTextField({
    super.key,
    required this.labelText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.isRequired = false, // Default to not required
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Space between fields
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align label and field
        children: [
          // Label on the left
          SizedBox(
            width: 120, // Adjust the width as needed
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: labelText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // Set font weight to bold
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                  if (isRequired) // Add the red asterisk first if required
                    const TextSpan(
                      text: '* ',
                      style: TextStyle(
                        color: Colors.red, // Asterisk color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
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
              minLines: 1,
              maxLines: 4,
              // Or leave this if single line is enough
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0, // Increased padding
                  horizontal: 10.0,
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
                suffixIcon: suffixIcon,
              ),
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
