import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:osumpie/partials/settings.dart';
import 'package:osumpie/partials/widgets/dash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardRoute extends StatefulWidget {
  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> with SingleTickerProviderStateMixin {
  AnimationController _runAnimationController;
  Map<String, List<Object>> _menus;
  List<String> _menuKeys;

  Settings settings;

  void initAsync() async {
    final storage = await SharedPreferences.getInstance();
    settings = Settings(storage);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text("Osum Pie"), actions: [
          for (int i = 0; i < _menus.length; i++)
            FlatButton.icon(
              label: Text(_menuKeys[i]),
              icon: Icon(_menus[_menuKeys[i]][0]),
              onPressed: () => null,
            ),
          IconButton(
              icon: Icon(Icons.brightness_2),
              onPressed: () => DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                  )),
        ]),
        body: DashboardLayout(
          contentChild: TabBarView(
            children: [Icon(Icons.directions_car), Icon(Icons.directions_transit), Icon(Icons.directions_bike)],
          ),
          tabChild: TabBar(
            isScrollable: true,
            tabs: [
              for (int i = 0; i < 3; i++)
                Tab(
                    child: Row(children: [
                  Icon(Icons.file_copy, size: 15.0),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
                      child: Text("Test", style: TextStyle(fontSize: 15.0))),
                  IconButton(
                      splashRadius: 10.0,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close),
                      iconSize: 16.0,
                      onPressed: () {})
                ])),
            ],
          ),
          sidenavChild: Column(children: [
            Text("Hi"),
          ]),
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
          child: FloatingActionButton(
              onPressed: runProject,
              tooltip: 'Run the project',
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _runAnimationController,
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _runAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initAsync();
    if (_menus == null)
      _menus = {
        "File": [Icons.file_copy, null],
        "Edit": [Icons.edit, null],
        "View": [Icons.view_carousel, null],
        "Run": [Icons.play_arrow, null],
        "Help": [Icons.help, null],
      };
    _menuKeys = _menus.keys.toList();
    _runAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
  }

  void runProject() {
    if (_runAnimationController.isCompleted)
      _runAnimationController.reverse();
    else
      _runAnimationController.forward();
  }
}
