import 'dart:convert';
import 'dart:io';

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

  @override
  void initState() {
    super.initState();
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _nodes = [];
    _nodesFile = File('test.json');
    _nodes.addAll([
      Positioned(
        right: 150,
        child: BounceIn(
          child: FloatingActionButton(
            tooltip: 'Save receipe',
            child: Icon(Icons.save),
            onPressed: saveNodes,
          ),
        ),
      ),
      Positioned(
        right: 80,
        child: BounceIn(
          child: FloatingActionButton(
              tooltip: 'Add recipe block',
              child: Icon(Icons.add),
              onPressed: () => setState(() => _nodes.addAll([RecipeNode(
                    bottom: null,
                    right: 0,
                    description: '',
                    height: null,
                    left: 0,
                    parameters: {},
                    title: 'Hi',
                    width: 200,
                    top: null,
                  )]))),
        ),
      ),
      Positioned(
        right: 10,
        child: BounceIn(
          child: FloatingActionButton(
              onPressed: runProject,
              tooltip: 'Run the project',
              child: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _runAnimationController,
              )),
        ),
      ),
    ]);
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
