import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../partials/settings.dart';
import '../partials/widgets/dash.dart';
import '../partials/widgets/sidenav_explorer.dart';
import '../partials/widgets/tabs.dart';
import '../routes/hardware_monitor.dart';

/// The main dashboard route which holds the dashboard widget.
class DashboardRoute extends StatefulWidget {
  DashboardRoute({Key key}) : super(key: key);

  @override
  _DashboardRouteState createState() => _DashboardRouteState();
}

class _DashboardRouteState extends State<DashboardRoute> with AutomaticKeepAliveClientMixin {
  /// Contains the application's global settings.
  Settings _settings;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final menuKeys = menus.keys.toList();

    return DefaultTabController(
      length: osumTabs.length,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: isDesktop ? 40.0 : null, title: Text("Osum Pie"), actions: [
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
          tabChild: SizedBox(
              width: _settings != null
                  ? MediaQuery.of(context).size.width + 10 - _settings.sideNavWidth / 2
                  : MediaQuery.of(context).size.width,
              child: CupertinoScrollbar(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                child: TabBar(
                  physics: const BouncingScrollPhysics(),
                  isScrollable: true,
                  tabs: loadTabs(setState),
                ),
              ))),
          sidenavChild: SideNavExplorer(setStateRoot: setState),
          sidenavIconsChild: Column(
            children: [
              for (int i = 0; i < 5; i++)
                Padding(
                  padding: isDesktop ? const EdgeInsets.fromLTRB(0, 0, 0, 12) : const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: IconButton(
                    color: DynamicTheme.of(context).data.appBarTheme.iconTheme.color,
                    icon: Icon(Icons.file_copy, size: isDesktop ? 25.0 : 30.0),
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
      ),
    );
  }

  /// Loading the start up logic for dashboard.
  void initAsync() async {
    // Load the settings
    final storage = await SharedPreferences.getInstance();
    setState(() => _settings = Settings(storage));
    // Setup up for BSI
    // await Mqtt().initialize(
    //     using: MqttConnection.from(
    //   service: OsumPieService.instance.reference,
    //   broker: "127.0.0.1",
    //   port: 1883,
    // ));
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }
}
