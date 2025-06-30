import 'package:flutter/material.dart';

class HashLabeledDropdown extends StatelessWidget {
  final String label;
  final bool readOnly;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;
  final bool isRequired;

  const HashLabeledDropdown({
    super.key,
    required this.label,
    required this.options,
    this.readOnly = false,
    required this.onChanged,
    this.selectedValue,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
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
                  if (isRequired)
                    const TextSpan(
                      text: '* ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:
                      selectedValue != null && options.contains(selectedValue)
                          ? selectedValue
                          : options.isNotEmpty
                              ? options.first
                              : null, // Fallback to null if options is empty
                  icon: readOnly
                      ? null
                      : const Icon(
                          Icons.arrow_drop_down), // Hide icon if readOnly
                  isExpanded: true,
                  items: options.isNotEmpty
                      ? options.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text(
                              'No options available',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                  onChanged: readOnly ? null : onChanged, // Disable if readOnly
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
