import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:filex/filex.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:osumpie/routes/revision_history.dart';

import '../../globals.dart';
import '../../routes/file_editor.dart';

/// The side navigation bar widget
class SideNavExplorer extends StatefulWidget {
  SideNavExplorer({Key key, this.setStateRoot}) : super(key: key);
  final StateSetter setStateRoot;

  @override
  _SideNavExplorerState createState() => _SideNavExplorerState(setStateRoot);
}

class _SideNavExplorerState extends State<SideNavExplorer> {
  List<String> files;
  ScrollController _directoryScrollController;
  FilexController _filexController;

  final StateSetter setStateRoot;

  _SideNavExplorerState(this.setStateRoot);

  @override
  void initState() {
    files = <String>[];
    _directoryScrollController = ScrollController();
    _filexController = FilexController(path: Directory.current.path);
    super.initState();
  }

  @override
  void dispose() {
    _directoryScrollController?.dispose();
    _filexController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollbar.semicircle(
        alwaysVisibleScrollThumb: true,
        controller: _directoryScrollController,
        child: ListView(
          controller: _directoryScrollController,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
              child: Filex(
                controller: _filexController,
                fileTrailingBuilder: (context, item) {
                  return Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.open_in_new),
                        onPressed: () => setStateRoot(() => osumTabs.addAll({
                              item.filename: FileRawEditor(filename: item.path),
                            })),
                      ),
                      IconButton(
                        icon: Icon(Icons.undo),
                        onPressed: () => setStateRoot(() => osumTabs.addAll({
                              item.filename: RevisionHistory(filename: item.path),
                            })),
                      )
                    ],
                  );
                },
                compact: false,
                actions: <PredefinedAction>[
                  // PredefinedAction.delete,
                ],
              ),
            ),
          ],
        ));
  }
}
