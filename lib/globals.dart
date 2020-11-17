import 'package:flutter/material.dart';

import 'routes/hardware_monitor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, Object> osumTabs = {
  "Hardware Monitor": HardwareMonitorRoute(),
  "Check2": Text("Hello"),

};
Map<String, List<Object>> menus = {
  "File": [Icons.file_copy, null],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};
