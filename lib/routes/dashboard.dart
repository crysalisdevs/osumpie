import 'package:flutter/material.dart';
import 'package:osumpie/globals.dart';
import 'package:osumpie/partials/widgets/sidenav.dart';

class DashboardRoute extends StatefulWidget {
  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> with SingleTickerProviderStateMixin {
  AnimationController _runAnimationController;
  Map<String, List<Object>> _menus;
  List<String> _menuKeys;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Osum Pie"), actions: [
        for (int i = 0; i < _menus.length; i++)
          FlatButton.icon(
            label: Text(_menuKeys[i]),
            icon: Icon(_menus[_menuKeys[i]][0]),
            onPressed: () => changeTheme(context),
          ),
        IconButton(
          icon: Icon(Icons.brightness_2),
          onPressed: () => changeTheme(context),
        ),
      ]),
      body: Row(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: SideNav(
            child: Column(
              children: [
                Text("Hi"),
              ],
            ),
          )),
          Center(child: Text("Hi"))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: runProject,
          tooltip: 'Run the project',
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: _runAnimationController,
          )),
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
