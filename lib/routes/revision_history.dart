import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RevisionHistory extends StatefulWidget {
  final String fileName;

  RevisionHistory({Key key, @required this.fileName}) : super(key: key);

  @override
  _RevisionHistoryState createState() => _RevisionHistoryState(fileName);
}

class _RevisionHistoryState extends State<RevisionHistory> {
  final String fileName;

  _RevisionHistoryState(this.fileName);

  ScrollController revisionHistoryScrollController;

  @override
  void initState() {
    revisionHistoryScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    revisionHistoryScrollController.dispose();
    super.dispose();
  }

  Future<Widget> getFileHistory() async {
    if (!kIsWeb) {
      ProcessResult gitCheck = await Process.run('git', ['--version']);
      if (gitCheck.exitCode == 0) {
        // do git versioning
        if (fileName != null) {
          ProcessResult gitVersionResult = await Process.run('git', ['log', '-p', fileName]);
          List<TextSpan> richTextContent = [];
          String result = gitVersionResult.stdout as String;
          List<String> lines = result.split('\n');
          for(int lineNumber = 0; lineNumber < lines.length; lineNumber++) {
            if(lines[lineNumber].startsWith('commit'))
              richTextContent.add(TextSpan(text: '${lines[lineNumber]}\n', style: TextStyle(color: Colors.red)));
            else
              richTextContent.add(TextSpan(text: '${lines[lineNumber]}\n', style: TextStyle(color: Colors.black)));
          }
          // lines.forEach((line) {
          //   if (line.startsWith('commit'))
          //     richTextContent.add(TextSpan(text: '$line\n', style: TextStyle(color: Colors.red)));
          //   else
          //     richTextContent.add(TextSpan(text: '$line\n', style: TextStyle(color: Colors.black)));
          // });
          return RichText(text: TextSpan(children: richTextContent));
        } else
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error),
              const Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: const Text("File name not specified"),
              ),
            ]),
          );
      } else
        return const Text('Git is not installed to work with file versioning');
    }
    return const Text('File versioning not support on web yet');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFileHistory(),
      builder: (context, snapshot) {
        if (snapshot.hasData)
          return DraggableScrollbar.semicircle(
              alwaysVisibleScrollThumb: true,
              controller: revisionHistoryScrollController,
              child: ListView.builder(
                  itemCount: 1,
                  controller: revisionHistoryScrollController,
                  itemBuilder: (context, position) => snapshot.data));
        else
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const CircularProgressIndicator(),
            const Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text("Waiting for git..."),
            )
          ]);
      },
    );
  }
}
