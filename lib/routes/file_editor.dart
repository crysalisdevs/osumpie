/// File editor route
import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';

import '../partials/widgets/error_msg.dart';
import '../partials/widgets/loading_msg.dart';

// NOTE: raw editor is deprecated use system default text/code editor instead.

/// A raw file viewer widget which loads the file [filename].
class FileRawEditor extends StatefulWidget {
  final String filename;

  FileRawEditor({Key key, @required this.filename}) : super(key: key);

  @override
  _FileRawEditorState createState() => _FileRawEditorState();
}

class _FileRawEditorState extends State<FileRawEditor> with AutomaticKeepAliveClientMixin {
  final _sourceScrollController = ScrollController();
  final _sourceTextController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<String>(
        future: File(widget.filename).readAsString(),
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

  @override
  void dispose() {
    _sourceTextController?.dispose();
    _sourceScrollController?.dispose();
    super.dispose();
  }
}
