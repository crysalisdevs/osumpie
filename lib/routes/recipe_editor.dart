import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:uuid/uuid.dart';

import '../partials/widgets/error_msg.dart';
import '../partials/widgets/loading_msg.dart';
import '../partials/widgets/node.dart';

class RecipeEditor extends StatefulWidget {
  RecipeEditor({Key key}) : super(key: key);

  @override
  _RecipeEditorState createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor> with SingleTickerProviderStateMixin {
  List<Widget> _nodes;
  File _nodesFile;
  AnimationController _runAnimationController;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: initAsync(),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.data == null)
          return OsumPieErrorMsg(
            error: snapshot.error ?? 'No recipe? Add recipe block!',
          );
        else if (snapshot.hasData)
          return Stack(
            children: snapshot.data,
          );
        return const OsumPieLoadingMsg(
          loadingMsg: 'Loading receipe...',
        );
      },
    );
  }

  @override
  void dispose() {
    _runAnimationController?.dispose();
    super.dispose();
  }

  Future<List<Widget>> initAsync() async {
    if (!await _nodesFile.exists()) {
      await _nodesFile.create();
    } else {
      String fileContents = await _nodesFile.readAsString();
      Map<String, dynamic> nodeJson = jsonDecode(fileContents);
      nodeJson.forEach((key, value) => _nodes.add(RecipeNode.fromJson(value)));
    }
    return _nodes;
  }

  // get the list of all the job extension paths
  Future<List<FileSystemEntity>> listExtensions() {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = Directory('extensions/').list(recursive: true);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  Map<String, Map<String, Object>> allNodeExtensions = {};

  // get the json files load them and include the job blocks when listing the jobs.
  Future<List<String>> createJobBlock() async {
    List<String> nodeTemplates = [];
    final extensions = await listExtensions();
    for (int i = 0; i < extensions.length; i++) {
      if (await File(extensions[i].path).exists()) {
        String jsonSource = await File(extensions[i].path).readAsString();
        Map<String, Object> json = jsonDecode(jsonSource);
        allNodeExtensions.addAll({json['title']: json});
        nodeTemplates.add(json['title']);
      }
    }
    return nodeTemplates;
  }

  Widget get toolBar => Positioned(
      right: 10,
      child: SlideInDown(
        preferences: AnimationPreferences(offset: Duration(milliseconds: 200)),
        child: FloatingActionRow(
          color: Colors.black,
          children: <Widget>[
            // Add job button
            FutureBuilder<List<String>>(
                future: createJobBlock(),
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return PopupMenuButton<String>(
                        tooltip: 'Add a job',
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                        onSelected: (value) => setState(() => _nodes.add(RecipeNode(
                              top: 10,
                              left: 10,
                              width: allNodeExtensions[value]['width'],
                              height: allNodeExtensions[value]['height'],
                              title: value,
                              description: allNodeExtensions[value]['description'],
                              properties: allNodeExtensions[value]['properties'],
                              author: allNodeExtensions[value]['author'],
                              gitUpdathPath: null, //allNodeExtensions[value]['gitUpdathPath'],
                              isDisabled: false,
                            ))),
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
                onPressed: saveNodes,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                tooltip: 'Save',
                child: Icon(Icons.save)),
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

  @override
  void initState() {
    super.initState();
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _nodes = [];
    _nodesFile = File('test.json');
    _nodes.add(toolBar);
  }

  void runProject() {
    if (_runAnimationController.isCompleted)
      _runAnimationController.reverse();
    else
      _runAnimationController.forward();
  }

  Future<void> saveNodes() async {
    Map<String, dynamic> jsonData = {};
    if (!await _nodesFile.exists()) {
      await _nodesFile.create();
    }
    _nodes.forEach((element) {
      if (element is RecipeNode) {
        jsonData.addAll({Uuid().v4(): element.toJson()});
      }
    });
    _nodesFile.writeAsString(jsonEncode(jsonData));
  }
}
