import 'package:flutter/material.dart';
import 'lot_value.dart';

class LOTColorValue extends LOTValue {
  final Color color;

  LOTColorValue.fromHex(String hex) : color = HexColor(hex);
  LOTColorValue.fromColor(Color color) : color = color;

  String get value => '0x${color.value.toRadixString(16).padLeft(8, '0')}';

  LOTValueType get type => LOTValueType.Color;
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
