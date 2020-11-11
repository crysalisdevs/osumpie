import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:osumpie/partials/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sideNavBorderWidth = 10.0;

class SideNav extends StatefulWidget {
  SideNav({this.child});

  final Widget child;
  @override
  _SideNavState createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  double width = 200;
  double left = 0;

  Settings settings;

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
            left: left,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: width,
              color: Colors.white70,
              child: widget.child,
            )),
        Positioned(
            left: left,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: width,
              child: widget.child,
            )),
        Positioned(
            left: left + width - sideNavBorderWidth / 2,
            child: SideNavBorder(onDrag: (dx, dy) {
              var newWidth = width + dx;
              setState(() => settings.sideNavWidth = width = newWidth > 0 ? newWidth : 0);
            })),
      ],
    );
  }
}

class SideNavBorder extends StatefulWidget {
  SideNavBorder({Key key, this.onDrag});

  final Function onDrag;

  @override
  _SideNavBorderState createState() => _SideNavBorderState();
}

class _SideNavBorderState extends State<SideNavBorder> {
  double initX;
  double initY;

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
}
