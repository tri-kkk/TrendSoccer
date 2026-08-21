import 'package:flutter/material.dart';

abstract final class TsElevation {
  static const List<BoxShadow> light1 = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x1A101828),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color(0x0F101828),
    ),
  ];

  static const List<BoxShadow> light2 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      color: Color(0x14101828),
    ),
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color(0x0F101828),
    ),
  ];

  static const List<BoxShadow> light3 = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 24,
      color: Color(0x1F101828),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      color: Color(0x14101828),
    ),
  ];

  static const List<BoxShadow> dark2 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color(0x66000000),
    ),
  ];

  static const List<BoxShadow> dark3 = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 32,
      color: Color(0x8F000000),
    ),
  ];

  static const List<BoxShadow> none = [];
}
