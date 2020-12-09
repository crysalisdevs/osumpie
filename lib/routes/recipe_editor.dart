import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:floating_action_row/floating_action_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../partials/widgets/error_msg.dart';
import '../partials/widgets/loading_msg.dart';
import '../partials/widgets/node_widget.dart';

/// The receipe editor route which handles the receipe creating, saving, etc.
///
/// The [file] object must be passed to open it in receipe editor.
class RecipeEditor extends StatefulWidget {
  final File file;

  RecipeEditor({Key key, @required this.file}) : super(key: key);

  @override
  _RecipeEditorState createState() => _RecipeEditorState();
}

class _RecipeEditorState extends State<RecipeEditor>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  /// All the widgets inside the receipe editor.
  List<Widget> _widgets = [];

  /// All the available jobs that can be added.
  Map<String, Map<String, dynamic>> _availableJobBlocks = {};

  /// The jobs who must be connected with lines are stored here.
  List<NodeBlock> selectedForLines = [];

  /// Prevent from reloading the receipe editor when setStating.
  bool _reFuturelock = false;

  AnimationController _runAnimationController;

  bool lockEditorPan = false;

  TransformationController _transformationController;

  /// The floating toolbar used to create and delete jobs.
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
            // Delete button
            FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                tooltip: 'Delete Job',
                child: Icon(Icons.delete)),
            FloatingActionRowDivider(),
            // Run button
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
  bool get wantKeepAlive => true;

  /// Add a job into the receipe editor.
  ///
  /// The [name] of the job node.
  void addJob(String name) {
    setState(() => _widgets.add(
          NodeBlock(
            top: 10,
            left: 10,
            width: _availableJobBlocks[name]['width'],
            height: _availableJobBlocks[name]['height'],
            title: name,
            description: _availableJobBlocks[name]['description'],
            properties: _availableJobBlocks[name]['properties'],
            author: _availableJobBlocks[name]['author'],
            myUuid: Uuid().v4(),
            rightUuid: null,
            renderLinesCallback: renderLines,
            nodeBlocks: selectedForLines,
            saveReceipeFileCallback: saveReceipeFile,
            lockEditorPan: lockEditorPan,
            setStateRoot: setState,
          ),
        ));
    saveReceipeFile();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<Widget>>(
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
          // Disabling the panning when scroll feature in desktop as it is hard
          // to pan node because it will pan the editor also.
          return InteractiveViewer(
            transformationController: _transformationController,
            panEnabled: true,
            scaleEnabled: true,
            boundaryMargin: const EdgeInsets.all(5.0),
            constrained: false,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(
                height: 5000,
                width: 5000,
              ),
              child: Stack(
                children: [toolBar]..addAll(snapshot.data),
              ),
            ),
          );
        return const OsumPieLoadingMsg(
          loadingMsg: 'Loading receipe...',
        );
      },
    );
  }

  // get the json files load and include the job blocks when listing the jobs.
  @override
  void dispose() {
    _runAnimationController?.dispose();
    _transformationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _runAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _transformationController = TransformationController();
  }

  Future<List<FileSystemEntity>> listExtensions() {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = Directory('bakecode-jobs/lib/stl/').list(recursive: true);
    lister.listen((file) => files.add(file),
        // should also register onError
        onDone: () => completer.complete(files));
    return completer.future;
  }

  /// List all the available jobs that can be added in to the receipe editor.
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

  /// Load the receipe file into the receipe editor and prepare connection logic.
  Future<List<Widget>> loadReceipeFile() async {
    if (!_reFuturelock) {
      _reFuturelock = true;
      if (!await widget.file.exists()) {
        await widget.file.create();
      } else {
        String fileContents = await widget.file.readAsString();
        try {
          Map<String, dynamic> nodes = jsonDecode(fileContents);
          nodes.forEach((uuid, nodeData) => _widgets.add(
                NodeBlock.fromJson(nodeData, renderLines, selectedForLines, saveReceipeFile, lockEditorPan, setState),
              ));
        } on FormatException catch (e) {
          if (e.message == 'Unexpected end of input')
            return null;
          else
            throw e;
        }
      }
    }
    // Connection line logic
    _widgets.forEach((widget) {
      if (widget is NodeBlock) {
        if (widget.rightUuid != null) {
          selectedForLines.add(widget);
          final otherNode = List<NodeBlock>.from(_widgets.where((widget2) {
            if (widget2 is NodeBlock) return widget2.myUuid == widget.rightUuid;
            return false;
          }).toList());
          selectedForLines.addAll(otherNode);
        }
      }
    });
    renderLines();
    return _widgets;
  }

  /// Draw the connections between two jobs.
  void renderLines() {
    _widgets.removeWhere((widgetInside) => widgetInside is CustomPaint);
    if (selectedForLines.length % 2 == 0 && selectedForLines.length >= 2)
      for (int i = 0; i < selectedForLines.length; i += 2) {
        setState(
          () => _widgets.insert(
            0,
            CustomPaint(
                painter: NodeConnectionLines([
              selectedForLines[i + 1].left + selectedForLines[i + 1].width / 2,
              selectedForLines[i + 1].top + selectedForLines[i + 1].height / 2
            ], [
              selectedForLines[i].left + selectedForLines[i].width / 2,
              selectedForLines[i].top + selectedForLines[i].height / 2
            ])),
          ),
        );
        selectedForLines[i].rightUuid = selectedForLines[i + 1].myUuid;
        saveReceipeFile();
      }
  }

  // To keep the tab content state alive.
  void runProject() {
    if (_runAnimationController.isCompleted)
      _runAnimationController.reverse();
    else
      _runAnimationController.forward();
  }

  /// Save the receipe to the file.
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
