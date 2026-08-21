import 'package:flutter/material.dart';

abstract final class TsRadius {
  static const double xsValue = 4;
  static const double smValue = 8;
  static const double mdValue = 12;
  static const double fullValue = 999;

  static const BorderRadius xs = BorderRadius.all(Radius.circular(xsValue));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(smValue));
  static const BorderRadius md = BorderRadius.all(Radius.circular(mdValue));
  static const BorderRadius full = BorderRadius.all(Radius.circular(fullValue));

  static const double xlValue = 20;
  static const BorderRadius xl = BorderRadius.all(Radius.circular(xlValue));
  static const BorderRadius topXl = BorderRadius.vertical(
    top: Radius.circular(xlValue),
  );
}
