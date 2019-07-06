import 'lot_value.dart';

class LOTOpacityValue extends LOTValue {
  final double opacity;

  LOTOpacityValue(this.opacity);

  String get value => opacity.toString();

  LOTValueType get type {
    return LOTValueType.Opacity;
  }
}
