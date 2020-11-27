import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../globals.dart';
import '../partials/widgets/error_msg.dart';
import '../partials/widgets/loading_msg.dart';
import '../partials/widgets/node_widget.dart';

class RecipeEditor extends StatefulWidget {
  final File file;

  RecipeEditor({Key key, @required this.file}) : super(key: key);

  @override
  _RecipeEditorState createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor> with SingleTickerProviderStateMixin {
  List<Widget> _widgets = [];
  AnimationController _runAnimationController;
  Map<String, Map<String, dynamic>> _availableJobBlocks = {};

  Widget get toolBar => Positioned(
      right: 10,
      child: SlideInDown(
        preferences: AnimationPreferences(offset: Duration(milliseconds: 200)),
        child: FloatingActionRow(
          color: Colors.black,
          children: <Widget>[
            // Add job button
            FutureBuilder<List<String>>(
                future: listJobs(),
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return PopupMenuButton<String>(
                        tooltip: 'Add a job',
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                        onSelected: addJob,
                        itemBuilder: (context) => snapshot.data
                            .map((String value) => PopupMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList());
                  else if (snapshot.hasError) return Icon(Icons.error);
                  return CircularProgressIndicator();
                }),
            FloatingActionRowDivider(),
            FloatingActionButton(
                onPressed: saveReceipeFile,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                tooltip: 'Save',
                child: Icon(Icons.point_of_sale)),
            FloatingActionRowDivider(),
            FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                tooltip: 'Delete Job',
                child: Icon(Icons.delete)),
            FloatingActionRowDivider(),
            FloatingActionButton(
                onPressed: runProject,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                tooltip: 'Run',
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _runAnimationController,
                )),
          ],
        ),
      ));

  bool _reFuturelock = false;

  void addJob(String value) => setState(() => _widgets.add(
        NodeBlock(
          top: 10,
          left: 10,
          width: _availableJobBlocks[value]['width'],
          height: _availableJobBlocks[value]['height'],
          title: value,
          description: _availableJobBlocks[value]['description'],
          properties: _availableJobBlocks[value]['properties'],
          author: _availableJobBlocks[value]['author'],
          myUuid: Uuid().v4(),
          leftUuid: null,
          rightUuid: null,
        ),
      ));

  final stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Widget>>(
        future: loadReceipeFile(),
        builder: (context, snapshot) {
          if (snapshot.hasError || snapshot.data == null)
            return Stack(
              children: [
                OsumPieErrorMsg(
                  error: snapshot.error ?? 'No recipe? Add recipe block!',
                ),
                toolBar
              ],
            );
          else if (snapshot.hasData)
            return Stack(
              key: stackKey,
              children: [toolBar]..addAll(snapshot.data),
            );
          return const OsumPieLoadingMsg(
            loadingMsg: 'Loading receipe...',
          );
        },
      );

  // get the list of all the job extension paths
  @override
  void dispose() {
    _runAnimationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  // get the json files load and include the job blocks when listing the jobs.
  Future<List<FileSystemEntity>> listExtensions() {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = Directory('extensions/').list(recursive: true);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  Future<List<String>> listJobs() async {
    List<String> nodeTemplates = [];
    final extensions = await listExtensions();
    for (int i = 0; i < extensions.length; i++) {
      if (await File(extensions[i].path).exists() && extension(extensions[i].path) == '.json') {
        String jsonSource = await File(extensions[i].path).readAsString();
        Map<String, Object> json = jsonDecode(jsonSource);
        _availableJobBlocks.addAll({json['title']: json});
        nodeTemplates.add(json['title']);
      }
    }
    return nodeTemplates;
  }

  Future<List<Widget>> loadReceipeFile() async {
    if (!_reFuturelock) {
      _reFuturelock = true;
      renderLines();
      if (!await widget.file.exists()) {
        await widget.file.create();
      } else {
        String fileContents = await widget.file.readAsString();
        try {
          Map<String, dynamic> nodes = jsonDecode(fileContents);
          nodes.forEach((uuid, nodeData) {
            _widgets.add(NodeBlock.fromJson(nodeData));
          });
        } on FormatException catch (e) {
          if (e.message == 'Unexpected end of input')
            return null;
          else
            throw e;
        }
      }
    }
    return _widgets;
  }

  void renderLines() {
    Timer.periodic(Duration(seconds: 1), (Timer t) {
      _widgets.removeWhere((widgetInside) => widgetInside is CustomPaint);
      if (selectedForLines.length % 2 == 0 && selectedForLines.length >= 2)
        for (int i = 0; i < selectedForLines.length; i += 2) {
          print(selectedForLines);
          
          setState(() {
            _widgets.add(CustomPaint(
                painter: NodeConnectionLines(
              [selectedForLines[i + 1].left, selectedForLines[i + 1].top],
              [selectedForLines[i].left, selectedForLines[i].top],
            )));
          });
        }
    });
  }

  // save the node setup to a file
  void runProject() {
    if (_runAnimationController.isCompleted)
      _runAnimationController.reverse();
    else
      _runAnimationController.forward();
  }

  Future<void> saveReceipeFile() async {
    if (!await widget.file.exists()) await widget.file.create();
    var nodeBlocks = {};
    _widgets.forEach((widget) {
      if (widget is NodeBlock) {
        nodeBlocks.addAll({
          widget.myUuid: widget.toJson(),
        });
      }
    });
    widget.file.writeAsString(jsonEncode(nodeBlocks));
  }
}
