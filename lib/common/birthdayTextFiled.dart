import 'package:flutter/material.dart';

class BirthdatTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap; // For fields like date pickers
  final Widget? suffixIcon; // For icons like calendars or dropdowns
  final TextEditingController controller; // Accept controller as parameter

  const BirthdatTextField({
    Key? key,
    required this.labelText,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    required this.controller, // Receive controller here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextFormField(
              controller: controller, // Use passed controller here
              keyboardType: keyboardType,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
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