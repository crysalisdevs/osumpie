/// File editor route

import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

import '../partials/widgets/error_msg.dart';
import '../partials/widgets/loading_msg.dart';

// TODO: add code hightlighting

/// A raw file editor widget which loads the file [filename].
class FileRawEditor extends StatefulWidget {
  FileRawEditor({Key key, @required this.filename}) : super(key: key);

  final String filename;

  @override
  _FileRawEditorState createState() => _FileRawEditorState(filename);
}

class _FileRawEditorState extends State<FileRawEditor> {
  final String filename;

  TextEditingController _sourceTextController;
  ScrollController _sourceScrollController;

  _FileRawEditorState(this.filename);

  @override
  void dispose() {
    _sourceTextController?.dispose();
    _sourceScrollController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _sourceTextController = TextEditingController();
    _sourceScrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: File(filename).readAsString(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _sourceTextController.text = snapshot.data;
            return DraggableScrollbar.semicircle(
              alwaysVisibleScrollThumb: true,
              controller: _sourceScrollController,
              child: ListView(
                controller: _sourceScrollController,
                children: [
                  TextField(
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: _sourceTextController,
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError)
            return OsumPieErrorMsg(
              error: snapshot.error,
            );
          return const OsumPieLoadingMsg(
            loadingMsg: "Reading file...",
          );
        });
  }
}
