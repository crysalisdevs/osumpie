import 'dart:io';

import 'package:flutter/material.dart';
import 'package:osumpie/routes/recipe_editor.dart';

import 'partials/widgets/node_widget.dart';
import 'routes/hardware_monitor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, Object> osumTabs = {
  "Receipe Editor": RecipeEditor(file: File('test.json')),
};

Map<String, List<Object>> menus = {
  "Stat": [Icons.hardware, HardwareMonitorRoute()],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};

List<NodeBlock> selectedForLines = [];
