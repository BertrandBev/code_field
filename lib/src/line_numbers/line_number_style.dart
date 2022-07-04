import 'package:flutter/widgets.dart';

class LineNumberStyle {
  /// Width of the line number column
  final double width;

  /// Alignment of the numbers in the column
  final TextAlign textAlign;

  /// Style of the numbers
  final TextStyle? textStyle;

  /// Background of the line number column
  final Color? background;

  /// Central horizontal margin between the numbers and the code
  final double margin;

  const LineNumberStyle({
    this.width = 42.0,
    this.textAlign = TextAlign.right,
    this.margin = 10.0,
    this.textStyle,
    this.background,
  });
}
