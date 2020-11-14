/// Dashboard layout UI

import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:osumpie/partials/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const sideNavBorderWidth = 10.0;

class DashboardLayout extends StatefulWidget {
  final Widget tabChild;
  final Widget contentChild;
  final Widget sidenavChild;
  final Widget statusBarChild;
  final Widget sidenavIconsChild;

  DashboardLayout({this.sidenavChild, this.tabChild, this.contentChild, this.statusBarChild, this.sidenavIconsChild});

  @override
  _DashboardLayoutState createState() =>
      _DashboardLayoutState(sidenavChild, tabChild, contentChild, statusBarChild, sidenavIconsChild);
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
  final Widget sidenavIconsChild;

  _DashboardLayoutState(
      this.tabChild, this.sidenavChild, this.contentChild, this.statusBarChild, this.sidenavIconsChild);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Sidenav Content
        Positioned(
            left: 0,
            child: SlideInLeft(
              child: Container(
                width: width,
                color: DynamicTheme.of(context).data.canvasColor,
                child: widget.sidenavChild,
                height: MediaQuery.of(context).size.height,
              ),
            )),
        // Icon Bar
        Positioned(
            left: 0,
            child: SlideInLeft(
              child: Container(
                width: 55,
                decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.appBarTheme.color,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(color: DynamicTheme.of(context).data.appBarTheme.shadowColor, blurRadius: 8.0),
                    ]),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(3, 8, 8, 8),
                  child: widget.sidenavIconsChild,
                ),
                height: MediaQuery.of(context).size.height,
              ),
            )),
        // Sidenav Border
        Positioned(
            left: width - sideNavBorderWidth / 2,
            child: SlideInLeft(
              child: SideNavBorder(onDrag: (dx, dy) {
                var newWidth = width + dx;
                setState(() => settings.sideNavWidth = width = newWidth > 0 ? newWidth : 0);
              }),
            )),
        // Tabs
        Positioned(
            left: width + 10 - sideNavBorderWidth / 2,
            child: SlideInDown(
              child: widget.tabChild,
            )),
        // Tab Content
        Positioned(
            left: width + 10 - sideNavBorderWidth / 2,
            top: 45,
            child: FadeIn(
              preferences: AnimationPreferences(offset: Duration(seconds: 1)),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height - 103,
                  width: MediaQuery.of(context).size.width - width - 8,
                  child: widget.contentChild),
            )),
        // Status Bar
        Positioned(
            bottom: 0,
            child: SlideInUp(
              child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                      color: DynamicTheme.of(context).data.primaryColor,
                      shape: BoxShape.rectangle,
                      boxShadow: [
                        BoxShadow(color: DynamicTheme.of(context).data.appBarTheme.shadowColor, blurRadius: 5.0),
                      ]),
                  width: MediaQuery.of(context).size.width,
                  child: widget.statusBarChild),
            )),
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
                BoxShadow(
                  color: DynamicTheme.of(context).data.appBarTheme.shadowColor.withOpacity(0.4),
                  blurRadius: 8.0,
                ),
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
