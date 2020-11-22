import 'package:flutter/material.dart';
import 'package:osumpie/routes/recipe_editor.dart';

import 'routes/hardware_monitor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, Object> osumTabs = {
  "Receipe Editor": RecipeEditor(),
};

Map<String, List<Object>> menus = {
  "Stat": [Icons.hardware, HardwareMonitorRoute()],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};
