import 'package:flutter/material.dart';

class SimpleDropdown extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;

  const SimpleDropdown({
    Key? key,
    required this.options,
    required this.onChanged,
    this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Light background color like the image
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4.0), // Small border radius for a rounded look
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          icon: const Icon(
            Icons.arrow_drop_down, // Dropdown arrow icon
            color: Colors.grey,
          ),
          isExpanded: true, // Ensure the dropdown expands to fill the width
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
/*
SimpleDropdown(
          options: houseNameMapping.values.toList(), // List of house names
          selectedValue: selectedHouseName,
          onChanged: (String? newValue) {
            setState(() {
              selectedHouseName = newValue;
              // Find and set the house ID corresponding to the selected house name
              selectedHouseId = houses.firstWhere(
                  (house) => house['house_name'] == newValue)['house_id'];
            });
          },
        ),
        */