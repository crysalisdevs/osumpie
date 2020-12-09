import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../partials/widgets/loading_msg.dart';

/// Display all the hardware metrics in a widget
class HardwareMonitorRoute extends StatefulWidget {
  HardwareMonitorRoute({Key key}) : super(key: key);

  @override
  _HardwareMonitorRouteState createState() => _HardwareMonitorRouteState();
}

class _HardwareMonitorRouteState extends State<HardwareMonitorRoute> {
  /*
    The reason for going with two list views instead of going for one grid view is
    because flutter does not allow each child widget to have different sizes inside
    a grid view. To work around this, the widgets are wrapped within two list views
    and share the same scroll controller for even scrolling.
  */
  ScrollController _monitorStateScrollControllerLeft;
  ScrollController _monitorStateScrollControllerRight;

  final _monitorStateScrollController = LinkedScrollControllerGroup();
  final _metrics = ["CPU", "GPU", "TEMP", "RAM", "ROM", "POWER"];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadMonitorData(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return Row(children: [
            Expanded(
                child: buildMonitorList(
              controller: _monitorStateScrollControllerLeft,
            )),
            Expanded(
              child: DraggableScrollbar.semicircle(
                  controller: _monitorStateScrollControllerRight,
                  alwaysVisibleScrollThumb: true,
                  child: buildMonitorList(
                    controller: _monitorStateScrollControllerRight,
                  )),
            )
          ]);
        else
          return OsumPieLoadingMsg(
            loadingMsg: "Fetching hardware info...",
          );
      },
    );
  }

  /// Returns the monitor record as a list view.
  ///
  /// Pass the [controller] to hook up with the scrollbar.
  Widget buildMonitorList({@required ScrollController controller}) {
    return ListView(
      controller: controller,
      children: List.generate(10, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.blueGrey[50],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hardware Name $index', style: TextStyle(color: Colors.blueGrey)),
                  // Usage
                  Scrollbar(
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: [
                          for (String metric in _metrics)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularPercentIndicator(
                                radius: 70.0,
                                lineWidth: 10.0,
                                animation: true,
                                percent: 0.7,
                                center: Text(
                                  "0.0%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                footer: Text(
                                  metric,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.blueGrey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Status Text
                  Text(
                    "Status OK   Connected   Version 0.0   Manufacturer <NAME>",
                    style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _monitorStateScrollControllerLeft?.dispose();
    _monitorStateScrollControllerRight?.dispose();
    super.dispose();
  }

  // TODO: build the logic for getting hardware metrics
  @override
  void initState() {
    super.initState();
    _monitorStateScrollControllerLeft = _monitorStateScrollController.addAndGet();
    _monitorStateScrollControllerRight = _monitorStateScrollController.addAndGet();
  }

  Future<dynamic> loadMonitorData() async {
    await Future.delayed(Duration(seconds: 1));
    return '';
  }
}
