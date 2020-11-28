import 'dart:io';

import 'package:flutter/material.dart';

import 'routes/hardware_monitor.dart';
import 'routes/recipe_editor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, List<Object>> menus = {
  "Stat": [Icons.hardware, HardwareMonitorRoute()],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};

Map<String, Object> osumTabs = {
  "Receipe Editor": RecipeEditor(file: File('test.json')),
};
