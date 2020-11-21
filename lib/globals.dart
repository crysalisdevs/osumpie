import 'package:flutter/material.dart';

import 'routes/hardware_monitor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, Object> osumTabs = {};

Map<String, List<Object>> menus = {
  "Stat": [Icons.hardware, HardwareMonitorRoute()],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};
