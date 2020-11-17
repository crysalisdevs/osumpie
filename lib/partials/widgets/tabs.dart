import 'package:flutter/material.dart';

import '../../globals.dart';


List<Widget> loadTabs(setState) {
  return <Widget>[
    for (String tab in osumTabs.keys)
      Tab(
          child: Row(children: [
        Icon(Icons.file_copy, size: 15.0),
        Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 0, 0),
            child: Text(
              tab,
              style: TextStyle(fontSize: 15.0),
            )),
        IconButton(
          splashRadius: 10.0,
          padding: EdgeInsets.zero,
          icon: Icon(Icons.close),
          iconSize: 16.0,
          onPressed: () => setState(() => osumTabs.remove(tab)),
        )
      ])),
  ];
}

List<Widget> loadTabContent(setState) {
  return <Widget>[for (String tab in osumTabs.keys) osumTabs[tab]];
}