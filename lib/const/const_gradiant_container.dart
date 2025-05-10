import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget? child;  // Optional child widget
  final double height;  // Optional height
  final double width;   // Optional width

  const GradientContainer({
    super.key,
    this.child,
    this.height = double.infinity,  // Default to full height if not specified
    this.width = double.infinity,   // Default to full width if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
