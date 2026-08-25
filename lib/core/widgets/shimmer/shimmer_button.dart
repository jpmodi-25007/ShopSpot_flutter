import 'package:flutter/material.dart';

class ShimmerButton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerButton({
    super.key,
    this.width = double.infinity,
    this.height = 56.0,
    this.borderRadius = 12.0, // Common button radius in this app
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
