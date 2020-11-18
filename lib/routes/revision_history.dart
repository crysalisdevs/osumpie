import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RevisionHistory extends StatefulWidget {
  RevisionHistory({Key key}) : super(key: key);

  @override
  _RevisionHistoryState createState() => _RevisionHistoryState();
}

class _RevisionHistoryState extends State<RevisionHistory> {
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
        ProcessResult gitVersionResult = await Process.run('git', ['log', '-p', 'lib/main.dart']);
        List<TextSpan> richTextContent = [];
        String result = gitVersionResult.stdout as String;
        List<String> lines = result.split('\n');
        lines.forEach((line) {
          if (line.startsWith('commit'))
            richTextContent.add(TextSpan(text: '$line\n', style: TextStyle(color: Colors.red)));
          else
            richTextContent.add(TextSpan(text: '$line\n', style: TextStyle(color: Colors.black)));
        });

        return RichText(text: TextSpan(children: richTextContent));
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
              controller: revisionHistoryScrollController,
              alwaysVisibleScrollThumb: true,
              child: ListView.builder(
                itemCount: 1,
                controller: revisionHistoryScrollController,
                itemBuilder: (context, position) => snapshot.data,
              ));
        else
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text("Waiting for git..."),
            )
          ]);
      },
    );
  }
}
