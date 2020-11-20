import 'dart:io';

import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:osumpie/globals.dart';
import 'package:osumpie/routes/revision_history.dart';
import 'package:path/path.dart';

class SideNavExplorer extends StatefulWidget {
  SideNavExplorer({Key key, this.setStateRoot}) : super(key: key);
  final StateSetter setStateRoot;

  @override
  _SideNavExplorerState createState() => _SideNavExplorerState(setStateRoot);
}

class _SideNavExplorerState extends State<SideNavExplorer> {
  List<String> files;
  ScrollController directoryScrollController;

  final StateSetter setStateRoot;

  _SideNavExplorerState(this.setStateRoot);

  @override
  void initState() {
    files = <String>[];
    directoryScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    directoryScrollController.dispose();
    super.dispose();
  }

  String getProjectPathFromFullPath({@required List<String> files, @required String projectName, @required int index}) {
    // Sometimes windows may have multiple path seperators like / & \\ both in same path
    final _filePathWindowsCheck = files[index].split('\\');
    final _filePath = _filePathWindowsCheck.join('/').split('/');
    bool deleteStuff = true;
    _filePath.removeWhere((element) {
      if (deleteStuff) {
        if (element == projectName) {
          deleteStuff = false;
          return false;
        } else
          return true;
      }
      return false;
    });
    return _filePath.join('/');
  }

  IconData getFileIcon(String path) {
    switch (extension(path)) {
      case '.png':
      case '.jpeg':
      case '.jpg':
      case '.bmp':
      case '.png':
        return FontAwesomeIcons.fileImage;
      case '.xml':
      case '.json':
      case '.yaml':
        return FontAwesomeIcons.fileContract;
      case '.recipe':
        return FontAwesomeIcons.breadSlice;
      case '.dart':
      case '.c':
      case '.py':
      case '.h':
      case '.cpp':
      case '.java':
        return Icons.code;
      default:
        return FontAwesomeIcons.file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FileSystemEntity>(
      stream: Directory.current.list(recursive: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          files.add(snapshot.data.path);

          return DraggableScrollbar.semicircle(
            alwaysVisibleScrollThumb: true,
            controller: directoryScrollController,
            child: ListView.builder(
                controller: directoryScrollController,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final path = getProjectPathFromFullPath(
                    files: files,
                    projectName: 'osumpie',
                    index: index,
                  );
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
                    child: ListTile(
                      title: Text(basename(path)),
                      subtitle: Text(path),
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FaIcon(getFileIcon(path)),
                      ),
                      onTap: () {
                        print("etst");
                        setStateRoot(() {
                          osumTabs.addAll({
                            "File History ${basename(path)}": RevisionHistory(fileName: path),
                          });
                        });
                      },
                    ),
                  );
                }),
          );
        }
        return Text("...");
      },
    );
  }
}
