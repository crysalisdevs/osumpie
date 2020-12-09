import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:filex/filex.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../../globals.dart';
import '../../routes/file_editor.dart';
import '../../routes/recipe_editor.dart';
import '../../routes/revision_history.dart';

/// The side navigation bar widget
class SideNavExplorer extends StatefulWidget {
  final StateSetter setStateRoot;

  SideNavExplorer({Key key, this.setStateRoot}) : super(key: key);

  @override
  _SideNavExplorerState createState() => _SideNavExplorerState();
}

class _SideNavExplorerState extends State<SideNavExplorer> {
  final _directoryScrollController = ScrollController();
  final _filexController = FilexController(path: Directory.current.path);

  @override
  Widget build(BuildContext context) => DraggableScrollbar.semicircle(
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
                      onPressed: () => widget.setStateRoot(() => osumTabs.addAll({
                            item.filename: extension(item.path) == '.receipe'
                                ? RecipeEditor(file: File(item.path))
                                : FileRawEditor(filename: item.path),
                          })),
                    ),
                    IconButton(
                      icon: Icon(Icons.undo),
                      onPressed: () => widget.setStateRoot(() => osumTabs.addAll({
                            item.filename: RevisionHistory(filename: item.path),
                          })),
                    )
                  ],
                );
              },
              compact: false,
            ),
          ),
        ],
      ));

  @override
  void dispose() {
    _directoryScrollController?.dispose();
    _filexController?.dispose();
    super.dispose();
  }
}
