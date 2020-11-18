import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:osumpie/routes/hardware_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../partials/settings.dart';
import '../partials/widgets/dash.dart';
import '../partials/widgets/tabs.dart';

class DashboardRoute extends StatefulWidget {
  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> with SingleTickerProviderStateMixin {
  AnimationController _runAnimationController;
  Settings settings;

  @override
  Widget build(BuildContext context) {
    final menuKeys = menus.keys.toList();
    return DefaultTabController(
      length: osumTabs.length,
      child: Scaffold(
        appBar: AppBar(title: Text("Osum Pie"), actions: [
          for (int i = 0; i < menus.length; i++)
            SlideInDown(
                child: FlatButton.icon(
                    label: Text(menuKeys[i]),
                    icon: Icon(menus[menuKeys[i]][0]),
                    onPressed: () {
                      setState(
                        () => osumTabs.addAll({"Stat": HardwareMonitorRoute()}),
                      );
                    })),
          SlideInDown(
            child: IconButton(
                icon: Icon(Icons.brightness_2),
                onPressed: () => DynamicTheme.of(context).setBrightness(
                      Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                    )),
          ),
        ]),
        body: DashboardLayout(
          contentChild: TabBarView(children: loadTabContent(setState)),
          tabChild: TabBar(isScrollable: true, tabs: loadTabs(setState)),
          sidenavChild: Column(children: [Text("Hi")]),
          sidenavIconsChild: Column(
            children: [
              for (int i = 0; i < 5; i++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: IconButton(
                    color: DynamicTheme.of(context).data.appBarTheme.iconTheme.color,
                    icon: Icon(Icons.file_copy, size: 30),
                    onPressed: () {},
                  ),
                )
            ],
          ),
          statusBarChild: Row(
            children: [
              Icon(Icons.done, color: Colors.white, size: 15),
              Padding(
                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: Text("Ready", style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: BounceIn(
            child: FloatingActionButton(
                onPressed: runProject,
                tooltip: 'Run the project',
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _runAnimationController,
                )),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _runAnimationController.dispose();
    super.dispose();
  }

  void initAsync() async {
    final storage = await SharedPreferences.getInstance();
    settings = Settings(storage);
  }

  @override
  void initState() {
    super.initState();
    initAsync();
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  void runProject() {
    if (_runAnimationController.isCompleted)
      _runAnimationController.reverse();
    else
      _runAnimationController.forward();
  }
}
