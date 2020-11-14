import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:osumpie/partials/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sideNavBorderWidth = 10.0;

class DashboardLayout extends StatefulWidget {
  final Widget tabChild;
  final Widget contentChild;
  final Widget sidenavChild;

  DashboardLayout({this.sidenavChild, this.tabChild, this.contentChild});

  @override
  _DashboardLayoutState createState() => _DashboardLayoutState(sidenavChild, tabChild, contentChild);
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

  _DashboardLayoutState(this.tabChild, this.sidenavChild, this.contentChild);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
            left: 0,
            child: Container(
              width: width,
              color: Colors.white70,
              child: widget.sidenavChild,
              height: MediaQuery.of(context).size.height,
            )),
        Positioned(
            left: width - sideNavBorderWidth / 2,
            child: SideNavBorder(onDrag: (dx, dy) {
              var newWidth = width + dx;
              setState(() => settings.sideNavWidth = width = newWidth > 0 ? newWidth : 0);
            })),
        Positioned(
          left: width + 10 - sideNavBorderWidth / 2,
          child: widget.tabChild,
        ),
        Positioned(
          left: width + 10 - sideNavBorderWidth / 2,
          top: 45,
          child: SizedBox(
            height: 500,
            width: width + 10 - sideNavBorderWidth,
            child: widget.contentChild,
          ),
        ),
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
