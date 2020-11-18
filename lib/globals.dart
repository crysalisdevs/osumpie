import 'package:flutter/material.dart';
import 'package:osumpie/routes/revision_history.dart';

import 'routes/hardware_monitor.dart';

Brightness globalBrightness = Brightness.light;

Map<String, Object> osumTabs = {
  "Hardware Monitor": HardwareMonitorRoute(),
  "Check2": Text("Hello"),
  "File History main.dart": RevisionHistory()
};

Map<String, List<Object>> menus = {
  "Stat": [Icons.hardware, HardwareMonitorRoute()],
  "Edit": [Icons.edit, null],
  "View": [Icons.view_carousel, null],
  "Run": [Icons.play_arrow, null],
  "Help": [Icons.help, null],
};
