import 'package:flutter/material.dart';

/// Root navigator keys shared by routing and deep-link handlers.
abstract final class NavigatorKeys {
  static final GlobalKey<NavigatorState> root =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> shell =
      GlobalKey<NavigatorState>(debugLabel: 'shell');
}
