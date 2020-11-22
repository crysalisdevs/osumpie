import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:osumpie/partials/widgets/error_msg.dart';
import 'package:osumpie/partials/widgets/loading_msg.dart';

/// Displays the revision history of the [fileName] using git
class RevisionHistory extends StatefulWidget {
  final String filename;

  RevisionHistory({Key key, @required this.filename}) : super(key: key);

  @override
  _RevisionHistoryState createState() => _RevisionHistoryState(filename);
}

class _RevisionHistoryState extends State<RevisionHistory> {
  final String filename;

  _RevisionHistoryState(this.filename);

  ScrollController _revisionHistoryScrollController;

  @override
  void initState() {
    _revisionHistoryScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _revisionHistoryScrollController?.dispose();
    super.dispose();
  }

  /// Get the file history using git commands.
  Future<List<Widget>> getFileHistory() async {
    if (!kIsWeb) {
      ProcessResult gitCheck = await Process.run('git', ['--version'], runInShell: false);
      if (gitCheck.exitCode == 0) {
        // do git versioning
        if (filename != null) {
          ProcessResult fileVersionResult =
              await Process.run('git', ['log', '--format=fuller', '--date=local', '-p', filename], runInShell: false);
          List<Widget> commitMsgWidgets = <Widget>[];
          String result = fileVersionResult.stdout as String;
          List<String> lines = result.split('\n');
          for (int lineNumber = 0; lineNumber < lines.length; lineNumber++) {
            if (lines[lineNumber].startsWith('commit')) {
              String commitHash = lines[lineNumber].substring(7);
              String commitMsg = lines[lineNumber + 6].replaceFirst('    ', '');
              String commitAuthor = '@${lines[lineNumber + 3].substring(12)}';
              String commitDate = lines[lineNumber + 4].substring(12);

              commitMsgWidgets.add(ListTile(
                isThreeLine: true,
                title: Text(commitMsg, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(commitAuthor,
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(commitDate)
                ]),
                trailing: SizedBox(
                  width: 420,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(commitHash, style: TextStyle(color: Colors.blueGrey)),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                          child: RaisedButton.icon(
                            icon: Icon(Icons.undo),
                            label: Text("Undo"),
                            onPressed: () {},
                          )),
                    ],
                  ),
                ),
                onTap: () {},
              ));
              lineNumber += 11;
            } else if (lines[lineNumber].startsWith('-'))
              commitMsgWidgets.add(Text(lines[lineNumber].substring(1),
                  style: TextStyle(
                    color: Colors.blueGrey[200],
                    decoration: TextDecoration.lineThrough,
                  )));
            else if (lines[lineNumber].startsWith('+'))
              commitMsgWidgets.add(Text(lines[lineNumber].substring(1),
                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)));
            else
              commitMsgWidgets.add(Text(lines[lineNumber]));
          }
          return commitMsgWidgets; // RichText(text: TextSpan(children: commitMsgWidgets));
        } else
          return <Widget>[
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: OsumPieErrorMsg(
                  error: "File name not specified",
                ))
          ];
      } else
        return <Widget>[const Text('Git is not installed to work with file versioning')];
    }
    return <Widget>[const Text('File versioning not support on web yet')];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFileHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return DraggableScrollbar.semicircle(
            alwaysVisibleScrollThumb: true,
            controller: _revisionHistoryScrollController,
            child: ListView(
              controller: _revisionHistoryScrollController,
              children: snapshot.data,
            ),
          );
        else
          return const OsumPieLoadingMsg(
            loadingMsg: "Waiting for git...",
          );
      },
    );
  }
}
