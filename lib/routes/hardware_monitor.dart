import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HardwareMonitorRoute extends StatefulWidget {
  HardwareMonitorRoute({Key key}) : super(key: key);

  @override
  _HardwareMonitorRouteState createState() => _HardwareMonitorRouteState();
}

class _HardwareMonitorRouteState extends State<HardwareMonitorRoute> {
  ScrollController monitorStateScrollController;

  @override
  void initState() {
    monitorStateScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    monitorStateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = ["CPU", "GPU", "TEMP", "RAM", "ROM", "POWER"];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 13, 0, 0),
      child: DraggableScrollbar.semicircle(
        controller: monitorStateScrollController,
        alwaysVisibleScrollThumb: true,
        child: GridView.builder(
            itemCount: 20,
            controller: monitorStateScrollController,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.blueGrey[200],
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Hardware Name $index', style: Theme.of(context).textTheme.headline5),
                          // Usage
                          Scrollbar(
                              child: SingleChildScrollView(
                                  child: Wrap(children: [
                            for (String metric in metrics)
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircularPercentIndicator(
                                    radius: 70.0,
                                    lineWidth: 10.0,
                                    animation: true,
                                    percent: 0.7,
                                    center: Text("0.0%",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color: Colors.white,
                                        )),
                                    footer: Text(metric,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.0,
                                          color: Colors.white,
                                        )),
                                    circularStrokeCap: CircularStrokeCap.round,
                                    progressColor: Colors.white,
                                  )),
                          ]))),
                          // Status Text
                          Text(
                            "Status OK   Connected   Version 0.0   Manufacturer <NAME>",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]))))),
      ),
    );
  }
}
