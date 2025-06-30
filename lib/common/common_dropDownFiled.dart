import 'package:flutter/material.dart';

class LabeledDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final bool readOnly;
  final Function(String?) onChanged;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.onChanged,
    this.readOnly = false,
    this.selectedValue,
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
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.black,
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
                              : null,
                  icon: readOnly ? null : const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: options.isNotEmpty
                      ? options.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16.0,
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
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                  onChanged: readOnly ? null : onChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
