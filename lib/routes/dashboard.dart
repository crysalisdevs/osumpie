import 'package:flutter/material.dart';
import 'package:osumpie/globals.dart';
import 'package:osumpie/partials/widgets/sidenav.dart';

class DashboardRoute extends StatefulWidget {
  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> with SingleTickerProviderStateMixin {
  AnimationController runAnimationController;

  @override
  void initState() {
    super.initState();
    runAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    runAnimationController.dispose();
    super.dispose();
  }

  void runProject() {
    if (runAnimationController.isCompleted)
      runAnimationController.reverse();
    else
      runAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Osum Pie"), actions: [
        IconButton(
          icon: Icon(Icons.brightness_2),
          onPressed: () => changeTheme(context),
        )
      ]),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: SideNav(
            child: Column(
              children: [
                Text("Hi"),
              ],
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: runProject,
          tooltip: 'Run the project',
          child: AnimatedIcon(
            icon: AnimatedIcons.play_pause,
            progress: runAnimationController,
          )),
    );
  }
}
