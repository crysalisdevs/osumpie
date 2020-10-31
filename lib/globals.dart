import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

Brightness globalBrightness = Brightness.light;

void changeTheme(BuildContext context) {
  DynamicTheme.of(context).setBrightness(
    Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
  );
}
