import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:osumpie/partials/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sideNavBorderWidth = 10.0;

class DashboardLayout extends StatefulWidget {
  final Widget tabChild;
  final Widget contentChild;
  final Widget sidenavChild;
  final Widget statusBarChild;

  DashboardLayout({this.sidenavChild, this.tabChild, this.contentChild, this.statusBarChild});

  @override
  _DashboardLayoutState createState() => _DashboardLayoutState(sidenavChild, tabChild, contentChild, statusBarChild);
}

class SideNavBorder extends StatefulWidget {
  final Function onDrag;

  SideNavBorder({Key key, this.onDrag});

  @override
  _SideNavBorderState createState() => _SideNavBorderState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  double width = 200;

  Settings settings;

  final Widget tabChild;
  final Widget sidenavChild;
  final Widget contentChild;
  final Widget statusBarChild;

  _DashboardLayoutState(this.tabChild, this.sidenavChild, this.contentChild, this.statusBarChild);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Sidenav Content
        Positioned(
            left: 0,
            child: Container(
              width: width,
              color: Colors.white70,
              child: widget.sidenavChild,
              height: MediaQuery.of(context).size.height,
            )),
        // Sidenav Border
        Positioned(
            left: width - sideNavBorderWidth / 2,
            child: SideNavBorder(onDrag: (dx, dy) {
              var newWidth = width + dx;
              setState(() => settings.sideNavWidth = width = newWidth > 0 ? newWidth : 0);
            })),
        Positioned(left: width + 10 - sideNavBorderWidth / 2, child: widget.tabChild),
        // Tab Content
        Positioned(
            left: width + 10 - sideNavBorderWidth / 2,
            top: 45,
            child: SizedBox(
                height: MediaQuery.of(context).size.height - 103,
                width: MediaQuery.of(context).size.width - width - 8,
                child: widget.contentChild)),
        // Status Bar
        Positioned(
            bottom: 0,
            child: Container(
                height: 20,
                decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.primaryColor,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(color: Colors.blueGrey[100], blurRadius: 5.0),
                    ]),
                width: MediaQuery.of(context).size.width,
                child: widget.statusBarChild)),
      ],
    );
  }

  void initAsync() async {
    final storage = await SharedPreferences.getInstance();
    settings = Settings(storage);
    setState(() => width = settings.sideNavWidth ?? 200);
  }

  @override
  void initState() {
    initAsync();
    super.initState();
  }
}

class _SideNavBorderState extends State<SideNavBorder> {
  double initX;
  double initY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handleDrag,
      onPanUpdate: _handleUpdate,
      child: Container(
          width: sideNavBorderWidth,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              boxShadow: [
                BoxShadow(color: Colors.blueGrey[50], blurRadius: 15.0),
              ],
              border: Border(
                  left: BorderSide(
                color: Theme.of(context).dividerColor,
              ))),
          child: InkWell(
            onTap: () {},
            mouseCursor: SystemMouseCursors.resizeLeft,
          )),
    );
  }

  void _handleDrag(details) => setState(() {
        initX = details.globalPosition.dx;
        initY = details.globalPosition.dy;
      });

  void _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }
}
