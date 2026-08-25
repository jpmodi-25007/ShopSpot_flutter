import 'package:flutter/material.dart';

class ShimmerImage extends StatelessWidget {
  final double? width;
  final double? height;
  final double aspectRatio;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerImage({
    super.key,
    this.width,
    this.height,
    this.aspectRatio = 1.0,
    this.borderRadius = 0.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContainer = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    // If both width and height are provided, we don't strictly need AspectRatio 
    // unless we want to enforce it. For maximum flexibility, if AspectRatio is specified 
    // but we only have width or are bounded by a parent, AspectRatio widget helps maintain the shape.
    if (width == null || height == null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: imageContainer,
      );
    }

    return imageContainer;
  }
}
